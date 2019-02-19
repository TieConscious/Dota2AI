local module = {}


---- Function Pointers -----
local npcBot = GetBot()
local MoveDirectly = npcBot.Action_MoveDirectly
local AttackMove = npcBot.Action_AttackMove

----Item Purchasing Modules----

function module.ItemPurchase(Items)
	local PurchaseResult = -5
	local npcBot = GetBot()

	--If table is empty, don't do shit
	if (#Items == 0) then
		npcBot:SetNextItemPurchaseValue(0)
		return
	end

	npcBot:SetNextItemPurchaseValue(GetItemCost(list))

	--Gets location of both Secret Shops
	local SS1 = GetShopLocation(GetTeam(), SHOP_SECRET)
	local SS2 = GetShopLocation(GetTeam(), SHOP_SECRET2)

	local list = Items[1]

	if (npcBot:GetGold() >= GetItemCost(list)) then
		if (IsItemPurchasedFromSecretShop(list) == true) then
			--Finds which Secret Shop is closer and goes towards the nearest
			npcBot:ActionImmediate_Chat("Secret Shop", true)
			if (GetUnitToLocationDistance(npcBot, SS1) <= GetUnitToLocationDistance(npcBot, SS2)) then
				MoveDirectly(npcBot, SS1)
			else
				MoveDirectly(npcBot, SS2)
			end
		end

		PurchaseResult = npcBot:ActionImmediate_PurchaseItem(list)
		--Confirm whether the item was purchased, then remove from table
		if (PurchaseResult == PURCHASE_ITEM_SUCCESS) then
			table.remove(Items, 1)
			npcBot:ActionImmediate_Chat("Bought", true)
			return
		end
	end
end

----Ability Leveling Modules----
function module.AbilityLevelUp(Ability)
	local npcBot = GetBot()

	if (#Ability == 0) then
		return
	end

	--npcBot:ActionImmediate_Chat("nil removed", true)

	local ability_name = Ability[1]

	--If level up is "nil", delete nil
	if (ability_name == "nil") then
		table.remove(Ability, 1)
		--npcBot:ActionImmediate_Chat("nil removed", true)
		return
	end

	local ability = npcBot:GetAbilityByName(ability_name)

	--If ability can be upgraded, upgrade appropriate ability
	if (ability:CanAbilityBeUpgraded() and npcBot:GetAbilityPoints() > 0) then
		print("Skill: "..ability_name.."  upgraded!")
		npcBot:ActionImmediate_LevelAbility(ability_name)
		npcBot:ActionImmediate_Chat("Upgraded Ability", true)
		table.remove(Ability, 1)
		return
	end
end

----Caluclate total mana cost of a combo----
function module.CalcManaCombo(...)
	local sum = 0
    for k,v in pairs(...) do
        sum = sum + v
    end

    return sum
end

--use percent health as another ratio unit
----Calculate power ratios----
function module.CalcPowerRatio(npcBot, aHero, eHero)
	--GetOffensivePower calculates a more accurate power level of heroes, but is only usable on allies
	--GetRawOffensivePower calculates the "theoretical" power level of heroes

	local aPower = 0.0--npcBot:GetRawOffensivePower()
	local ePower = 0.0

	----Get power level of allied heroes----
	if (aHero ~= nil or #aHero ~= 0) then
		for _,unit in pairs(aHero) do
			if (unit ~= nil and unit:IsAlive()) then
				aPower = aPower + unit:GetRawOffensivePower()
			end
		end
	end

	----Get power level of enemy heroes----
	for _,unit in pairs(eHero) do
		if (unit ~= nil and unit:IsAlive()) then
			ePower = ePower + unit:GetRawOffensivePower()
		end
	end

	----Calculate power ratio----
	local powerRatio = ePower / aPower

	return powerRatio

end

--nearbyTower is only usable by heroes, doesn't work with creeps. vise versa.
----TowerRangeCreepSearch, order of distance to npcBot----
function module.GetAllyCreepInTowerRange(npcBot, searchRange)
	local nearbyAllyCreeps = npcBot:GetNearbyLaneCreeps(searchRange, false)
	local nearbyEnemyTower = npcBot:GetNearbyTowers(searchRange, true)[1]
	local empty = {}
	if nearbyEnemyTower == nil then
		return empty
	end
	for i,creep in pairs(nearbyAllyCreeps) do
		if GetUnitToUnitDistance(nearbyEnemyTower, creep) > 700 then
			nearbyAllyCreeps[i] = nil;
		end
	end
	local j=1
	local n=#nearbyAllyCreeps
	for i=1,n do
        if nearbyAllyCreeps[i]~=nil then
			nearbyAllyCreeps[j]=nearbyAllyCreeps[i]
			j=j+1
        end
	end
	for i=n,j,-1 do
			table.remove(nearbyAllyCreeps, i)
	end
	return nearbyAllyCreeps
end

----Calculate units percent health----
function module.CalcPerHealth(unit)
	local Health = unit:GetHealth()
	local MaxHealth = unit:GetMaxHealth()
	local percentHealth = Health/MaxHealth

	return percentHealth
end

----Calculate units percent mana----
function module.CalcPerMana(unit)
	local Mana = unit:GetMana()
	local MaxMana = unit:GetMaxMana()
	local percentMana = Mana/MaxMana

	return percentMana
end

----Assign castable item so it can be used----
function module.ItemSlot(npcBot, ItemName)
	local Slot = npcBot:FindItemSlot(ItemName)

	if (Slot >= 0 and Slot <= 5) then
		local Item = npcBot:GetItemInSlot(Slot)
		Slot = nil
		return Item
	end

	return nil
end

----Find weakest enemy unit (Creep or Hero) and their health----
function module.GetWeakestUnit(Enemy)
	if (Enemy == nil or #Enemy == 0) then
		return nil, 0
	end

	local WeakestUnit = Enemy[1]
	local LowestHealth = Enemy[1]:GetHealth()
	for _,unit in pairs(Enemy)
	do
		if (unit ~= nil and unit:IsAlive()) then
			if (unit:GetHealth() < LowestHealth) then
				LowestHealth = unit:GetHealth()
				WeakestUnit = unit
			end
		end
	end

	return WeakestUnit,LowestHealth
end

----Find theoretically most powerful unit (ally or enemy)----
function module.GetStrongestHero(Hero)
	if (Hero == nil or #Hero == 0) then
		return nil, 10000
	end

	local PowUnit = nil
	local PowHealth = 1
	local Power = 0.0
	for _,unit in pairs(Hero)
	do
		if (unit ~= nil and unit:IsAlive()) then
			if (unit:GetRawOffensivePower() > Power) then
				PowHealth = unit:GetHealth()
				PowUnit = unit
			end
		end
	end

	return PowUnit,PowHealth
end

----Last hit minions----
function module.lastHit(WeakestCreep, CreepHealth, npcBot)
	if (WeakestCreep ~= nil) then
		if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= 1500) then
			if (CreepHealth <= npcBot:GetAttackDamage()) then
				--if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= npcBot:GetAttackRange()) then
				--npcBot:Action_AttackUnit(WeakestCreep, false)
				--else
				npcBot:Action_MoveToUnit(WeakestCreep)
				--	npcBot:Action_AttackUnit(WeakestCreep)
				--end
			end
		end
	end
end

----Retreat Function----
function module.BTFO(npcBot)
	local Health = npcBot:GetHealth()
	local MaxHealth = npcBot:GetMaxHealth()
	local percentHealth = Health/MaxHealth

	RADIANT_FOUNTAIN = Vector(-6750 ,-6550, 512)
	DIRE_FOUNTAIN = Vector(6780, 6124, 512)

	if (percentHealth <= 0.9) then
		npcBot:ActionImmediate_Chat("RUN 1!!!", true)
		if (npcBot:GetTeam() == 3) then
			AttackMove(npcbot, DIRE_FOUNTAIN)
		else
			AttackMove(npcbot, RADIANT_FOUNTAIN)
		end
		npcBot:ActionImmediate_Chat("RUN 2!!!", true)
	end
end
----End of Functions----

return module
