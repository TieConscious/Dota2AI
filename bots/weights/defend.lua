local module = require(GetScriptDirectory().."/helpers")
local globalState = require(GetScriptDirectory().."/global_state")

function EnemiesNearAncient(npcBot)
	return RemapValClamped(globalState.state.enemiesInBase, 0, 4, 0, 100)
end

function NoEnemyNearby(npcBot)
	local eHeroNearby = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	return eHeroNearby == nil or #eHeroNearby == 0
end

function NumberCreeps(npcBot)
    local ancient

    if (npcBot:GetTeam() == 2) then
		ancient = GetAncient(2)
	else
		ancient = GetAncient(3)
	end

    local nearbyEnemyCreeps = ancient:GetNearbyLaneCreeps(1600, true)
    if (nearbyEnemyCreeps ~= nil) then
        return RemapValClamped(#nearbyEnemyCreeps, 10, 20, 0, 50)
    else
        return 0
    end
end

----distance from their ancient will lower desire

local defend_weight = {
    settings =
    {
        name = "defend",

        components = {

        },

        conditionals = {
            {func=EnemiesNearAncient, condition=NoEnemyNearby, weight=2},
            {func=NumberCreeps, condition=NoEnemyNearby, weight=1}
        },
	
		multipliers = {
		}
    }
}

return defend_weight