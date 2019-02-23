local module = require(GetScriptDirectory().."/helpers")

runes = {
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4
}

local runeCollectDist = 1500

function distToRune(npcBot)
    local nearestRuneLoc
    local runeLoc
    for _,rune in pairs(runes) do
        runeLoc = GetRuneSpawnLocation(rune)
        if (GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE and (nearestRuneLoc == nil or GetUnitToLocationDistance(npcBot, runeLoc) < GetUnitToLocationDistance(npcBot, nearestRuneLoc))) then
            nearestRuneLoc = runeLoc
        end
    end
    local dist = GetUnitToLocationDistance(npcBot, nearestRuneLoc)
    return RemapValClamped(dist, 120, runeCollectDist, 100, 10)
end

function nextToRune(npcBot)
    local runeLoc
    for _,rune in pairs(runes) do
        runeLoc = GetRuneSpawnLocation(rune)
        if (GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE and GetUnitToLocationDistance(npcBot, runeLoc) < runeCollectDist) then
            return true
        end
    end
    return false
end

function firstRunes(npcBot)
    return RemapValClamped(DotaTime(), -60, 0, 0, 35)
end

function isEarlyGame(npcBot)
    if (DotaTime() < 0) then
        return true
    else
        return false
    end
end

local rune_weight = {
    settings =
    {
        name = "rune", 
    
        components = {
            --{func=<calculate>, weight=<n>},
        },
    
        conditionals = {
            --{func=<calculate>, condition=<condition>, weight=<n>},
            {func=firstRunes, condition=isEarlyGame, weight=1},
            {func=distToRune, condition=nextToRune, weight=1}
        }
    }
}

return rune_weight