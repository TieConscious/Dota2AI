Items = {
	"item_quelling_blade",
	"item_tango"
}

function ItemPurchaseThink()
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