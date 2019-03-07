local module = require(GetScriptDirectory().."/helpers")
local consumable_think = {}
local bought_on = {}

function consumable_think.Decide()
	local npcBot = GetBot()
	local pID = npcBot:GetPlayerID()
	local team = GetTeam()
	local tower = nil
	local lane = nil

	lane = module.GetLane(npcBot)
	local front = GetLaneFrontLocation(team, lane, 0.0)
	local time = DotaTime()

	local tpScroll = npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"))
	if npcBot:DistanceFromFountain() == 0 and (tpScroll == nil or (time > 600 and tpScroll:GetCurrentCharges() < 2)) and npcBot:GetGold() >= GetItemCost("item_tpscroll") then
		npcBot:ActionImmediate_PurchaseItem("item_tpscroll")
	end
	local runTime = math.floor(DotaTime()) + 80
	if runTime <= 601 and bought_on[pID] ~= runTime and runTime % 300 == 0 then
		bought_on[pID] = runTime
		npcBot:ActionImmediate_PurchaseItem ("item_flask")
	end
	-- local pID = npcBot:GetPlayerID()
	-- local runTime = math.floor(DotaTime()) + 90
	-- if runTime <= 601 and bought_on[pID] ~= runTime and runTime % 300 == 0 then
	-- 	bought_on[pID] = runTime
	-- 	print(runTime)
	-- 	npcBot:ActionImmediate_PurchaseItem ("item_tango")
	-- end
end

return consumable_think