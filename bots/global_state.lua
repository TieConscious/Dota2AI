
local globalState = {}

local state =
{
    calculationTime = 0.0,
    state = "idle", 
    weights = {}
}

function globalState.calculateState(team)
    local currTime = DotaTime()
    print(string.format("Current Time: %02f  Last Calculation Time: %02f", currTime, state.calculationTime))
    if currTime <= state.calculationTime then
        return
    end

    print("New global state calculation.")
    state.calculationTime = currTime
end

function globalState.printState()
    local str = string.format("State=\"%s\":  ", s.state)
    for name,weight in pairs(s.weights) do
        str = str..string.format("%s=%03d ", name, weight)
    end
    print(str)
end

return globalState