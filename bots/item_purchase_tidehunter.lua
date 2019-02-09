local module = require(GetScriptDirectory().."/functions")

local Items =
{
	"item_boots",
	"item_blink",
	"item_energy_booster"
}

function ItemPurchaseThink()
	module.ItemPurchase(Items)
end