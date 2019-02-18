local module = require(GetScriptDirectory().."/helpers")

--components--
--health----------------------------------------------------------------------------
function lowHealth(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	--100 on 0.1, 70 on 0.7
 		return RemapValClamped(percentHealth, 0.1, 0.65, 100, 0)
end
--count-----------------------------------------------------------------------------
function numberDifference(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
	return  20 * #nearbyEnemy/(#nearbyAlly + 1)
end
--conditionals--
--tower-----------------------------------------------------------------------------
--do not calc if EnemyTower is actually targeting me. use function below for that
function willEnemyTowerTargetMe(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
	if #nearbyEnemyTowers ~= 0 and nearbyEnemyTowers[1]:GetAttackTarget() ~= npcBot then
		AcreepsInTowerRange = nearbyEnemyTowers[1]:GetNearbyLaneCreeps(700, false)
		if AcreepsInTowerRange ~= nil and #AcreepsInTowerRange < 3 then
			return true
		end
	end
	return false
end

function enemyTowerShallTargetMe(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
	local AcreepsInTowerRange = nearbyEnemyTowers[1]:GetNearbyLaneCreeps(700, false)
	return Clamp((3 - #AcreepsInTowerRange) * 60, 0, 100)
end
------------------------------------------------------------------------------------
function isEnemyTowerTargetingMe(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
	if npcBot:WasRecentlyDamagedByTower(1) or next(nearbyEnemyTowers) ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() == npcBot then
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
function hasEnemyCreepsNearbyLowLevel(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(500, true)
	if #nearbyEnemyCreeps ~= 0 and npcBot:GetLevel() < 7 then
		return true
	end
	return false
end

function considerEenmyCreepHits(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(500, true)
	local creepsTargetingMe = {}
	for _,creep in pairs(nearbyEnemyCreeps) do
		if creep:GetAttackTarget() == npcBot then
			table.insert(creepsTargetingMe, creep)
		end
	end
	return Clamp(30 * #creepsTargetingMe, 0, 100)
end
------------------------------------------------------------------------------------
local retreat_weight = {
    settings =
    {
        name = "retreat", 
    
        components = {
            {func=lowHealth, weight=4},
            {func=numberDifference, weight=0.5}
        },
    
        conditionals = {
			{func=enemyTowerShallTargetMe, condition=willEnemyTowerTargetMe, weight=7},
			{func=enemyTowerTargetingMe, condition=isEnemyTowerTargetingMe, weight=7},
			{func=considerPowerRatio, condition=hasPassiveEnemyNearby, weight=0.5},
			{func=considerPowerRatio, condition=hasAggressiveEnemyNearby,weight=4},
			{func=considerEenmyCreepHits, condition=hasEnemyCreepsNearbyLowLevel, weight=3}
		}
    }
}

return retreat_weight