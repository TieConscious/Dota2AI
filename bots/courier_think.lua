local courier_think = {}
local courier = nil

function courier_think.Decide()
	local npcBot = GetBot()
	if courier == nil then
		npcBot:ActionImmediate_PurchaseItem("item_courier")
		courier = GetCourier(0)
	end
	if npcBot:GetStashValue() == 0 then
		return
	end
	local courierState = GetCourierState(courier)
	if courierState == COURIER_STATE_IDLE or courierState == COURIER_STATE_AT_BASE then
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
	end
end

return courier_think