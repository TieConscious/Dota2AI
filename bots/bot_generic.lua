local module = require(GetScriptDirectory().."/helpers")
local bot_generic = {}

--["RadiantShop"]= Vector(-4739,1263),
--["DireShop"]= Vector(4559,-1554),
--["BotShop"]= Vector(7253,-4128),
--["TopShop"]= Vector(-7236,4444),
--
--["RadiantBase"]= Vector(-7200,-6666),
--["RBT1"]= Vector(4896,-6140),
--["RBT2"]= Vector(-128,-6244),
--["RBT3"]= Vector(-3966,-6110),
--["RMT1"]= Vector(-1663,-1510),
--["RMT2"]= Vector(-3559,-2783),
--["RMT3"]= Vector(-4647,-4135),
--["RTT1"]= Vector(-6202,1831),
--["RTT2"]= Vector(-6157,-860),
--["RTT3"]= Vector(-6591,-3397),
--["RadiantTopShrine"]= Vector(-4229,1299),
--["RadiantBotShrine"]= Vector(622,-2555),
--
--["DireBase"]= Vector(7137,6548),
--["DBT1"]= Vector(6215,-1639),
--["DBT2"]= Vector(6242,400),
--["DBT3"]= Vector(-6307,3043),
--["DMT1"]= Vector(1002,330),
--["DMT2"]= Vector(2477,2114),
--["DMT3"]= Vector(4197,3756),
--["DTT1"]= Vector(-4714,6016),
--["DTT2"]= Vector(0,6020),
--["DTT3"]= Vector(3512,5778),
--["DireTopShrine"]= Vector(-139,2533),
--["DireBotShrine"]= Vector(4173,-1613),

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

----Game Constants----
npcBot = GetBot()
pID = npcBot:GetPlayerID()
team = npcBot:GetTeam()

----Function Pointers----
local GetLocation = npcBot.GetLocation
local MoveTo = npcBot.Action_MoveToLocation
local MoveDirectly = npcBot.Action_MoveDirectly
local AttackMove = npcBot.Action_AttackMove
local AttackUnit = npcBot.Action_AttackUnit

local AP_MoveDirectly = npcBot.ActionPush_MoveDirectly
local AP_AttackUnit = npcBot.ActionPush_AttackUnit
local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit

local WRDByTower = npcBot.WasRecentlyDamagedByTower
local WRDByCreep = npcBot.WasRecentlyDamagedByCreep
local WRDByHero = npcBot.WasRecentlyDamagedByAnyHero

--local howFar = 0

--move only for that distance.
--function completedPathFinding(totalDistance, a, wayPointList)
--	moved = 0
--	estimatedPosition = npcBot:GetLocation()
--	npcBot:Action_ClearActions(true)
--	for _,location in pairs(wayPointList) do
--		--calculate distance to that way point.
--		vectorToLocation = location - estimatedPosition
--		distance = math.sqrt(math.pow(vectorToLocation[1], 2) + math.pow(vectorToLocation[2], 2) + math.pow(vectorToLocation[3], 2))
--		moved = moved + distance
--		if moved > howFar then
--			--get direction and multiply by distance left, move there
--			npcBot:ActionQueue_MoveToLocation(vectorToLocation / distance * (moved - howFar))
--			return
--		end
--		npcBot:ActionQueue_MoveToLocation(location)
--		estimatedPosition = location
--	end
--end

----Retreating function----
--function Retreat(RetreatSpace)
--	if (team == 3) then
--		if (pID == 7 or pID == 8) then
--			howFar = RetreatSpace
--			GeneratePath(npcBot:GetLocation(), DIRE_TTOWER1, GetAvoidanceZones(), completedPathFinding)
--		elseif (pID == 9 or pID == 10) then
--			howFar = RetreatSpace
--			GeneratePath(npcBot:GetLocation(), DIRE_BTOWER1, GetAvoidanceZones(), completedPathFinding)
--		else
--			MoveTo(npcBot, npcBot:GetLocation() + Vector(RetreatSpace, RetreatSpace, 0))
--		end
--	else
--		if (pID == 2 or pID == 3) then
--			howFar = RetreatSpace
--			GeneratePath(npcBot:GetLocation(), RADIANT_TTOWER1, GetAvoidanceZones(), completedPathFinding)
--		elseif (pID == 4 or pID == 5) then
--			howFar = RetreatSpace
--			GeneratePath(npcBot:GetLocation(), RADIANT_BTOWER1, GetAvoidanceZones(), completedPathFinding)
--		else
--			MoveTo(npcBot, npcBot:GetLocation() - Vector(RetreatSpace, RetreatSpace, 0))
--		end
--		return
--	end
--end



function Retreat(RetreatSpace)
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			MoveTo(npcBot, npcBot:GetLocation() + Vector(RetreatSpace, RetreatSpace, 0))
		elseif (pID == 9 or pID == 10) then
			MoveTo(npcBot, npcBot:GetLocation() + Vector(RetreatSpace, RetreatSpace, 0))
		else
			MoveTo(npcBot, npcBot:GetLocation() + Vector(RetreatSpace, RetreatSpace, 0))
		end
	else
		if (pID == 2 or pID == 3) then
			MoveTo(npcBot, npcBot:GetLocation() - Vector(RetreatSpace, RetreatSpace, 0))
		elseif (pID == 4 or pID == 5) then
			MoveTo(npcBot, npcBot:GetLocation() - Vector(RetreatSpace, RetreatSpace, 0))
		else
			MoveTo(npcBot, npcBot:GetLocation() - Vector(RetreatSpace, RetreatSpace, 0))
		end
	end
end

----Move to lane at start of game----
function MoveToLane_Start()
	--if Dire--
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			AttackMove(npcBot, DIRE_TTOWER1)
		elseif (pID == 9 or pID == 10) then
			AttackMove(npcBot, DIRE_BTOWER1)
		elseif (pID == 11) then
			AttackMove(npcBot, DIRE_MTOWER1)
		end
	--if Radiant--
	elseif (team == 2) then
		if (pID == 2 or pID == 3) then
			AttackMove(npcBot, RADIANT_TTOWER1)
		elseif (pID == 4 or pID == 5) then
			AttackMove(npcBot, RADIANT_BTOWER1)
		elseif (pID == 6) then
			AttackMove(npcBot, RADIANT_MTOWER1)
		end
	else
		AttackMove(npcBot, MIDDLE_COORDS)
	end
end

----Move to lane to farm----
function MoveToLane_Farm()
	local delta = 0

	if (npcBot:GetAttackRange() <= 200) then
		delta = -10
	else
		delta = -200
	end

	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, delta)
	local RADIANT_TTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_TOP, delta)
	local RADIANT_BTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, delta)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, delta)
	local DIRE_TTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_TOP, delta)
	local DIRE_BTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_BOT, delta)

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

function MoveToLane_Final()
	local delta = 0

	if (npcBot:GetAttackRange() <= 200) then
		delta = -10
	else
		delta = -200
	end

	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, delta)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, delta)

	if (team == 3) then
        AttackMove(npcBot, DIRE_MTOWER_FRONT)
	elseif (team == 2) then
       AttackMove(npcBot, RADIANT_MTOWER_FRONT)
    end
    return
end


----Back the fuck out----
function BTFO()
	if (team == 3) then
		MoveTo(npcBot, DIRE_FOUNTAIN)
		return
	else
		MoveTo(npcBot, RADIANT_FOUNTAIN)
		return
	end
end

--
--
--
--
--
--
--

function Think()
	npcBot = GetBot()
	pID = npcBot:GetPlayerID()
	team = npcBot:GetTeam()

	----various Hero stats----
	local GameTime = DotaTime()
	local Health = npcBot:GetHealth()
	local MaxHealth = npcBot:GetMaxHealth()
	local percentHealth = Health/MaxHealth
	local ARange = npcBot:GetAttackRange()

	local aTowers = npcBot:GetNearbyTowers(700, false)
	local eTowers = npcBot:GetNearbyTowers(1000, true)

	----Enemy and Creep stats----
	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	------Enemy and Creep stats----
	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(eCreeps)
	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(aCreeps)

----If no other actions, then move to lane (first 20 seconds)----
	if (GameTime <= 20) then
		if (WeakestCreep == nil and WeakestEHero == nil) then
			if (percentHealth == 1) then
				MoveToLane_Start()
				return
			end
		end
	end
	----"Early" gameplay----
	if (GameTime <= 900) then


	----Back the fuck out----
		if (percentHealth <= 0.25) then
			BTFO()
			return
		end

		if (percentHealth < 1 and npcBot:DistanceFromFountain() <= 500) then
			BTFO()
			return
		end


	----Retreat from various damage----
		----Retreat from tower if too little ally creeps----
		if (#aCreeps <= 1 and eTowers ~= nil and #eTowers > 0) then
			Retreat(350)
		end
		----Retreat from tower if damaged----
		if (WRDByTower(npcBot, 0.25)) then
			Retreat(350)
		----Retreat from creeps if health is low----
		elseif (WRDByCreep(npcBot, 0.25) and percentHealth <= 0.3 and GetUnitToUnitDistance(npcBot, eCreeps[1]) <= 100) then
			Retreat(120)
		----Retreat from Heroes----
		elseif (WRDByHero(npcBot, 0.25)) then
			Retreat(120)
		end



	----Last-hit Creep----
		if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 1.2) then
			if (eCreepHealth <= npcBot:GetAttackDamage()) then
				if (GetUnitToUnitDistance(npcBot,eWeakestCreep) <= ARange) then
					npcBot:ActionPush_AttackUnit(eWeakestCreep, true)
				else
					npcBot:ActionPush_AttackUnit(eWeakestCreep, true)
					npcBot:ActionPush_MoveToUnit(eWeakestCreep)
				end
			end
		----Deny creep----
		elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetAttackDamage()) then
			if (GetUnitToUnitDistance(npcBot, aWeakestCreep) <= ARange) then
				npcBot:ActionPush_AttackUnit(aWeakestCreep, true)
			end
		end
	----Wack nearest creep----
	--elseif (eCreeps[1] ~= nil) then
	--	if (GetUnitToUnitDistance(npcBot, eCreeps[1]) <= ARange) then
	--		npcBot:Action_AttackUnit(eCreeps[1], true)
	--	else
	--		npcBot:Action_AttackUnit(eCreeps[1], true)
	--		npcBot:ActionPush_MoveToUnit(eCreeps[1])
	--	end
		if (npcBot:NumQueuedActions() == 0) then
			MoveToLane_Farm()
		end

	end

	------Mid/Late gameplay----
	if (GameTime > 1000) then
	----Move to location----
		if (GameTime <= 1030) then
			MoveTo(npcBot, MIDDLE_COORDS)
		end

	----Get out----
		if (percentHealth <= 0.15) then
			BTFO()
			return
		end

		if (percentHealth < 1 and npcBot:DistanceFromFountain() <= 750) then
			BTFO()
			return
		end


	----Last-hit Creep----
		if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 1.2) then
			if (eCreepHealth <= npcBot:GetAttackDamage() or #aCreeps == 0) then
				if (GetUnitToUnitDistance(npcBot,eWeakestCreep) <= ARange) then
					npcBot:ActionPush_AttackUnit(eWeakestCreep, true)
				else
					npcBot:ActionPush_AttackUnit(eWeakestCreep, true)
					npcBot:ActionPush_MoveToUnit(eWeakestCreep)
				end
			end
		end


	----If no other actions, move to beginning of farm----
		if (npcBot:NumQueuedActions() == 0) then
			MoveToLane_Final()
		end

	end

end

function bot_generic.Think()
	Think()
end

return bot_generic

