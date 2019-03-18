----GetExtrapolatedLocation(fTime)
----{ {location, time_since_seen}, ...} GetHeroLastSeenInfo( nPlayerID )
----if the hero on the opposing team was last seen standing near us, check their hp
----if it was low enough, go to the extrapolated location 2 seconds into the future
----cant see whether they were low enough
----lower than 15% start pinging
----should we make this a separate weight?
----ActionImmediate_Ping( fXCoord, fYCoord, bNormalPing )
----{time, location, normal_ping} GetMostRecentPing()
----int GetUnitPotentialValue( hUnit, vLocation, fRadius )
----if no heroes around you?

local module = require(GetScriptDirectory().."/helpers")
local globalState = require(GetScriptDirectory().."/global_state")

function IsThereAPing(npcBot)
	local pingLocation = npcBot:GetMostRecentPing().location
	local timeSince = npcBot:GetMostRecentPing().time
	local timeNow = GameTime()

	--print(timeNow)
	--print(timeSince)
	if (pingLocation ~= nil and timeSince ~= nil and (timeNow - timeSince) <= 4.0 and GetUnitToLocationDistance(npcBot, pingLocation) <= 1000) then
		return true
	end

	return false
end

function Forty(npcBot)
    return 40
end

local finishHim_weight = {
    settings =
    {
        name = "finishHim",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
            {func=Forty, condition=IsThereAPing, weight=1},
        }
    }
}

return finishHim_weight