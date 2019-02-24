local module = require(GetScriptDirectory().."/helpers")
local consumable_think = {}
local bought_on = {}

function consumable_think.Decide()
	local npcBot = GetBot()
	local pID = npcBot:GetPlayerID()
	local team = GetTeam()
	local tower = nil
	local lane = nil
	if (pID == 7 or pID == 8 or pID == 2 or pID == 3) then
		lane = LANE_TOP
		tower = GetTower(team, TOWER_TOP_1)
	elseif (pID == 9 or pID == 10 or pID == 4 or pID == 5) then
		lane = LANE_BOT
		tower = GetTower(team, TOWER_BOT_1)
	elseif (pID == 11 or pID == 6) then
		lane = LANE_MID
		tower = GetTower(team, TOWER_MID_1)
	end

	local front = GetLaneFrontLocation(team, lane, 0)
	local time = DotaTime()

	local tpScroll = npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"))
	if npcBot:DistanceFromFountain() == 0 and tpScroll == nil and npcBot:GetGold() >= GetItemCost("item_tpscroll") then
		npcBot:ActionImmediate_PurchaseItem("item_tpscroll")
	end
	local runTime = math.floor(DotaTime()) + 90
	if runTime <= 601 and bought_on[pID] ~= runTime and runTime % 300 == 0 then
		bought_on[pID] = runTime
		print(runTime)
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