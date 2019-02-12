local module = require(GetScriptDirectory().."/functions")

local Items = {
	"item_quelling_blade",
	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_recipe_bfury",

	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_quelling_blade",
	"item_recipe_bfury",

	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_quelling_blade",
	"item_recipe_bfury",

	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_quelling_blade",
	"item_recipe_bfury",

	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_quelling_blade",
	"item_recipe_bfury",

	"item_ring_of_health",
	"item_void_stone",
	"item_demon_edge",
	"item_quelling_blade",
	"item_recipe_bfury"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end
