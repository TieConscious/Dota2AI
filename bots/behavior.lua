local movement = require(GetScriptDirectory().."/movement_util")
local module = require(GetScriptDirectory().."/helpers")
local buy_weight = require(GetScriptDirectory().."/weights/buy")

local behavior = {}

function behavior.generic(npcBot, stateMachine)
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
	elseif stateMachine.state == "Deaggro" then
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
		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= attackRange + (eTowers[1]:GetBoundingRadius() / 2)) then
			npcBot:Action_AttackUnit(eTowers[1], false)
		else
			npcBot:Action_MoveToUnit(eTowers[1])
		end
		return
	end

	local eBarracks = npcBot:GetNearbyBarracks(1600, true)
	if (eBarracks ~= nil and #eBarracks > 0) then
		if (GetUnitToUnitDistance(npcBot, eBarracks[1]) <= attackRange + (eBarracks[1]:GetBoundingRadius() / 2)) then
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
		if (GetUnitToUnitDistance(npcBot, eAncient) <= attackRange + (eAncient:GetBoundingRadius() / 2)) then
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
	if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 2.5) then
		if (eCreepHealth <= npcBot:GetAttackDamage() * 0.9 or #aCreeps == 0) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= attackRange) then
				npcBot:Action_AttackUnit(eWeakestCreep, false)
			else
				npcBot:Action_MoveToUnit(eWeakestCreep)
			end
		end
		if (GetUnitToUnitDistance(npcBot,WeakestCreep) > attackRange) then
			npcBot:Action_MoveToUnit(eWeakestCreep)
		end
	----Deny creep----
	elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetAttackDamage()) then
		if (GetUnitToUnitDistance(npcBot,aWeakestCreep) <= attackRange) then
			npcBot:Action_AttackUnit(aWeakestCreep, false)
		end
	----Wack nearest creep----
	elseif (eCreeps[1] ~= nil) then
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
	local nearbyETowers = npcBot:GetNearbyTowers(700, true)
	local AcreepsInRange = nearbyETowers[1]:GetNearbyLaneCreeps(700)
	local closestAcreep = nil
	local dist = 3000;

	for _,creep in pairs(AcreepsInRange) do
		if GetUnitToUnitDistance(npcBot, creep) < dist then
			dist = GetUnitToUnitDistance(npcBot, creep) < dist
			closestAcreep = creep
		end
	end

	if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK then
		if dist > attackRange then
			npcBot:Action_MoveToUnit(closestAcreep)
		else
			npcBot:Action_AttackUnit(closestAcreep)
		end
	end
end

return behavior
