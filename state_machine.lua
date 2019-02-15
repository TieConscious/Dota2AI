local module = require(GetScriptDirectory().."/helpers")

--was never compiled.
--initialize npcBot before using
--I mean if you want to.
--I was just bored and had nothing to do.
--There aren't much to lurn in lua

local stateMachine =
{
    state = "farm", --farm for place holding.
    farmWeight = 0,
    huntWeight = 0,
    towerWeight = 0,
    healWeight = 0,
    retreatWeight = 0
}


npcBot = nil

--find FarmWight
function stateMachine:findFarmWeight(customFunction)
    --default 10.
    local weight = 10
    if customFunction ~= nil then
        weight = customFunction()
	else
		--medusa has 600, tide hunter has 150 range.
		--medusa will search in 800 range and tide hunter will search in 575 range
		local attackRange = npcBot:GetAttackRange()
		local nearbyECreeps = npcBot:GetNearbyLaneCreeps(500 + AttackRange / 2, true)
		local nearbyACreeps = npcBot:GetNearbyLaneCreeps(500 + AttackRange / 2, false)
		local lowECreep = module.GetWeakestUnit(nearbyECreeps)
		local lowACreep = module.GetWeakestUnit(nearbyAcreeps)
		local ECreepDist = GetUnitToUnitDistance(npcBot, lowECreep)
		local ACreepDist = GetUnitToUnitDistance(npcBot, lowACreep) 
		--check Ecreep first and then Acreep. never increase weight at the same time.
		--bonus weight if in range. If not, further they are, lower the weight
		if module.CalcPerHealth(lowECreep) < 0.2 then
			weight = weight + 40
			if attackRange > EcreepDist then
				weight = weight + 30
			else
				weight = weight + 300 / (15 + attackRange - Ecreepdist)
			end
		elseif module.CalcPerHealth(lowACreep) < 0.2 then
			weight = weight + 35
			if attackRange > AcreepDist then
				weight = weight + 20
			else
				weight = weight + 150 / (7 + attackRange - Acreepdist)
			end
		end
    end
    self.farmWeight = weight;
end

--find HuntWight
function stateMachine:findHuntWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
	else
		--in the document it says we can't use BOT_MODE_NONE for some reason.
		local attackRange = npcBot:GetAttackRange()
		local nearbyEnemy = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_ATTACK)
		local nearbyAlly = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local powerRatio = module.CalcPowerRatio(npcBot, nearbyAlly, nearbyEnemy)
		local lowestEnemy = module.GetWeakestUnit(nearbyEnemy)

		--Bonus for low health EHero nearby. 
		--Bonus for attackable EHero nearby. more bonus if I'm melee
		--Only calculates either.
		if module.CalcPerHealth(lowestEnemy) < 0.5 and GetUnitToUnitDistance(npcBot lowestEnemy) < 700 then
			weight = weight + 20 / module.CalcPerHealth(lowestEnemy)
		else if attackRange > GetUnitToUnitDistance(npcBot, nearbyEnemy[1]) then
			weight = weight + 20 + 3000/attackRange
		end
		
		--Total Factor : powerRatio.
		weight = weight / powerRatio 
    end
    self.huntWeight = weight;
end

--find demoWight
function stateMachine:findTowerWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
       weight = customFunction()
    else
        --if i'm not getting hit by the tower and there's several creeps helping
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
        if nearbyEnemyTowers[1] ~= nil and #nearbyEnemyTower[1]:GetNearbyLaneCreeps(700, true) > 1 then
            weight = weight + 80
        end
    end
    self.towerWeight = weight;
end

--find healWight
function stateMachine:findHealWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
    else
        --200 for 0% health, 0.66 for 100% health.
        --100e^-8x = y, 
        --tip: increase 100 part to give more wight for lower health.
        --lower the -8 part to lower the wight for higher health.  
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        weight = 200 * math.exponential(-8 * percentHealth)

        --collaborate with item situations
    end
    self.healWeight = weight;
end

--find RetreatWight
function stateMachine:findRetreatWeight(customFunction)
    local weight = 0
    if customFunction ~= nil then
        weight = customFunction()
    else
        --50 for 0% health, 0.33 for 100% health.
        --50e^-5x = y, 
        --tip: increase 50 part to give more wight for lower health.
        --lower the -5 part to lower the wight for higher health.  
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        weight = 50 * math.exponential(-5 * percentHealth)

        --if i'm in enemy tower range and not many ally creeps are in that range,
        --Increase wight
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
        if nearbyEnemyTowers[1] ~= nil and #nearbyEnemyTower[1]:GetNearbyLaneCreeps(700, true) < 3 then
            weight = weight + 50
        end
        
        --if theres enemy nearby and it's deadly and went into close range,
        --And the enemy has high health%, Increase wight
        local nearbyEnemy = npcBot:GetNearbyHeroes(300, true, BOT_MODE_NONE)
        if nearbyEnemy[1] ~= nil and nearbyEnemy[1]:GetHealth() / nearbyEnemy[1]:GetMaxHealth() > 0.5 and
            2 * npcBot:GetOffensivePower() < nearbyEnemy[1]:GetOffensivePower() then
            weight = weight + 50
        end

        --if losing in numbers and we're weak,
        --Increase wight, remember that nearbyAlly doesn't count myself.
        local nearbyAlly = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
        nearbyEnemy = npcBot:GetNearbyHeroes(700,true, BOT_MODE_NONE)
        if #nearbyAlly + 2 < #nearbyEnemy and
            (npcBot:GetOffensivePower() + addUpPower(nearbyAlly)) * 1.5 < addUpPower(nearbyEnemy) then
            weight = weight + 50
        end

        --if ally lane creeps are few
        if #GetNearbyLaneCreeps(500, false) < 2 then
            weight = weight + 30
        --if I'm getting hit by Enemy
        --I got lazy cya
        end
    end
    self.retreatWeight = weight;
end

function stateMachine:calculateStates(bot)
    npcBot = bot
    stateMachine:findTowerWeight(nil)
    stateMachine:findHealWeight(nil)
    stateMachine:findFarmWeight(nil)
    stateMachine:findHuntWeight(nil)
    stateMachine:findRetreatWeight(nil)

    local maxWeight = {-999}
    --change this if more state.
    if maxWeight < stateMachine[2] then
        maxWeight = stateMachine[2]
        self.state = "farm"
    end
    if maxWeight < stateMachine[3] then
        maxWeight = stateMachine[3]
        self.state = "hunt"
    end
    if maxWeight < stateMachine[4] then
        maxWeight = stateMachine[4]
        self.state = "tower"
    end
    if maxWeight < stateMachine[5] then
        maxWeight = stateMachine[5]
        self.state = "heal"
    end
    if maxWeight < stateMachine[6] then
        maxWeight = stateMachine[6]
        self.state = "retreat"
    end
    return self
end
