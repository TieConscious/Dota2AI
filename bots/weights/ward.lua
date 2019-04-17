-- local module = require(GetScriptDirectory().."/helpers")

-- Radiantside_riverward_Top = Vector(-2800, 800, 0)
-- Radiantside_riverward_Bot = Vector(3000, -2800, 0)
-- Radiantside_direjungle_Top = Vector(-3000, 4250, 0)
-- aShrine1 = GetShrine(GetTeam(), SHRINE_JUNGLE_1):GetLocation() + Vector(100, 0, 0)
-- aShrine2 = GetShrine(GetTeam(), SHRINE_JUNGLE_2):GetLocation() + Vector(100, 0, 0)
-- eShrine1 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_1):GetLocation() + Vector(100, 0, 0)
-- eShrine2 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_2):GetLocation() + Vector(100, 0, 0)
-- local ward_weight = {
-- wardLocs =
-- {
--     [Radiantside_riverward_Bot] = 120,
--     [Radiantside_riverward_Top] = 120,
--     [Radiantside_direjungle_Top] = 120,
--     [eShrine1] = 120,
--     [eShrine2] = 120,
--     [aShrine1] = 120,
--     [aShrine2] = 120
-- }
-- }
-- --Radiantside_riverward_Top = Vector(-2800, 800, 0)
-- --Radiantside_riverward_Bot = Vector(3050, -2750, 0)
-- --Radiantside_direjungle_Top = Vector(-3000, 4250, 0)
-- --aShrine1 = GetShrine(GetTeam(), SHRINE_JUNGLE_1)
-- --aShrine2 = GetShrine(GetTeam(), SHRINE_JUNGLE_2)
-- --eShrine1 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_1)
-- --eShrine2 = GetShrine(GetOpposingTeam(), SHRINE_JUNGLE_2)

-- local wardPlaceDist = 2000



-- function DistToWardSpot(npcBot)
--     local closestWard = nil

--     for loc,time in pairs(ward_weight.wardLocs) do
--         if (closestWard == nil or (GetUnitToLocationDistance(npcBot, loc) < GetUnitToLocationDistance(npcBot, closestWard))) then
--             closestWard = loc
--         end
--     end
--     local dist = GetUnitToLocationDistance(npcBot, closestWard)
--     return RemapValClamped(dist, 120, wardPlaceDist, 40, 10)
-- end

-- function NextToWardSpot(npcBot)
--     local ward = module.ItemSlot(npcBot, "item_ward_observer")
--     local currentTime = DotaTime()

--     if (ward ~= nil) then
--         for loc,time in pairs(ward_weight.wardLocs) do
--             if (GetUnitToLocationDistance(npcBot, loc) < wardPlaceDist and currentTime >= time) then
--                 return true
--             end
--         end
--     end

--     return false
-- end

-- ward_weight.settings = {
--         name = "ward",

--         components = {
--             --{func=<calculate>, weight=<n>},
--         },

--         conditionals = {
--             {func=DistToWardSpot, condition=NextToWardSpot, weight=1}
--         }
-- }

-- return ward_weight