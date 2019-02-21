local module = require(GetScriptDirectory().."/helpers")

local searchRadius = 1000
local hitConsider = 2.5
local moveDist = 300

function creepsAround(npcBot)
    local creepCount = 0
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(searchRadius, true)
    local nearbyACreeps = npcBot:GetNearbyLaneCreeps(searchRadius, false)

    if nearbyECreeps ~= nil then
        creepCount = creepCount + #nearbyECreeps
    end
    if nearbyACreeps ~= nil then
        creepCount = creepCount + #nearbyACreeps
    end

    return RemapValClamped(creepCount, 0, 3, 0, 100)
end

function calcEnemyCreepHealth(npcBot)
    local attackRange = npcBot:GetAttackRange()
    local attackDamage = npcBot:GetAttackDamage()
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(attackRange + moveDist, true)
    local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)

    if nearbyECreeps == nil or #nearbyECreeps == 0 then
        return 0
    end

    return RemapValClamped(eCreepHealth, attackDamage, attackDamage * hitConsider, 50, 0)
end

function calcEnemyCreepDist(npcBot)
    local attackRange = npcBot:GetAttackRange()
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(attackRange + moveDist, true)
    local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)
    local eCreepDist = GetUnitToUnitDistance(npcBot, eWeakestCreep)
    
    --if creeps are dead, they are not close
    if nearbyECreeps == nil or #nearbyECreeps == 0 then
        eCreepDist = 100000
    end

    return RemapValClamped(eCreepDist - attackRange, 0, moveDist, 50, 0)
end

function heroLevel(npcBot)
    local level = npcBot:GetLevel()
    return RemapValClamped(level, 1, 10, 60, 0)
end

function enemyNotLevel(npcBot)
    local nearbyCreeps = npcBot:GetNearbyLaneCreeps(searchRadius, true)
    return nearbyCreeps ~= nil and #nearbyCreeps > 0 and npcBot:GetLevel() < 10
end

local farm_weight = {
    settings =
    {
        name = "farm", 
    
        components = {
            {func=creepsAround, weight=2},
            {func=calcEnemyCreepHealth, weight=11},
            {func=calcEnemyCreepDist, weight=7}
        },
    
        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
            {func=heroLevel, condition=enemyNotLevel, weight=10}
        }
    }
}

return farm_weight