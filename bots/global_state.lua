
local globalState = {
	state =
	{
		calculationTime = 0.0,

		enemiesAlive = 0,
		enemiesMissing = 0,
		enemiesInBase = 0,

		furthestLane = 0,
		furthestLaneAmount = 0,
		closestLane = 0,
		closestLaneAmount = 0,
		laneInfo =
		{
			[LANE_TOP] = {numEnemies = 0, numAllies = 0},
			[LANE_MID] = {numEnemies = 0, numAllies = 0},
			[LANE_BOT] = {numEnemies = 0, numAllies = 0}
		}
	}
}

local lanes =
{
	LANE_TOP,
	LANE_MID,
	LANE_BOT
}



function globalState.getEnemyInfo(team)
	local enemyIDs = GetTeamPlayers(GetOpposingTeam())
	local livingEnemies = 0
	local missingEnemies = 0
	local baseEnemies = 0
	local ancient = GetAncient(team)
	--DebugDrawCircle(ancient:GetLocation(), 2500, 0, 255, 0)
	for _,eID in pairs(enemyIDs) do
		--living enemies
		local lsi = GetHeroLastSeenInfo(eID)
		if IsHeroAlive(eID) and lsi ~= nil and #lsi > 0 then
			livingEnemies = livingEnemies + 1
			--missing enemies
			if (lsi[1].time_since_seen > 7) then
				missingEnemies = missingEnemies + 1
			end
			--enemies in base
			if (lsi[1].time_since_seen < 2 and GetUnitToLocationDistance(ancient, lsi[1].location) < 2500) then
					baseEnemies = baseEnemies + 1
					--DebugDrawCircle(lsi[1].location, 100, 255, 0, 0)
			end
		end
	end
	globalState.state.enemiesAlive = livingEnemies
	globalState.state.enemiesMissing = missingEnemies
	globalState.state.enemiesInBase = baseEnemies
end

local maxLaneDist = 1000

function globalState.getLaneInfo(team)
	for _,lane in pairs(lanes) do
		globalState.state.laneInfo[lane].numAllies = 0
		globalState.state.laneInfo[lane].numEnemies = 0
		local pushDist = GetLaneFrontAmount(team, lane, false)
		if pushDist > globalState.state.furthestLaneAmount then
			globalState.state.furthestLane = lane
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
			globalState.state.closestLane = closestLane
			globalState.state.closestLaneAmount = GetLaneFrontLocation(team, closestLane, 0)
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
	--globalState.printState()
end

function globalState.printLaneInfo(lanename, lane)
	local str = string.format("  %s:\n", lanename)
	for name,value in pairs(globalState.state.laneInfo[lane]) do
		str = str..string.format("  %s=%03d\n", name, value)
	end
	return str
end

function globalState.printState()
	local str = "--Global State Info--\n"
	for name,value in pairs(state) do
		if name ~= "laneInfo" then
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