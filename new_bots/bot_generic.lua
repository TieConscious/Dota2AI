local module = require(GetScriptDirectory().."/functions")
local bot_generic = {}

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
local howFar;

----Retreating function using 4 points on map to see where you are (imperfect if team fight)----
function Retreat(RetreatSpace)
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			howFar = RetreatSpace
			GeneratePath(npcBot:GetLocation(), DIRE_TTOWER1, GetAvoidanceZones(), module.completedPathFinding)
		elseif (pID == 9 or pID == 10) then
			howFar = RetreatSpace
			GeneratePath(npcBot:GetLocation(), DIRE_BTOWER1, GetAvoidanceZones(), module.completedPathFinding)
		else
			MoveDirectly(npcBot, npcBot:GetLocation() + Vector(RetreatSpace, RetreatSpace, 0))
		end
	else
		if (pID == 2 or pID == 3) then
			howFar = RetreatSpace
			GeneratePath(npcBot:GetLocation(), RADIANT_TTOWER1, GetAvoidanceZones(), module.completedPathFinding)
		elseif (pID == 4 or pID == 5) then
			howFar = RetreatSpace
			GeneratePath(npcBot:GetLocation(), RADIANT_BTOWER1, GetAvoidanceZones(), module.completedPathFinding)
		else
			MoveDirectly(npcBot, npcBot:GetLocation() - Vector(RetreatSpace, RetreatSpace, 0))
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
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, -250)
	local RADIANT_TTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_TOP, -250)
	local RADIANT_BTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, -250)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, -250)
	local DIRE_TTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_TOP, -250)
	local DIRE_BTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_BOT, -250)

	--if Dire--
	if (team == 3) then
		if (pID == 7 or pID == 8) then
			AP_MoveDirectly(npcBot, DIRE_TTOWER_FRONT)
		elseif (pID == 9 or pID == 10) then
			AP_MoveDirectly(npcBot, DIRE_BTOWER_FRONT)
		elseif (pID == 11) then
			AP_MoveDirectly(npcBot, DIRE_MTOWER_FRONT)
		end
	--if Radiant--
	elseif (team == 2) then
		if (pID == 2 or pID == 3) then
			AP_MoveDirectly(npcBot, RADIANT_TTOWER_FRONT)
		elseif (pID == 4 or pID == 5) then
			AP_MoveDirectly(npcBot, RADIANT_BTOWER_FRONT)
		elseif (pID == 6) then
			AP_MoveDirectly(npcBot, RADIANT_MTOWER_FRONT)
		end
	else
		AP_MoveDirectly(npcBot, MIDDLE_COORDS)
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

	local AllyTowers = npcBot:GetNearbyTowers(700, false)
	local ETowers = npcBot:GetNearbyTowers(700, true)

	----Enemy and Creep stats----
	local creeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local WeakestCreep,CreepHealth = module.GetWeakestUnit(creeps)

	local Alliedcreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local WeakestAllyCreep,AllyHealth = module.GetWeakestUnit(Alliedcreeps)

	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

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
		if (#Alliedcreeps == 0 and ETowers ~= nil and #ETowers > 0) then
			Retreat(350)
		end
		----Retreat from tower if damaged----
		if (WRDByTower(npcBot, 0.5)) then ----number of allies
			Retreat(350)
		----Fight creeps if health is above 30%----
		elseif (WRDByCreep(npcBot, 0.5) and percentHealth > 0.3) then
			if (#creeps > 4 and #Alliedcreeps <= 1) then
				Retreat(120)
			elseif ((ETowers == nil or #ETowers == 0) and #creeps <= 4) then
				if ((EHERO == nil or #EHERO == 0)) then
					AP_AttackUnit(npcBot, creeps[1], true)
				elseif (EHERO ~= nil) then
					Retreat(250)
				end
			end
		----Retreat from creeps if health is low----
		elseif (WRDByCreep(npcBot, 0.5) and percentHealth <= 0.3) then
			Retreat(120)
		----Retreat from Heroes----
        elseif (WRDByHero(npcBot, 0.5)) then
            Retreat(120)
        return
		end
	----If no other actions, move to beginning of farm----
		if (ETowers == nil or #ETowers == 0) then
			if (percentHealth == 1 and npcBot:NumQueuedActions() <= 1) then
				MoveToLane_Farm()
				return
			end
		end
	----Calculates weakest heroes percent health, and attacks if they're under the set percent----
		if (percentHealth > 0.3 and ETowers == nil and #ETowers == 0 and EHERO ~= nil and #EHERO > 0) then
			local FirstEHeroHealth = (EHERO[1]:GetHealth())/(EHERO[1]:GetMaxHealth())
			--local WeakestPerHealth = EHeroHealth/WeakestEHero:GetMaxHealth()
			--local PowPerHealth = PowHealth/PowUnit:GetMaxHealth()
			if (FirstEHeroHealth <= 0.5 and AllyTowers ~= nil and #AllyTowers > 0) then
				AP_AttackUnit(npcBot, EHERO[1], false)
			elseif (FirstEHeroHealth <= 0.3) then
				AP_AttackUnit(npcBot, EHERO[1], false)
			end
		end
	----Last hit creep----
		if (WeakestCreep ~= nil and percentHealth > 0.2 and CreepHealth <= npcBot:GetAttackDamage() * 1.2 and #Alliedcreeps >= 1) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
				AP_AttackUnit(npcBot, WeakestCreep, false)
			else
				AP_AttackUnit(npcBot, WeakestCreep, false)
				AP_MoveToUnit(npcBot, WeakestCreep)
			end
	----Deny creep----
		elseif (WeakestAllyCreep ~= nil and percentHealth > 0.2 and AllyHealth <= npcBot:GetAttackDamage()) then
			if (GetUnitToUnitDistance(npcBot,WeakestAllyCreep) <= ARange) then
				AP_AttackUnit(npcBot, WeakestAllyCreep, false)
			end
	----Wack something----
		--elseif (WeakestAllyCreep ~= nil and percentHealth > 0.2) then
		--	if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
		--		AP_AttackUnit(npcBot, creeps[1], true)
		--	else
		--		AP_AttackUnit(npcBot, creeps[1], true)
		--		AP_MoveToUnit(npcBot, creeps[1])
		--	end
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