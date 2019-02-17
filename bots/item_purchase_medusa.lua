local module = require(GetScriptDirectory().."/helpers")

local Items = {
	----boots of strength----
	"item_belt_of_strength",
	"item_boots",
	"item_gloves",

	----mask of madness----
	"item_lifesteal",
	"item_quarterstaff",

	----manta style----
	"item_ultimate_orb",
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	"item_recipe_manta",

	----eye of skadi----
	"item_ultimate_orb",
	"item_ultimate_orb",
	"item_point_booster",

	----butterfly----
	"item_eagle",
	"item_talisman_of_evasion",
	"item_quarterstaff",

	----dragon lance----
	"item_boots_of_elves",
	"item_boots_of_elves",
	"item_ogre_axe"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end
