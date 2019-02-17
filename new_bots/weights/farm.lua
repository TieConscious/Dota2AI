local module = require(GetScriptDirectory().."/helpers")

function beTrue(npcBot)
    return true
end

function findFarmWeight(npcBot)
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
    return weight;
end

local farm_weight = {
    settings =
    {
        name = "farm", 
    
        components = {
            --{func=calcEnemies, weight=5},
            {func=findFarmWeight, weight=1}
        },
    
        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
            {func=findFarmWeight, condition=beTrue, weight=1}
        }
    }
}

return farm_weight