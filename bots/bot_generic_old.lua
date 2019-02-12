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

----Retreating function using 4 points on map to see where you are (imperfect if team fight)----
function Retreat(npcBot, retreatAmount)
	if (npcBot:GetTeam() == 3) then
		if (npcBot:GetPlayerID() == 7 or npcBot:GetPlayerID() == 8) then
			npcBot:Action_MoveDirectly(npcBot:GetLocation() + Vector(0, retreatAmount, 0))
		elseif (npcBot:GetPlayerID() == 9 or npcBot:GetPlayerID() == 10) then
			npcBot:Action_MoveDirectly(npcBot:GetLocation() + Vector(0, retreatAmount, 0))
		else
			npcBot:Action_MoveDirectly(npcBot:GetLocation() + Vector(retreatAmount, retreatAmount, 0))
		end
	else
		if (npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 3) then
			npcBot:Action_MoveDirectly(npcBot:GetLocation() - Vector(0, retreatAmount, 0))
		elseif (npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6) then
			npcBot:Action_MoveDirectly(npcBot:GetLocation() - Vector(0, retreatAmount, 0))
		else
			npcBot:Action_MoveDirectly(npcBot:GetLocation() - Vector(retreatAmount, retreatAmount, 0))
		end
	end
end

----Move to lane at start of game----
function MoveToLane_Start(npcBot)
	--if Dire--
	if (npcBot:GetTeam() == 3) then
		if (npcBot:GetPlayerID() == 7 or npcBot:GetPlayerID() == 8) then
			npcBot:Action_AttackMove(DIRE_TTOWER1)
		elseif (npcBot:GetPlayerID() == 9 or npcBot:GetPlayerID() == 10) then
			npcBot:Action_AttackMove(DIRE_BTOWER1)
		else
			npcBot:Action_AttackMove(DIRE_MTOWER1)
		end
	--if Radiant--
	elseif (npcBot:GetTeam() == 2) then
		if (npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 3) then
			npcBot:Action_AttackMove(RADIANT_TTOWER1)
		elseif (npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6) then
			npcBot:Action_AttackMove(RADIANT_BTOWER1)
		else
			npcBot:Action_AttackMove(RADIANT_MTOWER1)
		end
	else
		npcBot:Action_AttackMove(MIDDLE_COORDS)
	end
end

----Move to lane to farm----
function MoveToLane_Farm(npcBot)
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 500)
	local RADIANT_TTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_TOP, 500)
	local RADIANT_BTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_BOT, 500)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 500)
	local DIRE_TTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_TOP, 500)
	local DIRE_BTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_BOT, 500)

	--if Dire--
	if (npcBot:GetTeam() == 3) then
		if (npcBot:GetPlayerID() == 7 or npcBot:GetPlayerID() == 8) then
			npcBot:Action_AttackMove(DIRE_TTOWER_FRONT)
		elseif (npcBot:GetPlayerID() == 9 or npcBot:GetPlayerID() == 10) then
			npcBot:Action_AttackMove(DIRE_BTOWER_FRONT)
		else
			npcBot:Action_AttackMove(DIRE_MTOWER_FRONT)
		end
	--if Radiant--
	elseif (npcBot:GetTeam() == 2) then
		if (npcBot:GetPlayerID() == 2 or npcBot:GetPlayerID() == 3) then
			npcBot:Action_AttackMove(RADIANT_TTOWER_FRONT)
		elseif (npcBot:GetPlayerID() == 5 or npcBot:GetPlayerID() == 6) then
			npcBot:Action_AttackMove(RADIANT_BTOWER_FRONT)
		else
			npcBot:Action_AttackMove(RADIANT_MTOWER_FRONT)
		end
	else
		npcBot:Action_AttackMove(MIDDLE_COORDS)
	end
end

----Get ready to end the game----
function MoveToLane_Final(npcBot)
	local RADIANT_MTOWER_FRONT = GetLaneFrontLocation(TEAM_RADIANT, LANE_MID, 500)

	local DIRE_MTOWER_FRONT = GetLaneFrontLocation(TEAM_DIRE, LANE_MID, 500)

	--if Dire--
	if (npcBot:GetTeam() == 3) then
		npcBot:Action_AttackMove(DIRE_MTOWER_FRONT)
	--if Radiant--
	elseif (npcBot:GetTeam() == 2) then
		npcBot:Action_AttackMove(RADIANT_MTOWER_FRONT)
	else
		npcBot:Action_AttackMove(MIDDLE_COORDS)
	end
end

----Get the fuck out----
function BTFO(npcBot)
	if (npcBot:GetTeam() == 3) then
		npcBot:Action_MoveToLocation(DIRE_FOUNTAIN)
		return
	else
		npcBot:Action_MoveToLocation(RADIANT_FOUNTAIN)
		return
	end
end

function NumberOfPeeps(Table)
	local count = 0
	for _ in pairs(Table) do
		count = count + 1
	end
	return count
  end

function Think()
	----various Hero stats----
	local npcBot = GetBot()
	local GameTime = DotaTime()
	local Health = npcBot:GetHealth()
	local MaxHealth = npcBot:GetMaxHealth()
	local percentHealth = Health/MaxHealth
	local ARange = npcBot:GetAttackRange()
	----Enemy and Creep health stats----
	local creeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local WeakestCreep,CreepHealth = module.GetWeakestUnit(creeps)
	local numCreeps = NumberOfPeeps(creeps)

	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local numEHero = NumberOfPeeps(EHERO)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)



----if late game and tower is at 55%, minions are there, and other heroes are there smash the tower
----if only 1 enemy, dunk them
----if multiple, attack after stuns


----If no other actions, then move to lane (first 20 seconds)----
	if (GameTime <= 20) then
		if (WeakestCreep == nil and WeakestEHero == nil) then
			if (percentHealth == 1 and npcBot:NumQueuedActions() == 0) then
				MoveToLane_Start(npcBot)
				return
			end
		end
	end
	----"Early" gameplay----
	if (GameTime <= 1200) then
		----Back the fuck out----
		if (percentHealth <= 0.25) then
			BTFO(npcBot)
			return
		end
		--if () then
--
		--end
		----Retreat from tower damage---
		if (npcBot:WasRecentlyDamagedByTower(1)) then
			Retreat(npcBot, 300)
		elseif (npcBot:WasRecentlyDamagedByAnyHero(1)) then
			Retreat(npcBot, 100)
		elseif (npcBot:WasRecentlyDamagedByCreep(1)) then
			Retreat(npcBot, 50)
		end
		----If no other actions, move to beginning of farm----
		if (not npcBot:WasRecentlyDamagedByTower(1) and not npcBot:WasRecentlyDamagedByCreep(1) and not npcBot:WasRecentlyDamagedByAnyHero(1)) then
			MoveToLane_Farm(npcBot)
		end
		----Farm creeps----
		if (numCreeps > 0) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
				npcBot:Action_AttackUnit(WeakestCreep, true)
				return
			else
				npcBot:Action_MoveDirectly(WeakestCreep:GetLocation())
				npcBot:Action_AttackUnit(WeakestCreep, true )
				return
		end
		----Calculates weakest heroes percent health, and attacks if they're under the set percent----
		--if (percentHealth > 0.3 and EHero ~= 0) then
		--	--local WeakestPerHealth = EHeroHealth/WeakestEHero:GetMaxHealth()
		--	--local PowPerHealth = PowHealth/PowUnit:GetMaxHealth()
		--	--if (PowUnit:IsStunned()) then
		--	--	npcBot:ActionPush_AttackUnit(PowUnit, false)
		--	--elseif (WeakestPerHealth <= 0.4) then
		--	--	npcBot:ActionPush_AttackUnit(WeakestEHero, false)
		--	--elseif (PowPerHealth <= 0.4 ) then
		--	--	npcBot:ActionPush_AttackUnit(PowUnit, false)
		--	--else
		--	--	return
		--	--end
		--	npcBot:ActionPush_AttackUnit(WeakestEHero, false)
		--end
		------Last hit creep----
		--if (WeakestCreep ~= nil and percentHealth > 0.2) then
		--	if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
		--		npcBot:Action_AttackUnit(WeakestCreep, false)
		--	else
		--		npcBot:ActionPush_AttackUnit(WeakestCreep, false)
		--		npcBot:ActionPush_MoveToUnit(WeakestCreep)
		--		--if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
		--		--	npcBot:Action_AttackUnit(WeakestCreep, true)
		--		--end
		--	end
		--end

	end

	----Mid/Late gameplay----
	--if (GameTime > 1200) then
	--	----Move to location----
	--	if (GameTime <= 1260) then
	--		if (WeakestCreep == nil and npcBot:NumQueuedActions() <= 1) then
	--			npcBot:Action_MoveToLocation(MIDDLE_COORDS)
	--			return
	--		end
	--	end
	--	----Retreat from damage if health is low----
	--	if (percentHealth <= 0.2)
	--		BTFO(npcBot)
	--		return
	--	elseif (npcBot:WasRecentlyDamagedByTower(0.5) or npcBot:WasRecentlyDamagedByCreep(0.5) or npcBot:WasRecentlyDamagedByAnyHero(0.5)) then
	--		Retreat(npcBot)
	--		return
	--	end
	--	----If no other actions, move to beginning of farm----
	--	if (percentHealth >= 0.5 and npcBot:NumQueuedActions() <= 1) then
	--		MoveToLane_Final(npcBot)
	--	end
	--	----Calculates weakest heroes percent health, and attacks if they're under the set percent or attacks the most powerful stunned target----
	--	if (percentHealth > 0.2 and WeakestEHero ~= nil) then
	--		--local WeakestPerHealth = EHeroHealth/WeakestEHero:GetMaxHealth()
	--		----Attack the stunned most powerful unit----
	--		--if (PowUnit:IsStunned()) then
	--		--	npcBot:ActionPush_AttackUnit(PowUnit, false)
	--		----If the weakest unit is below 40% health----
	--		--if (WeakestPerHealth <= 0.4) then
	--			if (GetUnitToUnitDistance(npcBot,WeakestEHero) <= ARange) then
	--				npcBot:ActionPush_AttackUnit(WeakestEHero, false)
	--			else
	--				npcBot:ActionPush_AttackUnit(WeakestEHero, false)
	--				npcBot:ActionPush_MoveToUnit(WeakestEHero)
	--			end
	--		--end
	--	end
	--	----Last hit creep----
	--	if (WeakestCreep ~= nil and percentHealth > 0.2) then
	--		if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= ARange) then
	--			npcBot:Action_AttackUnit(WeakestCreep, false)
	--			return
	--		else
	--			npcBot:ActionPush_AttackMove(WeakestCreep:GetLocation())
	--			--npcBot:ActionPush_AttackUnit(WeakestCreep, false)
	--			--npcBot:ActionPush_MoveToUnit(WeakestCreep)
	--			--return
	--		end
	--	end
--
	end

end

function bot_generic.Think()
	Think()
end

return bot_generic

