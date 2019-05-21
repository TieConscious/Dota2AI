
local globalState = {
	state =
	{
		calculationTime = 0.0,

		enemiesAlive = 0,
		enemiesMissing = 0,
		enemiesInBase = 0,

		alliesAlive = 0,
		alliesInBase = 0,

		furthestLane = 0,
		furthestLaneAmount = 0,
		closestLane = 0,
		closestLaneAmount = 0,
		laneInfo =
		{
			[LANE_TOP] = {numEnemies = 0, numAllies = 0},
			[LANE_MID] = {numEnemies = 0, numAllies = 0},
			[LANE_BOT] = {numEnemies = 0, numAllies = 0}
		},
		teammates = {
			--<id> = {
			--	currentState = "idle"
			--	stateWeight = 30
			--	movingTo = <pos>
			--}
		}
	}
}

local lanes =
{
	LANE_TOP,
	LANE_MID,
	LANE_BOT
}

local deadEnemies = {}

function globalState.getEnemyInfo(team)
	local enemyIDs = GetTeamPlayers(GetOpposingTeam())
	local livingEnemies = 0
	local missingEnemies = 0
	local baseEnemies = 0
	local ancient = GetAncient(team)
	local unitList = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local visibleEnemyLoc = {}
	for _,unit in pairs(unitList) do
		if unit:CanBeSeen() then
			visibleEnemyLoc[unit:GetPlayerID()] = unit:GetLocation()
		end
	end
	--DebugDrawCircle(ancient:GetLocation(), 2500, 0, 255, 0)
	for _,eID in pairs(enemyIDs) do
		--living enemies
		local lsi = {}
		if visibleEnemyLoc[eID] ~= nil then
			lsi[1] = {}
			lsi[1].time_since_seen = 0
			lsi[1].location = visibleEnemyLoc[eID]
		else
			lsi = GetHeroLastSeenInfo(eID)
		end
		if IsHeroAlive(eID) and lsi ~= nil and #lsi > 0 then
			livingEnemies = livingEnemies + 1
			--missing enemies
			if (lsi[1].time_since_seen > 7) then
				missingEnemies = missingEnemies + 1
			end
			--enemies in base
			if (visibleEnemyLoc[eID] ~= nil and GetUnitToLocationDistance(ancient, visibleEnemyLoc[eID]) < 2500) and deadEnemies[eID] == nil then
					baseEnemies = baseEnemies + 1
					--DebugDrawCircle(lsi[1].location, 100, 255, 0, 0)
			end
			deadEnemies[eID] = nil
		elseif not IsHeroAlive(eID) and lsi ~= nil and #lsi > 0 then
			deadEnemies[eID] = true
		end
	end
	globalState.state.enemiesAlive = livingEnemies
	globalState.state.enemiesMissing = missingEnemies
	globalState.state.enemiesInBase = baseEnemies
end

function globalState.getAllyInfo(team)
	local allyIDs = GetTeamPlayers(GetTeam())
	local livingAllies = 0
	local baseAllies = 0
	local ancient = GetAncient(team)
	--DebugDrawCircle(ancient:GetLocation(), 2500, 0, 255, 0)
	for _,aID in pairs(enemyIDs) do
		--living enemies
		local lsi = GetHeroLastSeenInfo(aID)
		if IsHeroAlive(aID) and lsi ~= nil and #lsi > 0 then
			livingAllies = livingAllies + 1
			--missing enemies
			--enemies in base
			if (lsi[1].time_since_seen < 2 and GetUnitToLocationDistance(ancient, lsi[1].location) < 2500) then
					baseAllies = baseAllies + 1
					--DebugDrawCircle(lsi[1].location, 100, 255, 0, 0)
			end
		end
	end
	globalState.state.alliesAlive = livingAllies
	globalState.state.alliesInBase = baseAllies
end

local maxLaneDist = 1000

function globalState.getLaneInfo(team)
	globalState.state.furthestLaneAmount = 0
	globalState.state.closestLaneAmount = 100
	for _,lane in pairs(lanes) do
		globalState.state.laneInfo[lane].numAllies = 0
		globalState.state.laneInfo[lane].numEnemies = 0
		local pushDist = GetLaneFrontAmount(team, lane, false)
		if pushDist > globalState.state.furthestLaneAmount then
			globalState.state.furthestLane = lane
			globalState.state.furthestLaneAmount = pushDist
		end
		if pushDist < globalState.state.closestLaneAmount then
			globalState.state.closestLane = lane
			globalState.state.closestLaneAmount = pushDist
		end
	end

	--count enemies in lane
	local enemyIDs = GetTeamPlayers(GetOpposingTeam())
	for _,eID in pairs(enemyIDs) do
		--living enemies
		local lsi = GetHeroLastSeenInfo(eID)
		local closestLane = 0
		if IsHeroAlive(eID) and lsi ~= nil and #lsi > 0 and lsi[1].time_since_seen < 2 then  --nil value
			local smallestDist = maxLaneDist
			for _,lane in pairs(lanes) do
				local o = GetAmountAlongLane(lane, lsi[1].location)
				if o.distance ~= nil and o.distance < smallestDist then
					closestLane = lane
				end
			end
		end
		if closestLane ~= 0 and closestLane ~= nil then
			globalState.state.laneInfo[closestLane].numEnemies = globalState.state.laneInfo[closestLane].numEnemies + 1
		end
	end

	--count allies in lane
	for i = 1,5,1 do
		--living enemies
		local unit = GetTeamMember(i)
		local closestLane = 0
		if IsHeroAlive(unit:GetPlayerID()) then
			local smallestDist = maxLaneDist
			for _,lane in pairs(lanes) do
				local dist = GetUnitToLocationDistance(unit, GetLaneFrontLocation(team, lane, 0))
				if dist < smallestDist then
					closestLane = lane
				end
			end
		end
		if closestLane ~= 0 and closestLane ~= nil then
			globalState.state.laneInfo[closestLane].numAllies = globalState.state.laneInfo[closestLane].numAllies + 1
		end
	end

end

function globalState.calculateState(team)
	local currTime = DotaTime()
	if currTime <= globalState.state.calculationTime then
		return
	end
	globalState.state.calculationTime = currTime
	globalState.getLaneInfo(team)
	globalState.getEnemyInfo(team)
	--print(globalState.state.closestLane)
	--globalState.printState()
	--globalState.printTeammateInfo()
end

function globalState.printLaneInfo(lanename, lane)
	local str = string.format("  %s:\n", lanename)
	for name,value in pairs(globalState.state.laneInfo[lane]) do
		str = str..string.format("  %s=%03d\n", name, value)
	end
	return str
end

function globalState.printTeammateInfo()
	local str = "--Team State Info--\n"
	for pid,tab in pairs(globalState.state.teammates) do
		str = str..string.format("%s:\n", GetSelectedHeroName(pid))
		str = str..string.format("\t%s=%s\n", "state", tab.currentState)
		str = str..string.format("\t%s=%03d\n", "weight", tab.stateWeight)
	end
	print (str)
end

function globalState.printState()
	local str = "--Global State Info--\n"
	for name,value in pairs(globalState.state) do
		if name ~= "laneInfo" and name ~= "teammates" then
			str = str..string.format("%s=%03d\n", name, value)
		end
	end
	--print laneInfo
	str = str..globalState.printLaneInfo("TOP",LANE_TOP)
	str = str..globalState.printLaneInfo("MID",LANE_MID)
	str = str..globalState.printLaneInfo("BOT",LANE_BOT)
	print(str)
end

return globalState