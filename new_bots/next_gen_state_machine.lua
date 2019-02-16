local farm_weight = require(GetScriptDirectory().."/weights/farm")

local stateMachine = {}

local state =
{
    state = "idle", 
    weights = {}
}

npcBot = nil

function stateMachine.calcWeightedAvg(table)
    local denom = 0
    local total = 0
    for _,component in pairs(table) do
        total = total + (component.v * component.w)
        denom = denom + component.w
    end
    return total / denom
end

function stateMachine.calcWeight(settings)
    local computedComps = {}

    for _,component in pairs(settings.components) do
        local comp = {}
        comp.v = component.func(npcBot)
        comp.w = component.weight
        table.insert(computedComps, comp)
    end

    for _,conditional in pairs(settings.conditionals) do
        if conditional.condition(npcBot) then
            local comp = {}
            comp.v = conditional.func(npcBot)
            comp.w = conditional.weight
            table.insert(computedComps, comp)
        end
    end

    state.weights[settings.name] = stateMachine.calcWeightedAvg(computedComps)
end

function stateMachine.calculateState(bot)
    npcBot = bot
    stateMachine.calcWeight(farm_weight.getSettings())

    local maxWeight = 0
    --change this if more state.

    for name,weight in pairs(state.weights) do
        if weight > maxWeight then
            maxWeight = weight
            state.state = name
        end
    end

    return state
end

function stateMachine.printState(s)
    local str = string.format("State=\"%s\":  ", s.state)
    for name,weight in pairs(s.weights) do
        str = str..string.format("'%s'=%03d ", name, weight)
    end
    print(str)
end

return stateMachine