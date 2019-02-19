local movement = require(GetScriptDirectory().."/movement_util")
local module = require(GetScriptDirectory().."/helpers")
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local courier_think = require(GetScriptDirectory().."/courier_think")
local behavior = {}

function behavior.generic(npcBot, stateMachine)
	courier_think.Decide()
	--run generic behavior based on state
	if stateMachine.state == "retreat" then
		Retreat()
	elseif stateMachine.state == "heal" then
		Heal()
	elseif  stateMachine.state == "hunt" then
		Hunt()
	elseif stateMachine.state == "tower" then
		Tower()
	elseif stateMachine.state == "farm" then
		Farm()
	elseif stateMachine.state == "buy" then
		Buy()
	elseif stateMachine.state == "deaggro" then
		Deaggro()
	else
		Farm()
	end
end

function Retreat()
	local npcBot = GetBot()
	movement.Retreat(npcBot)
end

function Heal()
	local npcBot = GetBot()
	movement.RetreatToBase(npcBot)
end

function Hunt()
	--Generic enemy hunting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eHeros = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if (eHeros ~= nil and #eHeros > 0) then
		if (GetUnitToUnitDistance(npcBot, eHeros[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eHeros[1], false)
		else
			npcBot:Action_MoveToUnit(eHeros[1])
		end
		return
	end
end

function Tower()
	--building fighting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eTowers = npcBot:GetNearbyTowers(1600, true)
	if (eTowers ~= nil and #eTowers > 0) then
		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= attackRange + (eTowers[1]:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eTowers[1], false)
		else
			npcBot:Action_MoveToUnit(eTowers[1])
		end
		return
	end

	local eBarracks = npcBot:GetNearbyBarracks(1600, true)
	if (eBarracks ~= nil and #eBarracks > 0) then
		if (GetUnitToUnitDistance(npcBot, eBarracks[1]) <= attackRange + (eBarracks[1]:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eBarracks[1], false)
		else
			npcBot:Action_MoveToUnit(eBarracks[1])
		end
		return
	end

	local eAncient 
	if npcBot:GetTeam() == 2 then
		eAncient = GetAncient(3)
	else
		eAncient = GetAncient(2)
	end
	if (eAncient ~= nil and GetUnitToUnitDistance(npcBot, eAncient) <= 1500) then
		if (GetUnitToUnitDistance(npcBot, eAncient) <= attackRange + (eAncient:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eAncient, false)
		else
			npcBot:Action_MoveToUnit(eAncient)
		end
		return
	end
	
end

function Farm()
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()
	------Enemy and Creep stats----
	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(eCreeps)
	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(aCreeps)


	----Last-hit Creep----
	if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 2) then
		if (eCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 1.1 or #aCreeps < 0) then --number of enemies in the future
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= attackRange) then
				npcBot:Action_AttackUnit(eWeakestCreep, true)
			else
				npcBot:Action_MoveToUnit(eWeakestCreep)
			end
		end
		if (GetUnitToUnitDistance(npcBot,WeakestCreep) > attackRange) then
			npcBot:Action_MoveToUnit(eWeakestCreep)
		end
	----Deny creep----
	elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) + 5) then
		if (GetUnitToUnitDistance(npcBot,aWeakestCreep) <= attackRange) then
			npcBot:Action_AttackUnit(aWeakestCreep, true)
		end
	----Push when no enemy heros around----
	elseif (eCreeps[1] ~= nil and npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ~= nil and #(npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)) == 0) then
		if (GetUnitToUnitDistance(npcBot, eCreeps[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eCreeps[1], true)
		else
			npcBot:Action_MoveToUnit(eCreeps[1])
		end
	 else
		movement.MTL_Farm(npcBot)
	end
end

function Buy()
	local npcBot = GetBot()
	local nextItem = buy_weight.itemTree[npcBot:GetUnitName()][1]
	local SS1 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET)
	local SS2 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET2)
	local closerSecretShop = nil
	if GetUnitToLocationDistance(npcBot, SS1) < GetUnitToLocationDistance(npcBot, SS2) then
		closerSecretShop = SS1
	else
		closerSecretShop = SS2
	end
	if IsItemPurchasedFromSecretShop(nextItem) then
		if npcBot:DistanceFromSecretShop() == 0 then
			npcBot:ActionImmediate_PurchaseItem(nextItem) 
			table.remove(buy_weight.itemTree[npcBot:GetUnitName()], 1)
		else
			npcBot:Action_MoveToLocation(closerSecretShop)
		end
	else
		npcBot:ActionImmediate_PurchaseItem(nextItem) 
		table.remove(buy_weight.itemTree[npcBot:GetUnitName()], 1)
	end
end

function Deaggro()
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 800)

	if GetUnitToUnitDistance(ACreepsInTowerRange[1], npcBot) > attackRange then
		npcBot:Action_MoveToUnit(ACreepsInTowerRange[1])
	else
		npcBot:Action_AttackUnit(ACreepsInTowerRange[1], true)
	end

end

return behavior
