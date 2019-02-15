local module = require(GetScriptDirectory().."/helpers")

local stateMachine = {}

local state =
{
    state = "farm", 
    farmWeight = 0,
    huntWeight = 0,
    demoWeight = 0,
    healWeight = 0,
    retreatWeight = 0
}

function stateMachine.calculateStates(npcBot)
    return state
end

return stateMachine