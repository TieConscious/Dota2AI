----Gives various utilities for bots (i.e. general item purchase instructions, etc.)

local utilityModule={}

--------------------------------------------------------------------------	ItemPurchase

--Sell Items
function utilityModule.SellExtraItem(ItemsToBuy)
	local npcBot=GetBot()
	local level=npcBot:GetLevel()

	if (utilityModule.IsItemSlotsFull())
	then
		if(GameTime()>6*60 or level>=6)
		then
			utilityModule.SellSpecifiedItem("item_faerie_fire")
			utilityModule.SellSpecifiedItem("item_tango")
			utilityModule.SellSpecifiedItem("item_clarity")
			utilityModule.SellSpecifiedItem("item_flask")
		end
		if(GameTime()>25*60 or level>=10)
		then
			utilityModule.SellSpecifiedItem("item_stout_shield")
			utilityModule.SellSpecifiedItem("item_orb_of_venom")
			utilityModule.SellSpecifiedItem("item_enchanted_mango")
			--utilityModule.SellSpecifiedItem("item_poor_mans_shield")
		end
		if(GameTime()>35*60 or level>=15) then
			utilityModule.SellSpecifiedItem("item_branches")
			utilityModule.SellSpecifiedItem("item_bottle")
			utilityModule.SellSpecifiedItem("item_magic_wand")
			utilityModule.SellSpecifiedItem("item_magic_stick")
			utilityModule.SellSpecifiedItem("item_ancient_janggo")
			utilityModule.SellSpecifiedItem("item_ring_of_basilius")
			utilityModule.SellSpecifiedItem("item_ring_of_aquila")
			--utilityModule.SellSpecifiedItem("item_quelling_blade")
			utilityModule.SellSpecifiedItem("item_soul_ring")

		end
		if(GameTime()>40*60 or level>=20) then
			utilityModule.SellSpecifiedItem("item_vladmir")
			utilityModule.SellSpecifiedItem("item_urn_of_shadows")
			utilityModule.SellSpecifiedItem("item_drums_of_endurance")
			utilityModule.SellSpecifiedItem("item_hand_of_midas")
			utilityModule.SellSpecifiedItem("item_dust")
		end
	end
end

function utilityModule.ItemPurchase(ItemsToBuy)

	local npcBot = GetBot();

	if (DotaTime()<-80) then
		return;
	end

	if ( #ItemsToBuy == 0 ) then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = ItemsToBuy[1];

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) )

	utilityModule.SellExtraItem(ItemsToBuy)

	if(npcBot:DistanceFromFountain()<=2500 or npcBot:GetHealth()/npcBot:GetMaxHealth()<=0.35) then
		npcBot.secretShopMode = false;
		npcBot.sideShopMode = false;
	end

	if (IsItemPurchasedFromSideShop( sNextItem )==false and IsItemPurchasedFromSecretShop( sNextItem )==false) then
		npcBot.secretShopMode = false;
		npcBot.sideShopMode = false;
	end

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) ) then
		if(npcBot.secretShopMode~=true and npcBot.sideShopMode ~=true) then
			if (IsItemPurchasedFromSideShop( sNextItem ) and npcBot:DistanceFromSideShop() <= 1800) then
				npcBot.sideShopMode = true;
				npcBot.secretShopMode = false;
			end
			if (IsItemPurchasedFromSecretShop( sNextItem ) and sNextItem ~= "item_bottle") then
				npcBot.secretShopMode = true;
				npcBot.sideShopMode = false;
			end
		end

		local PurchaseResult=-2		--???????????????????

		if(npcBot.sideShopMode == true) then
			if(npcBot:DistanceFromSideShop() <= 250) then
				PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
			end

		elseif(npcBot.secretShopMode == true) then
			if(npcBot:DistanceFromSecretShop() <= 250) then
				PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
			end

		else
			PurchaseResult=npcBot:ActionImmediate_PurchaseItem( sNextItem )
		end

		if(PurchaseResult==PURCHASE_ITEM_SUCCESS) then
			npcBot.secretShopMode = false;
			npcBot.sideShopMode = false;
			table.remove( ItemsToBuy, 1 )
		end
		if(PurchaseResult==PURCHASE_ITEM_OUT_OF_STOCK) then
			utilityModule.SellSpecifiedItem("item_dust")
			utilityModule.SellSpecifiedItem("item_faerie_fire")
			utilityModule.SellSpecifiedItem("item_tango")
			utilityModule.SellSpecifiedItem("item_clarity")
			utilityModule.SellSpecifiedItem("item_flask")
		end
		if(PurchaseResult==PURCHASE_ITEM_INVALID_ITEM_NAME or PurchaseResult==PURCHASE_ITEM_DISALLOWED_ITEM) then
			table.remove( ItemsToBuy, 1 )
		end
		if(PurchaseResult==PURCHASE_ITEM_INSUFFICIENT_GOLD ) then
			npcBot.secretShopMode = false;
			npcBot.sideShopMode = false;
		end
		if(PurchaseResult==PURCHASE_ITEM_NOT_AT_SECRET_SHOP) then
			npcBot.secretShopMode = true
			npcBot.sideShopMode = false;
		end
		if(PurchaseResult==PURCHASE_ITEM_NOT_AT_SIDE_SHOP) then
			npcBot.sideShopMode = true
			npcBot.secretShopMode = false;
		end
		if(PurchaseResult==PURCHASE_ITEM_NOT_AT_HOME_SHOP) then
			npcBot.secretShopMode = false;
			npcBot.sideShopMode = false;
		end
		if(PurchaseResult>=-1) then
			print(npcBot:GetPlayerID().."[ItemPurchase] purchaseResult is"..PurchaseResult)
		end
	else
		npcBot.secretShopMode = false;
		npcBot.sideShopMode = false;
	end

end

function utilityModule.SellSpecifiedItem( item_name )

	local npcBot = GetBot();

	local itemCount = 0;
	local item = nil;

	for i = 0, 14
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil )
		then
			itemCount = itemCount + 1;
			if ( sCurItem:GetName() == item_name )
			then
				item = sCurItem;
			end
		end
	end

	if ( item ~= nil and itemCount > 5 and (npcBot:DistanceFromFountain() <= 600 or npcBot:DistanceFromSideShop() <= 200 or npcBot:DistanceFromSecretShop() <= 200) ) then
		npcBot:ActionImmediate_SellItem( item );
	end

end

function utilityModule.GetItemSlotsCount()
	local npcBot = GetBot();

	local itemCount = 0;

	for i = 0, 8
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if ( sCurItem ~= nil )
		then
			itemCount = itemCount + 1;
		end
	end

	return itemCount
end

function utilityModule.IsItemSlotsFull()
	local itemCount = utilityModule.GetItemSlotsCount();
	if(itemCount>=8)
	then
		return true
	else
		return false
	end
end

function utilityModule.checkItemBuild(ItemsToBuy)
	local ItemTableA=
	{
		"item_tango",
		"item_clarity",
		"item_faerie_fire",
		"item_enchanted_mango",
		"item_flask",
	}

	if(DotaTime()>0)
	then
		for _,item in pairs (ItemTableA)
		do
			for _1,item2 in pairs (ItemsToBuy)
			do
				if(item==item2)
				then
					table.remove(ItemsToBuy,_1)
				end
			end
		end

		local npcBot=GetBot()
		for _1,item2 in pairs (ItemsToBuy)
		do
			if(npcBot:FindItemSlot(item2)>0)
			then
				table.remove(ItemsToBuy,_1)
			end
		end
	end
end

-- function utilityModule.GetItemIncludeBackpack( item_name )

	-- local npcBot = GetBot();
	-- local item = nil;
	-- local i=-1
	-- i = npcBot:FindItemSlot(item_name)
	-- item = npcBot:GetItemInSlot(i)

	-- return item;
-- end

function utilityModule.GetItemIncludeBackpack(item_name)
	local npcBot=GetBot()
    for i = 0, 16 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

function utilityModule.IsItemAvailable(item_name)
    local npcBot = GetBot();

    for i = 0, 5, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

function utilityModule.CheckAbilityBuild(AbilityToLevelUp)
	local npcBot=GetBot()
	if #AbilityToLevelUp > 26-npcBot:GetLevel() then
		for i=1, npcBot:GetLevel() do
			print("remove"..AbilityToLevelUp[1])
			table.remove(AbilityToLevelUp, 1)
		end
	end
end

function utilityModule.DebugTalk(message)
	local debug_mode = false
	if(debug_mode==true)
	then
		local npcBot=GetBot()
		npcBot:ActionImmediate_Chat(message,true)
	end
end

function utilityModule.DebugTalk_Delay(message)

	local npcBot=GetBot()
	if(npcBot.LastSpeaktime==nil)
	then
		npcBot.LastSpeaktime=0
	end
	if(GameTime()-npcBot.LastSpeaktime>1)
	then
		npcBot:ActionImmediate_Chat(message,true)
		npcBot.LastSpeaktime=GameTime()
	end
end

---------------------------------------------------------------------------------------------------
return utilityModule;