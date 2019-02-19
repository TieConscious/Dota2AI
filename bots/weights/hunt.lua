local module = require(GetScriptDirectory().."/helpers")

function powerRatio(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end
    return RemapValClamped(powerRatio, 1.2, 0.5 , 0, 100)
end

function enemyDistance(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end

    local dist = GetUnitToUnitDistance(npcBot, nearbyEnemy[1])
    return RemapValClamped(dist, 200, 600 , 100, 0)
end

function enemyHealth(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end
    local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)
    local enemyPercHealth =  module.CalcPerHealth(lowestEnemy)

    
    return RemapValClamped(enemyPercHealth, 0.1, 0.5 , 100, 0)
end

function numberCreeps(npcBot)
    local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
    return RemapValClamped(#nearbyEnemyCreeps, 0, 5 , 100, 0)
end

function heroLevel(npcBot)
    local level = npcBot:GetLevel()
    return RemapValClamped(level, 1, 6, 0, 50)
end

function enemyNear(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    return nearbyEnemy ~= nil and #nearbyEnemy > 0
end

function enemyNearAndNotLevel(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    return nearbyEnemy ~= nil and #nearbyEnemy > 0 and npcBot:GetLevel() < 7
end

function isUnderTower(npcBot)
    eTower = npcBot:GetNearbyTowers(750, true)
    return eTower ~= nil and #eTower > 0
end

function zero(npcBot)
    return 0
end

local hunt_weight = {
    settings =
    {
        name = "hunt", 
    
        components = {
            {func=enemyHealth, weight=10},
            {func=powerRatio , weight=9},
            {func=enemyDistance , weight=10}
        },
    
        conditionals = {
            {func=zero, condition=isUnderTower, weight=35},
            {func=numberCreeps, condition=enemyNear, weight=4},
            {func=heroLevel, condition=enemyNearAndNotLevel, weight=20}
        }
    }
}

return hunt_weight