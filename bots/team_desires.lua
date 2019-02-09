--local module = require(GetScriptDirectory().."/functions")

----------------------------------------------------------------------------------------------------

--function UpdatePushLaneDesires()
--
--	return { 0.0, 0.5, 1.0 };
--
--end

----------------------------------------------------------------------------------------------------

--function UpdateDefendLaneDesires()
--
--	return { 0.1, 0.2, 0.3 };
--
--end

----------------------------------------------------------------------------------------------------

--function UpdateFarmLaneDesires()
--	local npcBot = GetHero()
--	local creeps = npcBot:GetNearbyCreeps(5000, true)
--	local WeakestCreep, CreepHealth = module.GetWeakestUnit(creeps)
--	local desire = 0.0
--
--	if (GetUnitToUnitDistance(npcBot, WeakestCreep) <= 5000) then
--		if (CreepHealth <= npcBot:GetAttackDamage()) then
--			module.LastHit(WeakestCreep, CreepHealth, npcBot)
--			return {desire, desire, desire}
--		else
--			desire = 0.4
--			return {desire, desire, desire}
--		end
--	end
--end

----------------------------------------------------------------------------------------------------

--function UpdateRoamDesire()
--
--	return { 0.5, 0.7, 0.9 };
--
--end

----------------------------------------------------------------------------------------------------

--function UpdateRoshanDesire()
--
--	return 0.8;
--
--end

----------------------------------------------------------------------------------------------------
