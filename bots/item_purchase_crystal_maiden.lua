local module = require(GetScriptDirectory().."/helpers")

local Items = {
	"item_wind_lace",
	"item_boots",
	"item_ring_of_regen",

	"item_cloak",
	"item_shadow_amulet",

	"item_blink",

	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

	"item_ring_of_regen",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_mithril_hammer",
	"item_ogre_axe",
	"item_recipe_black_king_bar",

	--"item_mystic_staff",
	--"item_ultimate_orb",
	--"item_void_stone"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end
