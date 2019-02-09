firstBuyItems = {
	["orb"] = "item_orb_of_venom",
	["branch0"] = "item_branches"
}

function ItemPurchaseThink()
	local npcBot = GetBot()

	if (GetGameState() == 4) then
		firstbuy()
	else
		earlyGameBuy()
	end
end

function earlyGameBuy()
	local npcBot = GetBot()

	if npcBot:GetGold() >= 600 then
		npcBot:ActionImmediate_PurchaseItem("item_boots")
	end
end

function firstbuy()
	local npcBot = GetBot()
	for _, item in pairs(firstBuyItems) do
		npcBot:ActionImmediate_PurchaseItem(item)
	end
end


--function ItemPurchaseThink()
--	local npcBot = GetBot()
--
--	if (#Items == 0) then
--		return
--	end
--
--	local list = Items[1]
--
--	if (npcBot:GetGold() >= GetItemCost(list)) then
--		npcBot:ActionImmediate_PurchaseItem(list)
--		table.remove(Items, 1)
--	end
--end