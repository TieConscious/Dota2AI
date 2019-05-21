local module = require(GetScriptDirectory().."/helpers")
local globalState = require(GetScriptDirectory().."/global_state")

-- todo: adjust for dire
--1st tower top 0.42 under == pulled
--

--globalState.state.furthestLane = penis

--1, 2, 3, on destroyed state, 4 on pushed
local pulledPushed = {
	[TEAM_RADIANT] =
	{
		[LANE_TOP] = {0.42, 0.28, 0.19, 0.65},
		[LANE_MID] = {0.52, 0.37, 0.28, 0.61},
		[LANE_BOT] = {0.65, 0.33, 0.19, 0.7}
	},
	[TEAM_DIRE] =
	{
		[LANE_TOP] = {0.65, 0.33, 0.19, 0.7},
		[LANE_MID] = {0.52, 0.37, 0.28, 0.61},
		[LANE_BOT] = {0.42, 0.28, 0.19, 0.65}
	}
}

local lane_state = {
	[LANE_TOP] = 0,
	[LANE_MID] = 0,
	[LANE_BOT] = 0
}

local decided = {}
local targetLane
local gankTime = 900

function LanePushedPulledNotHealing(npcBot)
	local myLane = module.GetLane(npcBot)
	local pID = npcBot:GetPlayerID()
	local percentHealth = module.CalcPerHealth(npcBot)
	local team = GetTeam()
	local time = DotaTime()

	local gankable = {
		[LANE_TOP] = true,
		[LANE_MID] = true,
		[LANE_BOT] = true
	}

	gankable[myLane] = nil

	if time < gankTime and myLane == LANE_TOP then
		gankable[LANE_BOT] = nil
	end
	if time < gankTime and myLane == LANE_BOT then
		gankable[LANE_TOP] = nil
	end

	local myFrontAmount = GetLaneFrontAmount(team, myLane, false)
	if myFrontAmount > pulledPushed[team][myLane][4] then
		lane_state[myLane] = 1
	end
	if	((time < gankTime or module.GetTower1(npcBot)) ~= nil and myFrontAmount < pulledPushed[team][myLane][1]) or
		(module.GetTower2(npcBot) ~= nil and myFrontAmount < pulledPushed[team][myLane][2]) or
		(myFrontAmount < pulledPushed[team][myLane][3]) then
		lane_state[myLane] = 0
	end

	if lane_state[myLane] == 0 or percentHealth < 0.5 or npcBot:DistanceFromFountain() == 0 or npcBot:HasModifier("modifier_flask_healing") or npcBot:GetLevel() < 8 then
		return false
	end

	if time < gankTime then
		if decided[pID] == nil or decided[pID] + 30 < time then
			local pulledLane = false
			for lane, exist in pairs(gankable) do
				if exist ~= nil and GetLaneFrontAmount(team, lane, false) < pulledPushed[team][lane][1] and
					globalState.state.laneInfo[lane].numEnemies > 0 and globalState.state.laneInfo[lane].numAllies > 0 then
					pulledLane = true
				end
			end
			if pulledLane == false then
				return false
			end
		end
		decided[pID] = time

		if lane == LANE_MID then
			local midDist = GetUnitToLocationDistance(npcBot, GetLaneFrontLocation(team, LANE_MID, 0))
			if  midDist < 2000 then
				if pulledPushed[team][LANE_BOT][1] < GetLaneFrontAmount(team, LANE_BOT, false) then
					midTargetLane = LANE_BOT
				elseif pulledPushed[team][LANE_TOP][1] < GetLaneFrontAmount(team, LANE_TOP, false) then
					midTargetLane = LANE_TOP
				else
					midTargetLane = LANE_BOT
				end
			end
			targetLane = midTargetLane
		else
			targetLane = LANE_MID
		end
	else
		targetLane = globalState.state.furthestLane
	end

	return true
end

--function EnemiesInLane()
--	local enemiesTop = globalState.state.laneInfo[1].numEnemies
--	local alliesTop = globalState.state.laneInfo[1].numAllies
--end
--
--function AlliesInLane()
--end

function GoGank(npcBot)
	local myLane = module.GetLane(npcBot)
	local targetLaneFront = GetLaneFrontLocation(npcBot:GetTeam(), targetLane, 0)
	if (GetUnitToLocationDistance(npcBot, targetLaneFront) < 1000) then
		return 0
	end
	return 25
end

local gank_weight = {
    settings =
    {
        name = "gank",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
        	{func=GoGank, condition=LanePushedPulledNotHealing, weight=1}
        },

		multipliers = {
		}
    }
}

return gank_weight