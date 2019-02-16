local module = require(GetScriptDirectory().."/helpers")

local Items =
{
	"item_boots",
	"item_energy_booster",
	"item_void_stone",
	"item_energy_booster",
	"item_recipe_aether_lens",

	"item_cloak",
	"item_shadow_amulet",

	"item_staff_of_wizardry",
	"item_void_stone",
	"item_recipe_cyclone",
	"item_wind_lace",

	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

	"item_mystic_staff",
	"item_ultimate_orb",
	"item_void_stone",
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end