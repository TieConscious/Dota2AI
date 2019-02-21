local module = require(GetScriptDirectory().."/helpers")
local consumable_think = {}
local bought_on = {}

function consumable_think.Decide()
	local npcBot = GetBot()
	local pID = npcBot:GetPlayerID()
	local runTime = math.floor(DotaTime()) + 90
	if runTime <= 601 and bought_on[pID] ~= runTime and runTime % 300 == 0 then
		bought_on[pID] = runTime
		print(runTime)
		npcBot:ActionImmediate_PurchaseItem ("item_tango")
	end
end

return consumable_think