local module = require(GetScriptDirectory().."/helpers")

function beTrue(npcBot)
    return true
end

local hitConsider = 2.5
local moveDist = 300


function calcEnemyCreepHealth(npcBot)
    local attackRange = npcBot:GetAttackRange()
    local attackDamage = npcBot:GetAttackDamage()
    local nearbyECreeps = npcBot:GetNearbyLaneCreeps(attackRange + moveDist, true)
    local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)

    return RemapValClamped(eCreepHealth, attackDamage, attackDamage * hitConsider, 100, 0)
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

    return RemapValClamped(eCreepDist - attackRange, 0, moveDist, 100, 0)
end

local farm_weight = {
    settings =
    {
        name = "farm", 
    
        components = {
            --{func=calcEnemies, weight=5},
            {func=calcEnemyCreepHealth, weight=5},
            {func=calcEnemyCreepDist, weight=3}
        },
    
        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
            --{func=findFarmWeight, condition=beTrue, weight=1}
        }
    }
}

return farm_weight