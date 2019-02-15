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
        --when there's low health enemy/ally creep, only apply one at a time.
        --getLowestCreep returns creep unit
        local lowEcreep = module.get(npcBot:GetNearbyLaneCreeps(200, true))
        local lowAcreep = getLowestCreep(npcBot:GetNearbyLaneCreeps(200, false))
        --borrowed from moo
        if (lowEcreep ~= nil and lowEcreep:GetHealth() / lowEcreep:GetMaxHealth() > 0.2 and lowEcreep:GetHealth() <= npcBot:GetAttackDamage() * 1.2) then
            weight = weight + 70
        else if (lowAcreep ~= nil and lowAcreep:GetHealth() / lowAcreep:GetMaxHealth() > 0.2 and lowAcreep:GetHealth() <= npcBot:GetAttackDamage() * 1.2) then
            weight = weight + 60
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
        --Lower the enemy Health, WE JUST GO FOR IT BECAUSE WE'RE BEASTS
        local nearbyEnemy = npcBot:GetNearbyHeroes(500, true)
        local nearbyTower = npcBot:GetNearbyTowers(700, true)
        if nearbyTower[1] == nil and nearbyEnemy[1]:GetHealth() / nearbyEnemy[1]:GetMaxHealth() < 0.3 then
            weight = weight + 90
        end
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
