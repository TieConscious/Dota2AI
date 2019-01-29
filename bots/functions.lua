local module = {}

function module.ItemPurchase(Items)
	local npcBot = GetBot()

	if (#Items == 0) then
		return
	end

	local list = Items[1]

	if (npcBot:GetGold() >= GetItemCost(list)) then
		npcBot:ActionImmediate_PurchaseItem(list)
		table.remove(Items, 1)
	end
end

return module