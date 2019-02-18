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
        }
    }
}

return template_weight