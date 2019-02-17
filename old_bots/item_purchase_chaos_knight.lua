local module = require(GetScriptDirectory().."/helpers")

local Items = {
	----boots of strength----
	"item_belt_of_strength",
	"item_boots",
	"item_gloves",

	----echo sabre----
	"item_ogre_axe",
	"item_quarterstaff",
	"item_robe",
	"item_sobi_mask",

	----manta style----
	"item_ultimate_orb",
	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",
	"item_recipe_manta",

	----heart of tarrasque----
	"item_reaver",
	"item_vitality_booster",
	"item_ring_of_tarrasque",
	"item_recipe_heart"

}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end
