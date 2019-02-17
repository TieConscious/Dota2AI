local module = require(GetScriptDirectory().."/helpers")



local hunt_weight = {
    settings =
    {
        name = "hunt", 
    
        components = {
            --{func=calcEnemies, weight=5},
            
        },
    
        conditionals = {
            --{func=calcEnemies, condition=condFunc, weight=3},
        }
    }
}

return hunt_weight