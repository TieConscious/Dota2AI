local module = require(GetScriptDirectory().."/helpers")

local hitConsider = 2.5
local moveDist = 300

function creepsAround(npcBot)
    local creepCount = 0
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(1600, true)
    local nearbyACreeps = npcBot:GetNearbyLaneCreeps(1600, false)

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

    return RemapValClamped(eCreepHealth, attackDamage, attackDamage * hitConsider, 50, 0)
end

function calcEnemyCreepDist(npcBot)
    local attackRange = npcBot:GetAttackRange()
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(attackRange + moveDist, true)
    local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)
    local eCreepDist = GetUnitToUnitDistance(npcBot, eWeakestCreep)
    
    --if creeps are dead, they are not close
    if #nearbyECreeps == 0 then
        eCreepDist = 100000
    end

    return RemapValClamped(eCreepDist - attackRange, 0, moveDist, 50, 0)
end

local farm_weight = {
    settings =
    {
        name = "farm", 
    
        components = {
            --{func=calcEnemies, weight=5},
            {func=creepsAround, weight=2},
            {func=calcEnemyCreepHealth, weight=8},
            {func=calcEnemyCreepDist, weight=7}
        },
    
        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
            --{func=findFarmWeight, condition=beTrue, weight=1}
        }
    }
}

return farm_weight