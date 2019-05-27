local module = require(GetScriptDirectory().."/helpers")
local globalState = require(GetScriptDirectory().."/global_state")
local geneList = require(GetScriptDirectory().."/genes/gene")

local npcBot = GetBot()

-- function PowerRatioNoHunt(npcBot)
--     -- local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--     -- local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--     -- local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

--     -- return RemapValClamped(powerRatio, 0, 0.8 , 0, 100)
--     return 0
-- end

-- function EnemyPowerful(npcBot)
--     local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--     local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--     local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
--     if nearbyEnemy == nil or #nearbyEnemy == 0 or (powerRatio < geneList.GetWeight(npcBot:GetUnitName(), "highEnemyPowerRatio") / 100) then --0.8
--         return false
--     end
--     return true
-- end

-- function Fuckem(npcBot)
--     local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--     local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
-- 	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

-- 	if nearbyEnemy == nil or #nearbyEnemy == 0 then
-- 		return 0
-- 	end
--     return RemapValClamped(powerRatio, geneList.GetWeight(npcBot:GetUnitName(), "FuckMinRatio") / 100, geneList.GetWeight(npcBot:GetUnitName(), "FuckMaxRatio") / 100, 0, 100)
-- end

-- function EnemyWeak(npcBot)
--     local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--     local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--     local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
--     if nearbyEnemy == nil or #nearbyEnemy == 0 or (powerRatio >= 0) then
--         return false
--     end
--     return true
-- end

function CalcHyper(x, max_x, max_y, rate)
	return rate * (x - max_x)^2 / 2 + max_y
end

function enemyDistance(npcBot)
    local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if nearbyEnemy == nil or #nearbyEnemy == 0 then
        return 0
    end
	local attackRange = npcBot:GetAttackRange()

	if attackRange <= 150 then
		return RemapValClamped(GetUnitToUnitDistance(npcBot, nearbyEnemy[1]), 200, 600 , 100, 0)
	else
		local val = 100 * CalcHyper(GetUnitToUnitDistance(npcBot, nearbyEnemy[1]), attackRange * geneList.GetWeight(npcBot:GetUnitName(), "perfectAttackRange") / 100, 100, -0.01)
		return Clamp(val, 0, 100)
	end
    --return RemapValClamped(dist, 200, 600 , 100, 0)
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

    return RemapValClamped(perMana, 0.3, 0.8, 0, 100)
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


    return RemapValClamped(enemyPercHealth, 0.1, geneList.GetWeight(npcBot:GetUnitName(), "enemyHealthMax") / 100, 100, 0)
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

-- function UnseenEnemyHealth(npcBot)
--     local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--     if nearbyEnemy == nil or #nearbyEnemy == 0 then
--         return 0
--     end
--     local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)
--     local enemyPercHealth =  module.CalcPerHealth(lowestEnemy)


--     return RemapValClamped(enemyPercHealth, 0.1, 0.6, 100, 0)
-- end

function weDisabled(npcBot)
    if (module.IsDisabled(npcBot)) then
        return true
    end
    return false
end

function zero(npcBot)
    return 0
end

function  onehundred(npcBot)
    return 100
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
---------------------------------
function HuntHealth(npcBot)
	return RemapValClamped(module.CalcPerHealth(npcBot), 0, 1,
		geneList.GetWeight(npcBot:GetUnitName(), "huntMinHealth") / 100.0,
		geneList.GetWeight(npcBot:GetUnitName(), "huntMaxHealth") / 100.0)
end

function HuntLevel(npcBot)
	return RemapValClamped(npcBot:GetLevel(), 1, 25,
	 	geneList.GetWeight(npcBot:GetUnitName(), "huntEarly") / 100.0,
		geneList.GetWeight(npcBot:GetUnitName(), "huntLate") / 100.0)
end

function PowerConsider(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	return RemapValClamped(module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy), -0.5, 0.5, 1.5, 0.5)
end

local teammateSearchRange = 1200
function TeammateComing(npcBot)
    if (module.TeammateComing(npcBot, teammateSearchRange)) then
        return geneList.GetWeight(npcBot:GetUnitName(), "huntTOTWMod") / 100
    else
        return 1
    end
end

local hunt_weight = {
    settings = {
        name = "hunt",

        components = {
            {func=enemyHealth, weight=geneList.GetWeight, weightName="enemyHealth"},
            {func=enemyDistance, weight=geneList.GetWeight, weightName="enemyDistance"},
            --{func=Fuckem, weight=geneList.GetWeight, weightName="EnemyWeak"}

			--our health
            --our mana
        },

        conditionals = {
            {func=zero, condition=isUnderTower, weight=geneList.GetWeight, weightName="isUnderTower"}, --is this in retreat
            {func=zero, condition=weDisabled, weight=geneList.GetWeight, weightName="weDisabled"}, --should this be in retreat
            --{func=zero, condition=enemyOutlevels, weight=10},
            {func=HeroHealth, condition=eUnderTower, weight=geneList.GetWeight, weightName="eUnderTower"},
            --{func=HeroHealth, condition=eDissapeared, weight=20},

            --{func=numberCreeps, condition=enemyNear, weight=geneList.GetWeight, weightName="enemyNear"},
            --{func=heroMana, condition=enemyNear, weight=20},
            --{func=PowerRatioNoHunt, condition=EnemyPowerful, weight=geneList.GetWeight, weightName="EnemyPowerful"},
            --{func=Fuckem, condition=EnemyWeak, weight=geneList.GetWeight, weightName="EnemyWeak"},
            --{func=heroLevel, condition=enemyNearAndNotLevel, weight=geneList.GetWeight, weightName="enemyNearAndNotLevel"},
            {func=HeroHealth, condition=EnemyDisabled, weight=geneList.GetWeight, weightName="EnemyDisabled"},
            --{func=HeroHealth, condition=punchBack, weight=geneList.GetWeight, weightName="punchBack"},
            {func=onehundred, condition=allyInFight, weight=geneList.GetWeight, weightName="allyInFight"}
            --{func=heroMana, condition=under50ManaAndEnemyNear, weight=10}
            --{func=HeroHealth, condition=CanWeKillThem, weight=80}
        },
	
		multipliers = {
			{func=HuntHealth},
			{func=HuntLevel},
            {func=PowerConsider},
            {func=TeammateComing}
		}
    }
}


return hunt_weight