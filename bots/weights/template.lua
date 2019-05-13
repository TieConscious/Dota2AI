----Each weight is broken down into components and conditionals. Components are weighted using a range between 0-100
----and later scaled with the rest of the other weights, and are always computed. Conditionals are only used if a
----condition is true.


local module = require(GetScriptDirectory().."/helpers")

local template_weight = {
    settings =
    {
        name = "name",

        components = {
            --{func=<calculate>, weight=<n>},
        },

        conditionals = {
            --{func=<calculate>, condition=<condition>, weight=<n>},
        },
	
		multipliers = {
		}
    }
}

return template_weight