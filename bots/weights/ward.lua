local module = require(GetScriptDirectory().."/helpers")

--Radiantside_riverward_Top = Vector(-2800, 800, 0)
--Radiantside_riverward_Bot = Vector(3050, -2750, 0)
--Radiantside_direjungle_Top = Vector(-3000, 4250, 0)
<<<<<<< HEAD
--aShrine1 = GetShrine(GetTeam(), SHRINE_JUNGLE_1)
--aShrine2 = GetShrine(GetTeam(), SHRINE_JUNGLE_2)
--eShrine1 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_1)
--eShrine2 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_2)

local wardPlaceDist = 2000

=======
>>>>>>> parent of 41499f0... wards work


function DistToWardSpot(npcBot)
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

function NextToWardSpot(npcBot)
    local wardLoc
    for _,rune in pairs(runes) do
        runeLoc = GetRuneSpawnLocation(rune)
        if (GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE and GetUnitToLocationDistance(npcBot, runeLoc) < runeCollectDist) then
            return true
        end
    end
    return false
end

local ward_weight = {
    settings =
    {
        name = "ward",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
            {func=DistToWardSpot, condition=NextToWardSpot, weight=1}
        }
    }
}

return ward_weight