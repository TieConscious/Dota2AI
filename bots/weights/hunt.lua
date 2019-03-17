local module = require(GetScriptDirectory().."/helpers")
local globalState = require(GetScriptDirectory().."/global_state")

function PowerRatioNoHunt(npcBot)
    -- local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    -- local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    -- local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

    -- return RemapValClamped(powerRatio, 0, 0.8 , 0, 100)
    return 0
end

function EnemyPowerful(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
    if nearbyEnemy == nil or #nearbyEnemy == 0 or (powerRatio < 0.6) then --0.8
        return false
    end
    return true
end

function Fuckem(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
	if npcBot:GetUnitName() == "npc_dota_hero_bane" then
		print(powerRatio)
	end
    return RemapValClamped(powerRatio, 0, -1, 0, 100)
end

function EnemyWeak(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
    if nearbyEnemy == nil or #nearbyEnemy == 0 or (powerRatio >= 0) then
        return false
    end
    return true
end

function enemyDistance(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end

    local dist = GetUnitToUnitDistance(npcBot, nearbyEnemy[1])
    return RemapValClamped(dist, 200, 600 , 100, 0)
end

function enemyOutlevels(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local aLevel = 0
    local eLevel = 0

    if (nearbyEnemy == nil or #nearbyEnemy == 0) then
        return false
    end

    for _,unit in pairs(nearbyAlly) do
        if (unit ~= nil and unit:IsAlive()) then
            aLevel = aLevel + unit:GetLevel()
        end
    end

	for _,unit in pairs(nearbyEnemy) do
        if (unit ~= nil and unit:IsAlive()) then
            eLevel = eLevel + unit:GetLevel()
        end
	end

    ----Calculates the level of opponents to see if they're fightable or not
    local fightable = aLevel - (eLevel * 0.8)
    if (fightable <= 0) then
        return true
    end
    return false
end

function heroMana(npcBot)
    local perMana = module.CalcPerMana(npcBot)
    --local mana = npcBot:GetMana()

    return RemapValClamped(perMana, 0.3, 0.8, 0, 20)
end

function under50ManaAndEnemyNear(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if (nearbyEnemy ~= nil and #nearbyEnemy > 0) then
        local target = module.SmartTarget(npcBot)
        return module.CalcPerMana(target) < 0.5
    end

    return false
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
    local level = npcBot:GetLevel()
    local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
    if (level < 8) then
        return RemapValClamped(#nearbyEnemyCreeps, 0, 5, 50, 0)
    else
        return RemapValClamped(#nearbyEnemyCreeps, 0, 10, 50, 0)
    end
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
    return nearbyEnemy ~= nil and #nearbyEnemy > 0 and npcBot:GetLevel() < 6
end

function isUnderTower(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local eTower = npcBot:GetNearbyTowers(1600, true)
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
	return 	PointToLineDistance(npcBot:GetLocation(), calculation, eTower[1]:GetLocation())["distance"] < 950
end

function eUnderTower(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aTower = npcBot:GetNearbyTowers(1000, false)
	if #aTower == 0 or #nearbyEnemy == 0 then
		return false
    end

	dist = GetUnitToLocationDistance(nearbyEnemy[1], aTower[1]:GetLocation())
	if dist < 600 then

		return true
	end
	return false
end
 ----stunned enemy

function EnemyDisabled(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    if (#nearbyEnemy == 0) then
        return false
    end

    for _,unit in pairs(nearbyEnemy) do
        if (module.IsDisabled(unit)) then
           return true
        end
    end

    return false
end

function HeroHealth(npcBot)
    local perHealth = module.CalcPerHealth(npcBot)

    return RemapValClamped(perHealth, 0.2, 0.9, 0, 100)
end

function punchBack(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	if #nearbyEnemy ~= 0 and npcBot:WasRecentlyDamagedByAnyHero(0.25) then
		return true
	end
	return false
end

function allyInFight(npcBot)
    local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

    if (nearbyAlly ~= nil and #nearbyAlly > 1 and nearbyAlly[2]:GetAttackTarget() ~= nil
            and (nearbyAlly[2]:GetAttackTarget()):IsHero()) then
        return true
    end

    return false
end

--getlastseen and if time since they were seen is less than 1.5 try to stay in hunt based on our own health
--function eDissapeared(npcBot)
--    return GetHeroLastSeenInfo()
--end

function UnseenEnemyHealth(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end
    local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)
    local enemyPercHealth =  module.CalcPerHealth(lowestEnemy)


    return RemapValClamped(enemyPercHealth, 0.1, 0.6, 100, 0)
end

function weDisabled(npcBot)
    if (module.IsDisabled(npcBot)) then
        return true
    end
    return false
end

function zero(npcBot)
    return 0
end

function  forty(npcBot)
    return 40
end

function CanWeKillThem(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if (nearbyEnemy == nil or #nearbyEnemy == 0) then
        return false
    end

    local target = module.SmartTarget(npcBot)
	local targetHealth = target:GetHealth()
    return npcBot:GetEstimatedDamageToTarget(true, target, 3.0, DAMAGE_TYPE_ALL) >= targetHealth
end

local hunt_weight = {
    settings = {
        name = "hunt",

        components = {
            {func=enemyHealth, weight=30},
            --{func=enemyDistance, weight=12}
            --our health
            --our mana
        },

        conditionals = {
            {func=zero, condition=isUnderTower, weight=40}, --is this in retreat
            {func=zero, condition=weDisabled, weight=40}, --should this be in retreat
            --{func=zero, condition=enemyOutlevels, weight=10},
            {func=HeroHealth, condition=eUnderTower, weight=20},
            --{func=HeroHealth, condition=eDissapeared, weight=20},

            --{func=numberCreeps, condition=enemyNear, weight=4},
            {func=heroMana, condition=enemyNear, weight=20},
            {func=PowerRatioNoHunt, condition=EnemyPowerful, weight=20},
            {func=Fuckem, condition=EnemyWeak, weight=20},
            --{func=heroLevel, condition=enemyNearAndNotLevel, weight=20},
            {func=HeroHealth, condition=EnemyDisabled, weight=20},
            --{func=HeroHealth, condition=punchBack, weight=60},
            {func=forty, condition=allyInFight, weight=40},
            --{func=heroMana, condition=under50ManaAndEnemyNear, weight=10}
            {func=HeroHealth, condition=CanWeKillThem, weight=80}
        }
    }
}


return hunt_weight