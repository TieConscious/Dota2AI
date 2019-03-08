local buyback_think = {}
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local globalState = require(GetScriptDirectory().."/global_state")

function buyback_think.Decide()
	local npcBot = GetBot()
	local gold = npcBot:GetGold()
	--local nextItem = nil
	--if (buy_weight.itemTree[npcBot:GetUnitName()] == nil) then
	--	nextItem = require(GetScriptDirectory().."/item_purchase_generic")[1]
	--else
	--	nextItem = buy_weight.itemTree[npcBot:GetUnitName()][1]
	--end

	if (npcBot:IsAlive()) then
		return
	end

	if (npcBot:HasBuyback() and gold >= npcBot:GetBuybackCost() and globalState.state.enemiesInBase > 0
		and globalState.state.enemiesInBase >= globalState.state.alliesInBase) then
		npcBot:ActionImmediate_Buyback()
	end
end

return buyback_think