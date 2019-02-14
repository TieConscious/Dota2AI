local module = require(GetScriptDirectory().."/functions")
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

local AP_AttackUnit = npcBot.ActionPush_AttackUnit
local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit

local WRDByTower = npcBot.WasRecentlyDamagedByTower
local WRDByCreep = npcBot.WasRecentlyDamagedByCreep
local WRDByHero = npcBot.WasRecentlyDamagedByAnyHero

----Retreating function using 4 points on map to see where you are (imperfect if team fight)----
function Retreat(RetreatSpace)
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(0, RetreatSpace, 0))
		elseif (pID == 9 or pID == 10) then
			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(0, RetreatSpace, 0))
		else
			MoveDirectly(npcBot, GetLocation(npcBot) + Vector(RetreatSpace, RetreatSpace, 0))
		end
		return
	else
		if (pID == 2 or pID == 3) then
			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(0, RetreatSpace, 0))
		elseif (pID == 5 or pID == 6) then
			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(0, RetreatSpace, 0))
		else
			MoveDirectly(npcBot, GetLocation(npcBot) - Vector(RetreatSpace, RetreatSpace, 0))
		end
		return
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
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 500)
	local RADIANT_TTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_TOP, 500)
	local RADIANT_BTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, 500)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 500)
	local DIRE_TTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_TOP, 500)
	local DIRE_BTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_BOT, 500)

	--if Dire--
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			AttackMove(npcBot, DIRE_TTOWER_FRONT)
		elseif (pID == 9 or pID == 10) then
			AttackMove(npcBot, DIRE_BTOWER_FRONT)
		elseif (pID == 11) then
			AttackMove(npcBot, DIRE_MTOWER_FRONT)
		end
	--if Radiant--
	elseif (team == 2) then
		if (pID == 2 or pID == 3) then
			AttackMove(npcBot, RADIANT_TTOWER_FRONT)
		elseif (pID == 4 or pID == 5) then
			AttackMove(npcBot, RADIANT_BTOWER_FRONT)
		elseif (pID == 6) then
			AttackMove(npcBot, RADIANT_MTOWER_FRONT)
		end
	else
		AttackMove(npcBot, MIDDLE_COORDS)
	end
end

----Get ready to end the game----
function MoveToLane_Final()
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 500)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 500)

	--if Dire--
	if (team == 3) then
		AttackMove(npcBot, DIRE_MTOWER_FRONT)
	--if Radiant--
	elseif (team == 2) then
		AttackMove(npcBot, RADIANT_MTOWER_FRONT)
	else
		AttackMove(npcBot, MIDDLE_COORDS)
	end
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

	----Enemy and Creep stats----
	local creeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local WeakestCreep,CreepHealth = module.GetWeakestUnit(creeps)

	local Alliedcreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local WeakestAllyCreep,AllyHealth = module.GetWeakestUnit(Alliedcreeps)

	local ETowers = npcBot:GetNearbyTowers(700, true)

	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)



----if late game and tower is at 55%, minions are there, and other heroes are there smash the tower
----if only 1 enemy, dunk them
----if multiple, attack after stuns


----If no other actions, then move to lane (first 20 seconds)----
	if (GameTime <= 20) then
		if (WeakestCreep == nil and WeakestEHero == nil) then
			if (percentHealth == 1 and npcBot:NumQueuedActions() == 0) then
				MoveToLane_Start()
				return
			end
		end
	end
	----"Early" gameplay----
	if (GameTime <= 1200) then
	----Back the fuck out----
		if (percentHealth <= 0.25) then
			BTFO()
			return
		end
	----Retreat from various damage----
		----Retreat from tower if too little ally creeps----
		if (#Alliedcreeps <= 1 and ETowers ~= nil and #ETowers > 0) then
			Retreat(270)
		end
		----Retreat from tower if damaged----
		if (WRDByTower(npcBot, 0.5)) then ----number of allies
			Retreat(270)
		----Fight creeps if health is above 30%----
		elseif (WRDByCreep(npcBot, 0.5) and percentHealth > 0.3) then
			if (#creeps > 4 and #Alliedcreeps <= 1) then
				Retreat(120)
			elseif ((ETowers == nil or #ETowers == 0) and #creeps <= 4) then
				AP_AttackUnit(npcBot, creeps[1], false)
				return
			end
		----Retreat from creeps if health is low----
		elseif (WRDByCreep(npcBot, 0.5) and percentHealth <= 0.3) then
			Retreat(120)
		----Retreat from Heroes----
		elseif (WRDByHero(npcBot, 0.5)) then
			Retreat(120)
		end
	----If no other actions, move to beginning of farm----
		if (WeakestEHero == nil) then
			if (percentHealth == 1 and npcBot:NumQueuedActions() <= 1) then
				MoveToLane_Farm()
			end
		end
	----Calculates weakest heroes percent health, and attacks if they're under the set percent----
		--if (percentHealth > 0.3 and EHero ~= nil and #EHero > 0 and #EHero < 3) then
		--	local WeakestPerHealth = EHeroHealth/WeakestEHero:GetMaxHealth()
		--	local PowPerHealth = PowHealth/PowUnit:GetMaxHealth()
		--	if (WeakestPerHealth <= 0.4) then
		--		AP_AttackUnit(npcBot, WeakestEHero, false)
		--	elseif (PowPerHealth <= 0.4 ) then
		--		AP_AttackUnit(npcBot, PowUnit, false)
		--	else
		--		return
		--	end
		--end
	----Last hit creep----
		if (WeakestCreep ~= nil and percentHealth > 0.2 and CreepHealth <= npcBot:GetAttackDamage() * 1.2) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
				AttackUnit(npcBot, WeakestCreep, false)
			else
				AttackUnit(npcBot, WeakestCreep, false)
				AP_MoveToUnit(npcBot, WeakestCreep)
			end
	----Deny creep----
		elseif (WeakestAllyCreep ~= nil and percentHealth > 0.2 and AllyHealth <= npcBot:GetAttackDamage()) then
			if (GetUnitToUnitDistance(npcBot,WeakestAllyCreep) <= ARange) then
				AttackUnit(npcBot, WeakestAllyCreep, false)
			end
	----Wack something----
		elseif (WeakestAllyCreep ~= nil and percentHealth > 0.2) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
				AP_AttackUnit(npcBot, WeakestCreep, true)
			else
				AP_AttackUnit(npcBot, WeakestCreep, true)
				AP_MoveToUnit(npcBot, WeakestCreep)
			end
		end
		--if (ETowers ~= nil) then
		--	Retreat(100)
		--end
	end

	----Mid/Late gameplay----
	if (GameTime > 1200) then
	----Move to location----
		if (GameTime <= 1260) then
			if (WeakestCreep == nil and npcBot:NumQueuedActions() <= 1) then
				MoveTo(npcBot, MIDDLE_COORDS)
				return
			end
		end
	----Retreat from damage if health is low----
		if (percentHealth <= 0.2 and (WRDByTower(npcBot, 0.5) or WRDByCreep(npcBot, 0.5) or WRDByHero(npcBot, 0.5))) then
			Retreat()
		end
	----If no other actions, move to beginning of farm----
		if (percentHealth >= 0.5 and npcBot:NumQueuedActions() <= 1) then
			MoveToLane_Final()
		end
	----Calculates weakest heroes percent health, and attacks if they're under the set percent or attacks the most powerful stunned target----
		if (percentHealth > 0.2 and WeakestEHero ~= nil) then
			local WeakestPerHealth = EHeroHealth/WeakestEHero:GetMaxHealth()
			----Attack the stunned most powerful unit----
			--if (PowUnit:IsStunned()) then
			--	AP_AttackUnit(npcBot, PowUnit, false)
			----If the weakest unit is below 40% health----
			if (WeakestPerHealth <= 0.4) then
				if (GetUnitToUnitDistance(npcBot,WeakestEHero) <= ARange) then
					AP_AttackUnit(npcBot, WeakestEHero, false)
				else
					AP_AttackUnit(npcBot, WeakestEHero, false)
					AP_MoveToUnit(npcBot, WeakestEHero)
				end
			end
		end
	----Last hit creep----
		if (WeakestCreep ~= nil and percentHealth > 0.2) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
				AttackUnit(npcBot, WeakestCreep, false)
				return
			else
				AP_AttackUnit(npcBot, WeakestCreep, false)
				AP_MoveToUnit(npcBot, WeakestCreep)
				return
			end
		end

	end

end

function bot_generic.Think()
	Think()
end

return bot_generic

