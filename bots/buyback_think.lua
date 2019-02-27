local buyback_think = {}
local buy_weight = require(GetScriptDirectory().."/weights/buy")

function buyback_think.Decide()
	local npcBot = GetBot()
	local gold = npcBot:GetGold()
	if (buy_weight.itemTree[npcBot:GetUnitName()] == nil) then
		nextItem = require(GetScriptDirectory().."/item_purchase_generic")[1]
	else
		local nextItem = buy_weight.itemTree[npcBot:GetUnitName()][1]
	end

	if (npcBot:IsAlive()) then
		return
	end

	if (nextItem == nil and npcBot:HasBuyback() and gold >= npcBot:GetBuybackCost()) then
		npcBot:ActionImmediate_Buyback()
	end
end

return buyback_think