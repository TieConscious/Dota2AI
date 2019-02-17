local module = require(GetScriptDirectory().."/helpers")

local Items =
{
	----arcane boots----
	"item_boots",
	"item_energy_booster",

	----blink dagger----
	"item_blink"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end