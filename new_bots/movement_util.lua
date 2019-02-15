local module = require(GetScriptDirectory().."/helpers")

local movement = {}

----Radiant Locations----
RADIANT_FOUNTAIN = Vector(-6750 ,-6550, 512)

RADIANT_MTOWER1 = Vector(-1250, -1250, 512)
RADIANT_MTOWER1_FARM = Vector(-650, -650, 512)

RADIANT_TTOWER1 = Vector(-6202, 1831, 512)
RADIANT_TTOWER1_FARM = Vector(-5202, 831, 512)

RADIANT_BTOWER1 =  Vector(4896, -6140, 512)


----Dire Locations----
DIRE_FOUNTAIN = Vector(6780, 6124, 512)

DIRE_MTOWER1 = Vector(640, 500, 0)
DIRE_MTOWER1_FARM = Vector(0, 0, 0)

DIRE_TTOWER1 = Vector(-4714, 6016, 512)
DIRE_TTOWER1_FARM = Vector(-6200, 4500, 512)

DIRE_BTOWER1 = Vector(6215, -1639, 512)

----Retreat and Group Up Locations----
MIDDLE_COORDS = Vector(-400, -400, 1000)
PP = Vector(3500, 3500, 0)
NP = Vector(-3500, 3500, 0)
NN = Vector(-3500, -3500, 0)
PN = Vector(3500, -3500, 0)

----Function Pointers----
-- local GetLocation = npcBot.GetLocation
-- local MoveTo = npcBot.Action_MoveToLocation
-- local MoveDirectly = npcBot.Action_MoveDirectly
-- local AttackMove = npcBot.Action_AttackMove
-- local AttackUnit = npcBot.Action_AttackUnit

-- local AP_AttackUnit = npcBot.ActionPush_AttackUnit
-- local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit

-- local WRDByTower = npcBot.WasRecentlyDamagedByTower
-- local WRDByCreep = npcBot.WasRecentlyDamagedByCreep
-- local WRDByHero = npcBot.WasRecentlyDamagedByAnyHero

----Retreating function using 4 points on map to see where you are (imperfect if team fight)----
-- function Retreat(RetreatSpace)
--     npcBot = GetBot()
-- 	pID = npcBot:GetPlayerID()
-- 	team = npcBot:GetTeam()
-- 	if (team == 3) then
-- 		if (pID == 7 or pID == 8) then
-- 			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(0, RetreatSpace, 0))
-- 		elseif (pID == 9 or pID == 10) then
-- 			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(0, RetreatSpace, 0))
-- 		else
-- 			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(RetreatSpace, RetreatSpace, 0))
-- 		end
-- 		return
-- 	else
-- 		if (pID == 2 or pID == 3) then
-- 			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(0, RetreatSpace, 0))
-- 		elseif (pID == 5 or pID == 6) then
-- 			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(0, RetreatSpace, 0))
-- 		else
-- 			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(RetreatSpace, RetreatSpace, 0))
-- 		end
-- 		return
-- 	end
-- end

----Move to lane at start of game----
function movement.MTL_Start(npcBot)
	local pID = npcBot:GetPlayerID()
	local team = npcBot:GetTeam()
	--if Dire--
	if (team == 3) then
		if (pID == 7 or pID == 8) then
            npcBot:Action_MoveToLocation(DIRE_TTOWER1)
		elseif (pID == 9 or pID == 10) then
            npcBot:Action_MoveToLocation(DIRE_BTOWER1)
		elseif (pID == 11) then
            npcBot:Action_MoveToLocation(DIRE_MTOWER1)
		end
	--if Radiant--
	elseif (team == 2) then
		if (pID == 2 or pID == 3) then
            npcBot:Action_MoveToLocation(RADIANT_TTOWER1)
		elseif (pID == 4 or pID == 5) then
            npcBot:Action_MoveToLocation(RADIANT_BTOWER1)
		elseif (pID == 6) then
            npcBot:Action_MoveToLocation(RADIANT_MTOWER1)
		end
	else
		npcBot:Action_MoveToLocation(MIDDLE_COORDS)
    end
    return
end

----Move to lane to farm----
function movement.MTL_Farm(npcBot)
	local pID = npcBot:GetPlayerID()
	local team = npcBot:GetTeam()
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -10)
	local RADIANT_TTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_TOP, -10)
	local RADIANT_BTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, -10)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -10)
	local DIRE_TTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_TOP, -10)
	local DIRE_BTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_BOT, -10)

	--if Dire--
	if (team == 3) then
		if (pID == 7 or pID == 8) then
            npcBot:Action_MoveToLocation(DIRE_TTOWER_FRONT)
		elseif (pID == 9 or pID == 10) then
            npcBot:Action_MoveToLocation(DIRE_BTOWER_FRONT)
		elseif (pID == 11) then
            npcBot:Action_MoveToLocation(DIRE_MTOWER_FRONT)
		end
	--if Radiant--
	elseif (team == 2) then
		if (pID == 2 or pID == 3) then
            npcBot:Action_MoveToLocation(RADIANT_TTOWER_FRONT)
		elseif (pID == 4 or pID == 5) then
            npcBot:Action_MoveToLocation(RADIANT_BTOWER_FRONT)
		elseif (pID == 6) then
            npcBot:Action_MoveToLocation(RADIANT_MTOWER_FRONT)
		end
	else
		npcBot:Action_MoveToLocation(MIDDLE_COORDS)
    end
    return
end

----Get ready to end the game----
-- function MoveToLane_Final()
--     npcBot = GetBot()
-- 	pID = npcBot:GetPlayerID()
-- 	team = npcBot:GetTeam()
-- 	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 500)

-- 	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 500)

-- 	--if Dire--
-- 	if (team == 3) then
-- 		AttackMove(npcBot, DIRE_MTOWER_FRONT)
-- 	--if Radiant--
-- 	elseif (team == 2) then
-- 		AttackMove(npcBot, RADIANT_MTOWER_FRONT)
-- 	else
-- 		AttackMove(npcBot, MIDDLE_COORDS)
-- 	end
-- end

-- ----Back the fuck out----
-- function BTFO()
--     npcBot = GetBot()
-- 	pID = npcBot:GetPlayerID()
-- 	team = npcBot:GetTeam()
-- 	if (team == 3) then
-- 		MoveTo(npcBot, DIRE_FOUNTAIN)
-- 		return
-- 	else
-- 		MoveTo(npcBot, RADIANT_FOUNTAIN)
-- 		return
-- 	end
-- end

return movement
