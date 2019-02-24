local module = require(GetScriptDirectory().."/helpers")

--components--
--health----------------------------------------------------------------------------
function lowHealth(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	--100 on 0.1, 70 on 0.7
		return 100 * Clamp(1.747 * math.exp(-2*percentHealth) - 0.431, 0, 100)
end
--count-----------------------------------------------------------------------------
function numberDifference(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
	return  10 * #nearbyEnemy/(#nearbyAlly)
end
--conditionals--
--tower-----------------------------------------------------------------------------
--do not calc if EnemyTower is actually targeting me. use function below for that
function willEnemyTowerTargetMe(npcBot)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 850)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(850, true)
	if #ACreepsInTowerRange < 3 and
		not npcBot:WasRecentlyDamagedByTower(0.5) and nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() ~= npcBot then
		return true
	end
	return false
end

function enemyTowerShallTargetMe(npcBot)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 850)
	return Clamp((3 - #ACreepsInTowerRange) * 60, 0, 100)
end
------------------------------------------------------------------------------------
function isEnemyTowerTargetingMeNoAlly(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 850)
	if #ACreepsInTowerRange == 0 and
		(npcBot:WasRecentlyDamagedByTower(0.5) or (nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() == npcBot)) then
		return true
	end
	return false
end

function enemyTowerTargetingMe(npcBot)
	return 100;
end
--powerRatio------------------------------------------------------------------------
function hasPassiveEnemyNearby(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	if #nearbyEnemy ~= 0 and not npcBot:WasRecentlyDamagedByAnyHero(0.5) then
		return true
	end
	return false
end

function hasAggressiveEnemyNearby(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	if #nearbyEnemy ~= 0 and npcBot:WasRecentlyDamagedByAnyHero(0.5) then
		return true
	end
	return false
end

function considerPowerRatio(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

	return Clamp(100 * (powerRatio * 2 - 1), 0, 100)
end
--enemyCreepsHittingMe--------------------------------------------------------------
function hasEnemyCreepsNearby(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(500, true)
	if #nearbyEnemyCreeps ~= 0 then
		return true
	end
	return false
end

function considerEnemyCreepHits(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(500, true)
	local creepsTargetingMe = {}
	for _,creep in pairs(nearbyEnemyCreeps) do
		if creep:GetAttackTarget() == npcBot then
			table.insert(creepsTargetingMe, creep)
		end
	end
	return Clamp(50 * #creepsTargetingMe, 0, 100)
end
------------------------------------------------------------------------------------
local retreat_weight = {
    settings =
    {
        name = "retreat",

        components = {
            {func=lowHealth, weight=6},
            {func=numberDifference, weight=0.5}
        },

        conditionals = {
			{func=enemyTowerShallTargetMe, condition=willEnemyTowerTargetMe, weight=4},
			{func=enemyTowerTargetingMe, condition=isEnemyTowerTargetingMeNoAlly, weight=5},
			{func=considerPowerRatio, condition=hasPassiveEnemyNearby, weight=0.5},
			{func=considerPowerRatio, condition=hasAggressiveEnemyNearby,weight=2},
			{func=considerEnemyCreepHits, condition=hasEnemyCreepsNearby, weight=3}
		}
    }
}

return retreat_weight