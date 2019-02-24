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

function heroMana(npcBot)
    local perMana = module.CalcPerMana(npcBot)
    --local mana = npcBot:GetMana()

    return RemapValClamped(perMana, 0.05, 0.5, 0, 100)
end

function under50ManaAndEnemyNear(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    return nearbyEnemy ~= nil and #nearbyEnemy > 0 and module.CalcPerMana(npcBot) < 0.5
end

function enemyHealth(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end
    local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)
    local enemyPercHealth =  module.CalcPerHealth(lowestEnemy)


    return RemapValClamped(enemyPercHealth, 0.1, 0.6, 100, 0)
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
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local eTower = npcBot:GetNearbyTowers(900, true)
	if #eTower == 0 or #nearbyEnemy == 0 then
		return false
	end
	local distRequired = math.min(GetUnitToUnitDistance(nearbyEnemy[1], npcBot), npcBot:GetAttackRange())
	local distToMove = GetUnitToUnitDistance(npcBot, nearbyEnemy[1]) - distRequired

	local calculation = nearbyEnemy[1]:GetLocation()
	local myLocation = npcBot:GetLocation()
		calculation = calculation - myLocation
		calculation = calculation / GetUnitToUnitDistance(npcBot, nearbyEnemy[1]) * distToMove
		calculation = calculation + myLocation
	local val = PointToLineDistance(npcBot:GetLocation(), calculation, eTower[1]:GetLocation())
	return 	PointToLineDistance(npcBot:GetLocation(), calculation, eTower[1]:GetLocation())["distance"] < 800
end

--function weUnderTower(npcBot)

function zero(npcBot)
    return 0
end

local hunt_weight = {
    settings = {
        name = "hunt",

        components = {
            {func=enemyHealth, weight=20},
            {func=powerRatio , weight=15},
            {func=enemyDistance , weight=12}
        },

        conditionals = {
            {func=zero, condition=isUnderTower, weight=35},
            {func=numberCreeps, condition=enemyNear, weight=4},
            {func=heroLevel, condition=enemyNearAndNotLevel, weight=30},
            {func=heroMana , condition=under50ManaAndEnemyNear, weight=6}
        }
    }
}

return hunt_weight