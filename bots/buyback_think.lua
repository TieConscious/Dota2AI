local buyback_think = {}
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local globalState = require(GetScriptDirectory().."/global_state")

function buyback_think.Decide()
	local npcBot = GetBot()
	local gold = npcBot:GetGold()
	local defendLane = globalState.state.closestLane

	if (npcBot:IsAlive()) then
		return
	end

	if (npcBot:HasBuyback() and gold >= npcBot:GetBuybackCost() and globalState.state.enemiesInBase > 0
		and globalState.state.enemiesInBase >= globalState.state.alliesInBase) then
		npcBot:ActionImmediate_Buyback()
		npcBot:Action_MoveToLocation(GetLocationAlongLane(defendLane, 0.15))
	end
end

return buyback_think