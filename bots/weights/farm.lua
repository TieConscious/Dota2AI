local module = require(GetScriptDirectory().."/helpers")
local geneList = require(GetScriptDirectory().."/genes/gene")

local npcBot = GetBot()
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
	local nearbyACreeps = npcBot:GetNearbyLaneCreeps(800, false)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(nearbyECreeps)
	local targetCount = 0

    if nearbyECreeps == nil or #nearbyECreeps == 0 then
        return 0
	end

	for k,v in pairs(nearbyACreeps) do
		if v:GetAttackTarget() == eWeakestCreep then
			targetCount = targetCount + 1
		end
	end
    return RemapValClamped(eCreepHealth, attackDamage, attackDamage * (1 + targetCount * 0.33), 50, 0)
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
            {func=creepsAround, weight=geneList.GetWeight, weightName="creepsAround"},
            {func=calcEnemyCreepHealth, weight=geneList.GetWeight, weightName="calcEnemyCreepHealth"},
            {func=calcEnemyCreepDist, weight=geneList.GetWeight, weightName="calcEnemyCreepDist"}
        },

        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
            {func=heroLevel, condition=enemyNotLevel, weight=geneList.GetWeight, weightName="enemyNotLevel"},
            {func=moreFarm, condition=alone, weight=geneList.GetWeight, weightName="alone"}
        }
    }
}

return farm_weight