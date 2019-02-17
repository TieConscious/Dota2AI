local module = require(GetScriptDirectory().."/helpers")

local stateMachine = {}
--was never compiled.
--initialize npcBot before using
--I mean if you want to.
--I was just bored and had nothing to do.
--There aren't much to lurn in lua

local state =
{
    state = "farm", --farm for place holding.
    farmWeight = 0,
    huntWeight = 0,
    towerWeight = 0,
    healWeight = 0,
    retreatWeight = 0
}


npcBot = nil

--find FarmWeight
function stateMachine.findFarmWeight(customFunction)
    --default 10.
    local weight = 10
    if customFunction ~= nil then
        weight = customFunction()
	else
		--medusa has 600, tide hunter has 150 range.
		--medusa will search in 800 range and tide hunter will search in 575 range
		local attackRange = npcBot:GetAttackRange()
		local nearbyECreeps = npcBot:GetNearbyLaneCreeps(500 + attackRange / 2, true)
		local nearbyACreeps = npcBot:GetNearbyLaneCreeps(500 + attackRange / 2, false)
		local lowECreep = module.GetWeakestUnit(nearbyECreeps)
		local lowACreep = module.GetWeakestUnit(nearbyAcreeps)
		local ECreepDist = GetUnitToUnitDistance(npcBot, lowECreep)
		local ACreepDist = GetUnitToUnitDistance(npcBot, lowACreep) 
		--check Ecreep first and then Acreep. never increase weight at the same time.
		--bonus weight if in range. If not, further they are, lower the weight
		if lowECreep ~= nil and module.CalcPerHealth(lowECreep) < 0.2 then
			weight = weight + 40
			if attackRange > ECreepDist then
				weight = weight + 30
			else
				weight = weight + 300 / (15 + attackRange - ECreepDist)
            end
        --and for the ally(comes later)
        elseif lowACreep ~= nil and module.CalcPerHealth(lowACreep) < 0.2 then
			weight = weight + 35
			if attackRange > AcreepDist then
				weight = weight + 20
			else
				weight = weight + 150 / (7 + attackRange - Acreepdist)
			end
		end
    end
    state.farmWeight = weight;
end

--find HuntWeight
function stateMachine.findHuntWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
	else
		local attackRange = npcBot:GetAttackRange()
		local nearbyEnemy = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local nearbyAlly = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
        local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)

        --Count Calculation-
        weight = weight + 5 * (#nearbyAlly + 1 - #nearbyEnemy)

        --Ally Health-
        local allyHealthAverage = module.CalcPerHealth(npcBot)
        for _,ally in pairs(nearbyAlly) do
            allyHealthAverage = allyHealthAverage + module.CalcPerHealth(ally)
        end
        allyHealthAverage = allyHealthAverage / (#nearbyAlly + 1)
        weight = weight - 15 + 40 * allyHealthAverage

        --Enemy Health-
        local enemyHealthAverage = 0
        for _,enemy in pairs(nearbyEnemy) do
            enemyHealthAverage = enemyHealthAverage + module.CalcPerHealth(enemy)
        end
        enemyHealthAverage = enemyHealthAverage / #nearbyEnemy
        weight = weight - 15 + 40 * enemyHealthAverage

        --Ally Mana-
        local allyManaAverage = module.CalcPerMana(npcBot)
        for _,ally in pairs(nearbyAlly) do
            allyManaAverage = allyManaAverage + module.CalcPerMana(ally)
        end
        allyManaAverage = allyManaAverage / (#nearbyAlly + 1)
        if (allyManaAverage < 0.4 ) then
           weight = weight - 50 + 50 * allyManaAverage
        end

        --Enemy Mana-
        local enemyManaAverage = 0
        for _,enemy in pairs(nearbyEnemy) do
           enemyManaAverage = enemyManaAverage + module.CalcPerMana(enemy)
        end
         enemyManaAverage = enemyManaAverage / #nearbyEnemy
         weight = weight - 15 + 40 * enemyManaAverage

        --Enemy Distance, checkes lowest First, then closest
		if lowestEnemy ~= nil and module.CalcPerHealth(lowestEnemy) < 0.5 and GetUnitToUnitDistance(npcBot, lowestEnemy) < 700 then
			weight = weight + 20 / module.CalcPerHealth(lowestEnemy)
		elseif attackRange > GetUnitToUnitDistance(npcBot, nearbyEnemy[1]) then
			weight = weight + 20 + 3000 / attackRange
        end

        --in tower_range
        local nearbyEnemyTower = npcBot:GetNearbyTowers(700, true)
        if next(nearbyEnemyTower) ~= nil then
            weight = weight - 50
        end
		--Total Factor : powerRatio.
		weight = weight / powerRatio 
    end
    state.huntWeight = weight * .1;
end

--find demoWeight
function stateMachine.findTowerWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
       weight = customFunction()
    else
        --if i'm not getting hit by the tower and there's several creeps helping
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
        if nearbyEnemyTowers ~= nil and #nearbyEnemyTowers > 0 and npcBot:WasRecentlyDamagedByTower(0.5) and nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetNearbyLaneCreeps(700, true) ~= nil 
            and #nearbyEnemyTowers[1]:GetNearbyLaneCreeps(700, true) > 1 then
            weight = weight + 70
        end

        local nearbyEnemy = npcBot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        weight = weight - 5 * #nearbyEnemy

        if nearbyEnemyTowers ~= nil and #nearbyEnemyTowers > 0 then
            local enemyTowerPerHealth = module.CalcPerHealth(nearbyEnemyTowers[1])
            if (enemyTowerPerHealth < 0.2) then
                weight = weight * (1 + 0.2 - enemyTowerPerHealth)
            end
        end
    end
    state.towerWeight = weight;
end

--find healWeight
function stateMachine.findHealWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
    else
        --200 for 0% health, 0.66 for 100% health.
        --100e^-8x = y, 
        --tip: increase 100 part to give more weight for lower health.
        --lower the -8 part to lower the weight for higher health.  
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        weight = 200 * math.exp(-8 * percentHealth)
        --If closer to Fountain, multiply weight.

        --collaborate with item situations
    end
    state.healWeight = weight;
end

--find RetreatWeight
function stateMachine.findRetreatWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
    else
        --50 for 0% health, 0.33 for 100% health.
        --50e^-5x = y, 
        --health
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        weight = weight + 50 * math.exp(-5 * percentHealth)

        --tower
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
        if nearbyEnemyTowers ~= nil and #nearbyEnemyTowers > 0 and next(nearbyEnemyTowers) ~= nil and nearbyEnemyTowers[1]:GetNearbyLaneCreeps(700, true) ~= nil and #((nearbyEnemyTowers[1]):GetNearbyLaneCreeps(700, true)) < 3 then
            weight = weight + 50
        end
        
        --closest Deadly Enemy
        local nearbyEnemy = npcBot:GetNearbyHeroes(300, true, BOT_MODE_NONE)
        if nearbyEnemy[1] ~= nil and nearbyEnemy[1]:GetHealth() / nearbyEnemy[1]:GetMaxHealth() > 0.5 and
            2 * npcBot:GetOffensivePower() < nearbyEnemy[1]:GetOffensivePower() then
            weight = weight + 50
        end

        --numbers count,
		local nearbyEnemy = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local nearbyAlly = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        --weight = weight + 5 * (#nearbyAlly + 1 - #nearbyEnemy)
    
        --Power
        local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
        if powerRatio > 1.5 then
            weight = weight + 30
        end

        --if 3* more creep on them
        if 3 * #npcBot:GetNearbyLaneCreeps(500, false) < #npcBot:GetNearbyLaneCreeps(500, true) then
            weight = weight + 30
        end
    
        --if I'm getting hit by Tower
        if npcBot:WasRecentlyDamagedByTower(0.5) then
            weight = weight + 50
        end

    end
    state.retreatWeight = weight;
end

function stateMachine.calculateState(bot)
    npcBot = bot
    stateMachine.findTowerWeight(nil)
    stateMachine.findHealWeight(nil)
    stateMachine.findFarmWeight(nil)
    stateMachine.findHuntWeight(nil)
    stateMachine.findRetreatWeight(nil)

    local maxWeight = -999
    --change this if more state.

    if maxWeight < state["farmWeight"] then
        maxWeight = state["farmWeight"]
        state.state = "farm"
    end
    if maxWeight < state["huntWeight"] then
        maxWeight = state["huntWeight"]
        state.state = "hunt"
    end
    if maxWeight < state["towerWeight"] then
        maxWeight = state["towerWeight"]
        state.state = "tower"
    end
    if maxWeight < state["healWeight"] then
        maxWeight = state["healWeight"]
        state.state = "heal"
    end
    if maxWeight < state["retreatWeight"] then
        maxWeight = state["retreatWeight"]
        state.state = "retreat"
    end
    return state
end

function stateMachine.printState(s)
    print(string.format("State=%s : F=%03d E=%03d T=%03d H=%03d R=%03d", s.state, s.farmWeight, s.huntWeight, s.towerWeight, s.healWeight, s.retreatWeight))
end

return stateMachine