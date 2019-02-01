local module = {}

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

	if (#Items == 0) then
		return
	end

	local list = Items[1]

	if (npcBot:GetGold() >= GetItemCost(list)) then
		if (IsItemPurchasedFromSecretShop(list) == true and npcBot:DistanceFromSecretShop() < 10000) then
			--Finds which Secret Shop is closer and goes towards the nearest
			if (GetUnitToLocationDistance(npcBot, SS1) <= GetUnitToLocationDistance(npcBot, SS2)) then
				npcBot:ActionImmediate_Chat("Wanna go to the Secret Shop 1", true)
				npcBot:Action_MoveDirectly(SS1)
			else
				npcBot:ActionImmediate_Chat("Wanna go to the Secret Shop 2", true)
				npcBot:Action_MoveDirectly(SS2)
			end
		end
		PurchaseResult = npcBot:ActionImmediate_PurchaseItem(list)
		--Confirm whether the item was purchase, then remove from table
		if (PurchaseResult == PURCHASE_ITEM_SUCCESS) then
			table.remove(Items, 1)
			npcBot:ActionImmediate_Chat("Bought", true)
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
		npcBot:ActionImmediate_Chat("nil removed", true)
		return
	end

	local ability = npcBot:GetAbilityByName(ability_name)

	--If ability can be upgraded, upgrade appropriate ability
	if (ability:CanAbilityBeUpgraded() and npcBot:GetAbilityPoints() > 0) then
		print("Skill: "..ability_name.."  upgraded!")
		npcBot:ActionImmediate_LevelAbility(ability_name)
		npcBot:ActionImmediate_Chat("Upgraded Ability", true)
		table.remove(Ability, 1)
	end
end

return module