local module = require(GetScriptDirectory().."/helpers")

local searchRange = 1200

function numberCreeps(npcBot)
    local nearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
    return RemapValClamped(#nearbyEnemyCreeps, 3, 0, 0, 40)
end

function buildingNearby(npcBot)
    local eTower = npcBot:GetNearbyTowers(searchRange, true)
    if eTower ~= nil and #eTower > 0 then
        return true
    end
    local eBarracks = npcBot:GetNearbyBarracks(searchRange, true)
    if (eBarracks ~= nil and #eBarracks > 0) then
        return true
    end
    local eAncient 
	if npcBot:GetTeam() == 2 then
		eAncient = GetAncient(3)
	else
		eAncient = GetAncient(2)
    end
    if (eAncient ~= nil and GetUnitToUnitDistance(npcBot, eAncient) <= searchRange) then
        return true
    end
    return false
end

local tower_weight = {
    settings =
    {
        name = "tower", 
    
        components = {
            --{func=<calculate>, weight=<n>},
        },
    
        conditionals = {
            --{func=<calculate>, condition=<condition>, weight=<n>},
            {func=numberCreeps, condition=buildingNearby, weight=1}
        }
    }
}

return tower_weight