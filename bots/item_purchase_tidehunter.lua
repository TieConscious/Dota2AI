local module = require(GetScriptDirectory().."/helpers")

local Items =
{
	"item_boots",
	"item_blink",
	"item_energy_booster"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end