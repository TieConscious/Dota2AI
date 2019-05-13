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

-----------------------------------------------------------------------

function isShrineSafe(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	local time = DotaTime()
	if time < 0 then
		time = 0
	end
	time = math.floor(time / 60)
	local neededHealth = npcBot:GetMaxHealth() - npcBot:GetHealth()
	local nearbyEnemyHeroes = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(800, true)
	local possibleRegen = math.min(495 + 0.11 * npcBot:GetMaxHealth(), (120 + 2 * time) * 5)
	local closestShrine = nil

	local shrine1 = GetShrine(GetTeam(), SHRINE_JUNGLE_1)
	local shrine2 = GetShrine(GetTeam(), SHRINE_JUNGLE_2)
	if (shrine1 == nil) then
		if (shrine2 == nil) then
			return false
		end
		closestShrine = shrine2
	elseif (shrine2 == nil) then
		closestShrine = shrine1
	else
		if (GetUnitToUnitDistance(npcBot, shrine1) < GetUnitToUnitDistance(npcBot, shrine2)) then
			closestShrine = shrine1
		else
			closestShrine = shrine2
		end
	end
	if #nearbyEnemyHeroes == 0 and #nearbyEnemyTowers == 0 and
		(neededHealth - npcBot:GetHealthRegen() * 5 - possibleRegen > 0 and GetUnitToUnitDistance(npcBot, closestShrine) < 3000 and GetShrineCooldown(closestShrine) == 0 or
		(IsShrineHealing(closestShrine) and GetUnitToUnitDistance(npcBot, closestShrine) < 500)) then
		return true
	end
	return false
end

function ShrineWeight(npcBot)
	return 100
end
-----------------------------------------------------------------------

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
			{func=SalveWeight, condition=isSalveSafe, weight=1},
			{func=ShrineWeight, condition=isShrineSafe, weight=1}
        },
	
		multipliers = {
		}
    }
}

return heal_weight