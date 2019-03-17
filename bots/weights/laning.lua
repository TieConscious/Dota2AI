local module = require(GetScriptDirectory().."/helpers")

function GoLane(npcBot)
    return 20
end

function enemyAndCreepsNearby(npcBot)
	local nearbyCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local nearbyEnemy = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if #nearbyEnemy ~= 0 and #nearbyCreeps ~= 0 then
		return true
	end
	return false
end

local laning_weight = {
    settings =
    {
        name = "laning",

        components = {

        },

        conditionals = {
            {func=GoLane, condition=enemyAndCreepsNearby, weight=1}
        }
    }
}

return laning_weight