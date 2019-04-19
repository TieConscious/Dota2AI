local module = require(GetScriptDirectory().."/helpers")
local geneList = require(GetScriptDirectory().."/genes/gene")

local npcBot = GetBot()
--components--
--count-----------------------------------------------------------------------------
function numberDifference(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE)
	return  10 * #nearbyEnemy/(#nearbyAlly)
end
--conditionals--
--health----------------------------------------------------------------------------
function lowHealth(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	--100 on 0.1, 70 on 0.7
	return 100 * Clamp(1.747 * math.exp(-2*percentHealth) - 0.431, 0, 100)
end

function hardRetreat(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	local level = npcBot:GetLevel()
	return npcBot:DistanceFromFountain() < 4000 or percentHealth < geneList.GetWeight(npcBot:GetUnitName(), "hardHealth") / 100
end

function lowHealthSoft(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	local enemyHero = npcBot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	--100 on 0.1, 70 on 0.7
	if #enemyHero == 0 then
		return 0
	else
		return 100 * Clamp(1.747 * math.exp(-2*percentHealth) - 0.431, 0, 100)
	end
end

function enemyRetreat(npcBot)
	local percentHealth = module.CalcPerHealth(npcBot)
	local level = npcBot:GetLevel()
	return not hardRetreat(npcBot)
end
--tower-----------------------------------------------------------------------------
--do not calc if EnemyTower is actually targeting me. use function below for that
function willEnemyTowerTargetMe(npcBot)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 1000)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
	if #ACreepsInTowerRange > 0 and #ACreepsInTowerRange <= 2 and
		not npcBot:WasRecentlyDamagedByTower(0.5) and nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() ~= npcBot then
		return true
	end
	return false
end

function enemyTowerShallTargetMe(npcBot)
	-- local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 950)
	-- return Clamp(ACreepsInTowerRange * 60, 100, 0)
	return 100
end
------------------------------------------------------------------------------------
function isEnemyTowerTargetingMeNoAlly(npcBot)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 1000)
	if #ACreepsInTowerRange == 0 and
		(npcBot:WasRecentlyDamagedByTower(0.5) or (nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() == npcBot)) then
		return true
	end
	return false
end

function enemyTowerTargetingMe(npcBot)
	return 100;
end
--powerRatio------------------------------------------------------------------------
function hasPassiveEnemyNearby(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
	if #nearbyEnemy ~= 0 and not npcBot:WasRecentlyDamagedByAnyHero(0.5) and powerRatio > geneList.GetWeight(npcBot:GetUnitName(), "powerConsider") / 100 then --0.8
		return true
	end
	return false
end

function hasAggressiveEnemyNearby(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
	if #nearbyEnemy ~= 0 and npcBot:WasRecentlyDamagedByAnyHero(0.5) and powerRatio > geneList.GetWeight(npcBot:GetUnitName(), "powerConsider") / 100 then
		return true
	end
	return false
end

function considerPowerRatio(npcBot)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local nearbyAlly = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)

	return RemapValClamped(powerRatio, 0.2, 1, 0, 100)
end
--enemyCreepsHittingMe--------------------------------------------------------------
function hasEnemyCreepsNearby(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(800, true)
	if #nearbyEnemyCreeps ~= 0 then
		return true
	end
	return false
end

function considerEnemyCreepHits(npcBot)
	local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(800, true)
	local creepsTargetingMe = {}
	for _,creep in pairs(nearbyEnemyCreeps) do
		if creep:GetAttackTarget() == npcBot then
			table.insert(creepsTargetingMe, creep)
		end
	end
	return Clamp(geneList.GetWeight(npcBot:GetUnitName(), "creepCount") * #creepsTargetingMe, 0, 100)
end

function FountainMana(npcBot)
	local percentMana = module.CalcPerMana(npcBot)
	return npcBot:DistanceFromFountain() == 0 and percentMana < 0.8
end

function FillMana(npcBot)
	return 20
end

------------------------------------------------------------------------------------

function AreThereDangerPings(npcBot)
	local team = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local time = GameTime()

	for __,aHero in pairs(team) do
		local recentPing = aHero:GetMostRecentPing()
		--print(recentPing.time)
		if recentPing ~= nil and not recentPing.normal_ping and
			(time - recentPing.time) <= geneList.GetWeight(npcBot:GetUnitName(), "dangerTime") / 10 and
			GetUnitToLocationDistance(npcBot, recentPing.location) <= geneList.GetWeight(npcBot:GetUnitName(), "dangerDistance") then
			return true
		end
	end

	return false
end

function DistanceFromDangerPing(npcBot)
	return 100
end

------------------------------------------------------------------------------------
local retreat_weight = {
    settings =
    {
        name = "retreat",

        components = {
            --{func=numberDifference, weight=1}
        },

        conditionals = {
			{func=enemyTowerShallTargetMe, condition=willEnemyTowerTargetMe, weight=geneList.GetWeight, weightName="willEnemyTowerTargetMe"},
			{func=enemyTowerTargetingMe, condition=isEnemyTowerTargetingMeNoAlly, weight=geneList.GetWeight, weightName="isEnemyTowerTargetingMeNoAlly"},

			{func=considerPowerRatio, condition=hasPassiveEnemyNearby, weight=geneList.GetWeight, weightName="hasPassiveEnemyNearby"}, --0.5
			{func=considerPowerRatio, condition=hasAggressiveEnemyNearby, weight=geneList.GetWeight, weightName="hasAggressiveEnemyNearby"}, --2

			{func=considerEnemyCreepHits, condition=hasEnemyCreepsNearby, weight=geneList.GetWeight, weightName="hasEnemyCreepsNearby"},
			{func=lowHealth, condition=hardRetreat, weight=geneList.GetWeight, weightName="hardRetreat"},
			{func=lowHealthSoft, condition=enemyRetreat, weight=geneList.GetWeight, weightName="enemyRetreat"},
			{func=FillMana, condition=FountainMana, weight=20},
			{func=DistanceFromDangerPing, condition=AreThereDangerPings, weight=geneList.GetWeight, weightName="AreThereDangerPings"}
		}
    }
}

return retreat_weight