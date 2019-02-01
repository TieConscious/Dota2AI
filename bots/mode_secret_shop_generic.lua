function GetDesire()

	local npcBot = GetBot();
	local desire = 0.0;
	local oGold = npcBot:GetGold()

	--if (npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
	--	return
	--end

	if (npcBot:DistanceFromSecretShop() < 10000 and npcBot:GetNextItemPurchaseValue() <= oGold and npcBot:GetNextItemPurchaseValue() ~= 0) then
	--if (npcBot:DistanceFromSecretShop() < 10000 and npcBot:GetNextItemPurchaseValue() <= oGold) then
		npcBot:ActionImmediate_Chat("GOGOGOGOGOGO", true)
		desire = 1.0
		if (oGold > npcBot:GetGold()) then
			npcBot:ActionImmediate_Chat("NONONONONONO", true)
			desire = 0.2
		end
	end

	return desire
end