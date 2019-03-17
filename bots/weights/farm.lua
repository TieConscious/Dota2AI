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
	local nearbyECreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local nearbyACreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(nearbyACreeps)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if eWeakestCreep ~= nil then
		local health = module.PredictTiming(npcBot, eWeakestCreep, nearbyACreeps)
		if health > 0 and health <= eWeakestCreep:GetActualIncomingDamage(npcBot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
			return 50
		end
	end
	if aWeakestCreep ~= nil then
		local health = module.PredictTiming(npcBot, aWeakestCreep, nearbyECreeps)
		if health > 0 and health <= aWeakestCreep:GetActualIncomingDamage(npcBot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
			return 50
		end
	end
	return 0
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

function alone(npcBot)
    local nearbyCreeps = npcBot:GetNearbyLaneCreeps(searchRadius, true)
    local nearbyAllies = npcBot:GetNearbyHeroes(searchRadius, false, BOT_MODE_NONE)
    return nearbyCreeps ~= nil and #nearbyCreeps > 0 and #nearbyAllies == 1
end

function moreFarm(npcBot)
    return 100
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
<<<<<<< HEAD
            --{func=heroLevel, condition=enemyNotLevel, weight=10},
           	--{func=moreFarm, condition=alone, weight=5}
=======
            {func=heroLevel, condition=enemyNotLevel, weight=10},
            {func=moreFarm, condition=alone, weight=5}
>>>>>>> parent of 41499f0... wards work
        }
    }
}

return farm_weight