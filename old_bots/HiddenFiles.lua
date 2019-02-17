--was never compiled.
--initialize npcBot before using
--I mean if you want to.
--I was just bored and had nothing to do.
--There aren't much to lurn in lua

local stateMachine =
{
    state = "farm", --farm for place holding.
    farmWight = 0,
    huntWight = 0,
    demoWight = 0,
    healWight = 0,
    retreatWight = 0
}

npcBot = nil

function getLowestCreep(creepList)
    local min = {creepList[1], creepList[1]:GetHealth() / creepList[1]:GetMaxHealth()}
    for _,id in pairs[creepList] do
        if min[2] > id:GetHealth() / id:GetMaxHealth() then
            min = {id, id:GetHealth() / id:GetMaxHealth()}
        end
    end
    return min[1]
end

--find FarmWight
function stateMachine:findFarmWight(customFunction)
    --default 10.
    local wight = 10
    if customFunction ~= nil then
        wight = customFunction()
    else
        --when there's low health enemy/ally creep, only apply one at a time.
        --getLowestCreep returns creep unit
        local lowEcreep = getLowestCreep(npcBot:GetNearbyLaneCreeps(200, true))
        local lowAcreep = getLowestCreep(npcBot:GetNearbyLaneCreeps(200, false))
        --borrowed from moo
        if (lowEcreep ~= nil and lowEcreep:GetHealth() / lowEcreep:GetMaxHealth() > 0.2 and lowEcreep:GetHealth() <= npcBot:GetAttackDamage() * 1.2) then
            wight = wight + 70
        else if (lowAcreep ~= nil and lowAcreep:GetHealth() / lowAcreep:GetMaxHealth() > 0.2 and lowAcreep:GetHealth() <= npcBot:GetAttackDamage() * 1.2) then
            wight = wight + 60
        end
    end
    self.farmWight = wight;
end

--find HuntWight
function stateMachine:findHuntWight(customFunction)
    local wight = 0
    if customFunction ~= nil then
        wight = customFunction()
    else
        --Lower the enemy Health, WE JUST GO FOR IT BECAUSE WE'RE BEASTS
        local nearbyEnemy = npcBot:GetNearbyHeroes(500, true)
        local nearbyTower = npcBot:GetNearbyTowers(700, true)
        if nearbyTower[1] == nil and nearbyEnemy[1]:GetHealth() / nearbyEnemy[1]:GetMaxHealth() < 0.3 then
            wight = wight + 90
        end
    end
    self.huntWight = wight;
end

--find demoWight
function stateMachine:findDemoWight(customFunction)
    local wight = 0
    if customFunction ~= nil then
       wight = customFunction()
    else
        --if i'm not getting hit by the tower and there's several creeps helping
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(1000, true)
        if nearbyEnemyTowers[1] ~= nil and #nearbyEnemyTower[1]:GetNearbyLaneCreeps(700, true) > 1 then
            wight = wight + 80
        end
    end
    self.demoWight = wight;
end

--find healWight
function stateMachine:findHealWight(customFunction)
    local wight = 0
    if customFunction ~= nil then
        wight = customFunction()
    else
        --200 for 0% health, 0.66 for 100% health.
        --100e^-8x = y, 
        --tip: increase 100 part to give more wight for lower health.
        --lower the -8 part to lower the wight for higher health.  
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        wight = 200 * math.exponential(-8 * percentHealth)

        --collaborate with item situations
    end
    self.healWight = wight;
end

--find RetreatWight
function stateMachine:findRetreatWight(customFunction)
    local wight = 0
    if customFunction ~= nil then
        wight = customFunction()
    else
        --50 for 0% health, 0.33 for 100% health.
        --50e^-5x = y, 
        --tip: increase 50 part to give more wight for lower health.
        --lower the -5 part to lower the wight for higher health.  
        local percentHealth = npcBot:GetHealth() / npcBot:GetMaxHealth()
        wight = 50 * math.exponential(-5 * percentHealth)

        --if i'm in enemy tower range and not many ally creeps are in that range,
        --Increase wight
        local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
        if nearbyEnemyTowers[1] ~= nil and #nearbyEnemyTower[1]:GetNearbyLaneCreeps(700, true) < 3 then
            wight = wight + 50
        end
        
        --if theres enemy nearby and it's deadly and went into close range,
        --And the enemy has high health%, Increase wight
        local nearbyEnemy = npcBot:GetNearbyHeroes(300, true, BOT_MODE_NONE)
        if nearbyEnemy[1] ~= nil and nearbyEnemy[1]:GetHealth() / nearbyEnemy[1]:GetMaxHealth() > 0.5 and
            2 * npcBot:GetOffensivePower() < nearbyEnemy[1]:GetOffensivePower() then
            wight = wight + 50
        end

        --if losing in numbers and we're weak,
        --Increase wight, remember that nearbyAlly doesn't count myself.
        local nearbyAlly = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
        nearbyEnemy = npcBot:GetNearbyHeroes(700,true, BOT_MODE_NONE)
        if #nearbyAlly + 2 < #nearbyEnemy and
            (npcBot:GetOffensivePower() + addUpPower(nearbyAlly)) * 1.5 < addUpPower(nearbyEnemy) then
            wight = wight + 50
        end

        --if ally lane creeps are few
        if #GetNearbyLaneCreeps(500, false) < 2 then
            wight = wight + 30
        --if I'm getting hit by Enemy
        --I got lazy cya
        end
    end
    self.retreatWight = wight;
end
end -- my vs_code really want's an extra end