local buyback_think = {}
local buy_weight = require(GetScriptDirectory().."/weights/buy")

function buyback_think.Decide()
	local npcBot = GetBot()
	local gold = npcBot:GetGold()
	local nextItem = buy_weight.itemTree[npcBot:GetUnitName()][1]

	if (npcBot:IsAlive()) then
		return
	end

	if (nextItem == nil and npcBot:HasBuyback() and gold >= npcBot:GetBuybackCost()) then
		npcBot:ActionImmediate_Buyback()
	end
end

return buyback_think