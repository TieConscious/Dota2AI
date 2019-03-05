----Each weight is broken down into components and conditionals. Components are weighted using a range between 0-100
----and later scaled with the rest of the other weights, and are always computed. Conditionals are only used if a
----condition is true.


local module = require(GetScriptDirectory().."/helpers")

function HasDodgableLinearProj(npcBot)
	local output = module.GetDodgableIncomingLinearProjectiles(npcBot)
	if output ~= nil and #output ~= 0 then
		return true
	end
	return false
end

function HeyMove(npcBot)
	return 100
end

local dodge_weight = {
    settings =
    {
        name = "dodge",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
			{func=HeyMove, condition=HasDodgableLinearProj, weight = 1}
		--{func=<calculate>, condition=<condition>, weight=<n>},
        }
    }
}

return dodge_weight