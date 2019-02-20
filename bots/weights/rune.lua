local module = require(GetScriptDirectory().."/helpers")

runes = {
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4
}

function constFourty(npcBot)
    return 40
end

function nextToRune(npcBot)
    local runeLoc
    for _,rune in pairs(runes) do
        runeLoc = GetRuneSpawnLocation(rune)
        if (GetRuneTimeSinceSeen(rune) < 1 and GetUnitToLocationDistance(npcBot, runeLoc) < 1500) then
            return true
        end
    end
    return false
end

function firstRunes(npcBot)
    return RemapValClamped(DotaTime(), -60, 0, 0, 35)
end

function isEarlyGame(npcBot)
    if (DotaTime() < 5) then
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
            {func=constFourty, condition=nextToRune, weight=1}
        }
    }
}

return rune_weight