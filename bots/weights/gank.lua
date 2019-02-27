local module = require(GetScriptDirectory().."/helpers")

-- todo: adjust for dire
--1st tower top 0.42 under == pulled
--

local pulledPushed = {
	[TEAM_RADIANT] =
	{
		[LANE_TOP] = {0.42, 0.65},
		[LANE_MID] = {0.52, 0.61},
		[LANE_BOT] = {0.65, 0.7}
	},
	[TEAM_DIRE] =
	{
		[LANE_TOP] = {0.7, 0.65},
		[LANE_MID] = {0.52, 0.61},
		[LANE_BOT] = {0.65, 0.42}
	},
}

local lane_state = {
	[LANE_TOP] = 0,
	[LANE_MID] = 0,
	[LANE_BOT] = 0
}

local decided = {}

function LanePushedPulledNotHealing(npcBot)
	local myLane = module.GetLane(npcBot)
	local pID = npcBot:GetPlayerID()
	local percentHealth = module.CalcPerHealth(npcBot)
	local team = GetTeam()

	local gankable = {
		[LANE_TOP] = true,
		[LANE_MID] = true,
		[LANE_BOT] = true
	}

	gankable[myLane] = nil
	if myLane == LANE_TOP then
		gankable[LANE_BOT] = nil
	end
	if myLane == LANE_BOT then
		gankable[LANE_TOP] = nil
	end

	if GetLaneFrontAmount(team, myLane, false) > pulledPushed[team][myLane][2] then
		lane_state[myLane] = 1
	end
	if GetLaneFrontAmount(team, myLane, false) < pulledPushed[team][myLane][1] then
		lane_state[myLane] = 0
	end

	if lane_state[myLane] == 0 or percentHealth < 0.5 or npcBot:DistanceFromFountain() == 0 or npcBot:HasModifier("modifier_flask_healing") then
		return false
	end

	if decided[pID] == nil or decided[pID] + 30 < DotaTime() then
		local pulledLane = false
		for lane,exist in pairs(gankable) do
			--and globalState.state.laneInfo[lane].numEnemies > 0 and globalState.state.laneInfo[lane].numAllies > 0
			if exist ~= nil and GetLaneFrontAmount(team, lane, false) < pulledPushed[team][lane][1] then
				pulledLane = true
			end
		end
		if pulledLane == false then
			return false
		end
	end
	decided[pID] = DotaTime()
	return true
end

function GoGank(npcBot)
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
        }
    }
}

return gank_weight