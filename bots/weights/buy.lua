local module = require(GetScriptDirectory().."/helpers")

--compiled! but behavior is not defined.

--I don't know if we need to make a weight for normal items.
--How about dealing with only secretshop Items here and
--let the Item_purchase_generic do the work for the Normal Items.
--Since it happens immediately.

local buy_weight = {
	itemTree =
	{
		--['npc_dota_hero_tidehunter'] = require(GetScriptDirectory().."/item_purchase_tidehunter"),
		--['npc_dota_hero_chaos_knight'] = require(GetScriptDirectory().."/item_purchase_chaos_knight"),
		['npc_dota_hero_bane'] = require(GetScriptDirectory().."/item_purchase_bane"),
		--['npc_dota_hero_crystal_maiden'] = require(GetScriptDirectory().."/item_purchase_crystal_maiden"),
		--['npc_dota_hero_juggernaut'] = require(GetScriptDirectory().."/item_purchase_juggernaut"),
		['npc_dota_hero_medusa'] = require(GetScriptDirectory().."/item_purchase_medusa"),
		--['npc_dota_hero_phantom_assassin'] = require(GetScriptDirectory().."/item_purchase_phantom_assassin"),
		--['npc_dota_hero_abyssal_underlord'] = require(GetScriptDirectory().."/item_purchase_abyssal_underlord"),
		--['npc_dota_hero_pugna'] = require(GetScriptDirectory().."/item_purchase_generic"),
		--['npc_dota_hero_lich'] = require(GetScriptDirectory().."/item_purchase_lich"),
		--['npc_dota_hero_lion'] = require(GetScriptDirectory().."/item_purchase_lion"),
		--['npc_dota_hero_sven'] = require(GetScriptDirectory().."/item_purchase_generic"),
		--['npc_dota_hero_shadow_shaman'] = require(GetScriptDirectory().."/item_purchase_shadow_shaman"),
		--['npc_dota_hero_dazzle'] = require(GetScriptDirectory().."/item_purchase_generic"),
		--['npc_dota_hero_tinker'] = require(GetScriptDirectory().."/item_purchase_tinker"),
		['npc_dota_hero_jakiro'] = require(GetScriptDirectory().."/item_purchase_jakiro"),
		['npc_dota_hero_skeleton_king'] = require(GetScriptDirectory().."/item_purchase_skeleton_king"),
		--['npc_dota_hero_phantom_lancer'] = require(GetScriptDirectory().."/item_purchase_phantom_lancer"),
		['npc_dota_hero_ogre_magi'] = require(GetScriptDirectory().."/item_purchase_ogre_magi")
		--['npc_dota_hero_ursa'] = require(GetScriptDirectory().."/item_purchase_ursa"),
		--['npc_dota_hero_abyssal_underlord'] = require(GetScriptDirectory().."/item_purchase_abyssal_underlord")
	}
}

function isPurchaseableFromShop(npcBot)
	local nextItem = buy_weight.itemTree[npcBot:GetUnitName()]
	if nextItem ~= nil and next(nextItem) ~= nil and not IsItemPurchasedFromSecretShop(nextItem[1]) and npcBot:GetGold() >= GetItemCost(nextItem[1]) then
		return true
	end
	return false
end

function itemIsPurchaseable(npcBot)
	return 100;--since happens immediately. --but the problem is with the moving onto a new item.
				--Can each Files communicate?
end

function isPurchaseableFromSecretShop(npcBot)
	local nextItem = buy_weight.itemTree[npcBot:GetUnitName()]
	if nextItem ~= nil and next(nextItem) ~= nil and IsItemPurchasedFromSecretShop(nextItem[1]) and	npcBot:GetGold() >= GetItemCost(nextItem[1]) then
		return true
	end
	return false
end

function secretItemIsPurchaseable(npcBot)
	return  RemapValClamped(npcBot:DistanceFromSecretShop() , 0, 5000, 50, 0)
end

function TowerNearMe(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(850, true)
end

function zero()
	return 0
end

buy_weight.settings =
{
	name = "buy",

    components = {
		--{func=zero, condition=TowerNearMe, weight=0}
    },

    conditionals = {
		{func=itemIsPurchaseable, condition=isPurchaseableFromShop,weight=1},
		{func=secretItemIsPurchaseable, condition=isPurchaseableFromSecretShop, weight=1}
    }
}

return buy_weight