local module = require(GetScriptDirectory().."/helpers")

function isSalveSafe(npcBot)
	local neededHealth = npcBot:GetMaxHealth() - npcBot:GetHealth()
	local nearbyEnemyHeroes = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(800, true)
	local salve = module.ItemSlot(npcBot, "item_flask")
	if npcBot:HasModifier("modifier_flask_healing") or (salve ~= nil and #nearbyEnemyHeroes == 0 and #nearbyEnemyTowers == 0 and
		neededHealth - npcBot:GetHealthRegen() * 10 - 400 > 0 and npcBot:DistanceFromFountain() > 4000) then
		return true
	end
	return false
end

function SalveWeight(npcBot)
	return 100
end

function isTangoSafe(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	local tango = module.ItemSlot(npcBot, "item_tango")
	local nearbyTrees = npcBot:GetNearbyTrees(1200)
	if tango ~= nil and nearbyTrees[1] ~= nil and GetUnitToLocationDistance(npcBot, GetTreeLocation(nearbyTrees[1])) < 400
		and not npcBot:HasModifier("modifier_tango_heal") and 0.4 < percentHealth and percentHealth < 0.9 then
		return true
	end
	return false
end

function TangoWeight(npcBot)
	return 70
end

local heal_weight = {
    settings =
    {
        name = "heal",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
			-- {func=TangoWeight, condition=isTangoSafe, weight=1},
			{func=SalveWeight, condition=isSalveSafe, weight=1}
        }
    }
}

return heal_weight