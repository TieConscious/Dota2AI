local farm_weight = require(GetScriptDirectory().."/weights/farm")
local retreat_weight = require(GetScriptDirectory().."/weights/retreat")
local hunt_weight = require(GetScriptDirectory().."/weights/hunt")
local tower_weight = require(GetScriptDirectory().."/weights/tower")
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local deaggro_weight = require(GetScriptDirectory().."/weights/deaggro")
local rune_weight = require(GetScriptDirectory().."/weights/rune")
local heal_weight = require(GetScriptDirectory().."/weights/heal")
local gank_weight = require(GetScriptDirectory().."/weights/gank")
local dodge_weight = require(GetScriptDirectory().."/weights/dodge")
local defend_weight = require(GetScriptDirectory().."/weights/defend")
local finishHim_weight = require(GetScriptDirectory().."/weights/finishHim")
local geneList = require(GetScriptDirectory().."/genes/gene")
local module = require(GetScriptDirectory().."/helpers")
--local ward_weight = require(GetScriptDirectory().."/weights/ward")
local globalState = require(GetScriptDirectory().."/global_state")

local stateMachine = {}

local state =
{
    state = "idle",
    weights = {}
}

function stateMachine.calculateState(npcBot)
    globalState.calculateState(npcBot:GetTeam())
    stateMachine.calcWeight(npcBot, retreat_weight.settings)
    stateMachine.calcWeight(npcBot, hunt_weight.settings)
    stateMachine.calcWeight(npcBot, farm_weight.settings)
    stateMachine.calcWeight(npcBot, tower_weight.settings)
	stateMachine.calcWeight(npcBot, buy_weight.settings)
    stateMachine.calcWeight(npcBot, deaggro_weight.settings)
	stateMachine.calcWeight(npcBot, rune_weight.settings)
    stateMachine.calcWeight(npcBot, heal_weight.settings)
    stateMachine.calcWeight(npcBot, gank_weight.settings)
    stateMachine.calcWeight(npcBot, dodge_weight.settings)
    stateMachine.calcWeight(npcBot, defend_weight.settings)
    stateMachine.calcWeight(npcBot, finishHim_weight.settings)
    --stateMachine.calcWeight(npcBot, ward_weight.settings)


    --more weights

    --get teammate states
    stateMachine.teamwork(npcBot)

    stateMachine.getState()
    return state
end

function stateMachine.teamwork(npcBot) 
    local countSelfAsAlly = false
    local allyTeamworkDistance = geneList.GetWeight(npcBot:GetUnitName(), "teamworkDist") --600 --test 1000
    local allyTeamworkModifier = geneList.GetWeight(npcBot:GetUnitName(), "teamworkMod") / 100 --.2 (20) --test .25
    local allyTeamworkThreshold = geneList.GetWeight(npcBot:GetUnitName(), "teamworkThreshold") --42

    local nearbyAlly = npcBot:GetNearbyHeroes(allyTeamworkDistance, false, BOT_MODE_NONE)
    if (allyTeamworkModifier ~= 0 and nearbyAlly ~= nil and #nearbyAlly > 0) then
        for _,unit in pairs(nearbyAlly) do
            local pid = unit:GetPlayerID()
            if (unit ~= nil and unit:IsAlive() and (countSelfAsAlly or pid ~= npcBot:GetPlayerID()) and globalState.state.teammates[pid] ~= nil) then
                local allyStateName = globalState.state.teammates[pid].currentState
                local allyStateWeight = globalState.state.teammates[pid].stateWeight

                --if we are above the state threshold, then apply teammate's state to us
                if state.weights[allyStateName] ~= nil and state.weights[allyStateName] > allyTeamworkThreshold then
                    state.weights[allyStateName] = state.weights[allyStateName] + (allyStateWeight * allyTeamworkModifier)
                end
            end
        end
    end
end

function stateMachine.calcWeightedAvg(table)
    local denom = 0
    local total = 0
    for _,component in pairs(table) do
        total = total + (component.v * component.w)
        denom = denom + component.w
    end
    if denom == 0 then
        return 0
    end
    return total / denom
end

function stateMachine.calcWeight(npcBot, settings)
    local computedComps = {}

    for _,component in pairs(settings.components) do
        local comp = {}
		comp.v = component.func(npcBot)
		if (type(component.weight) == "function") then
			comp.w = component.weight(npcBot:GetUnitName(), component.weightName)
		else
			comp.w = component.weight
		end
        table.insert(computedComps, comp)
    end

    for _,conditional in pairs(settings.conditionals) do
        if conditional.condition(npcBot) then
            local comp = {}
            comp.v = conditional.func(npcBot)
            if (type(conditional.weight) == "function") then
				comp.w = conditional.weight(npcBot:GetUnitName(), conditional.weightName)
			else
				comp.w = conditional.weight
			end
            table.insert(computedComps, comp)
        end
    end
	state.weights[settings.name] = stateMachine.calcWeightedAvg(computedComps)

	for _,mulitplier in pairs(settings.multipliers) do
		state.weights[settings.name] = state.weights[settings.name] * mulitplier.func(npcBot)
	end
end

function stateMachine.getState()
    local maxWeight = 0
    state.state = "idle"
    for name,weight in pairs(state.weights) do
        if weight > maxWeight then
            maxWeight = weight
            state.state = name
        end
    end
    --log current state info
    local pid = GetBot():GetPlayerID()
    if globalState.state.teammates[pid] == nil then
        globalState.state.teammates[pid] = {}
        globalState.state.teammates[pid].currentState = "";
        globalState.state.teammates[pid].stateWeight = 0;
        globalState.state.teammates[pid].movingTo = Vector(0, 0, -1);
    end
	globalState.state.teammates[pid].currentState = state.state;
    globalState.state.teammates[pid].stateWeight = maxWeight;
    globalState.state.teammates[pid].movingTo.z = -1
end

function stateMachine.printState(s)
    local str = string.format("State=\"%s\":  ", s.state)
    for name,weight in pairs(s.weights) do
        str = str..string.format("%s=%03d ", name, weight)
    end
    print(str)
end

function stateMachine.getWeightValue(value)
    local weightValue = state.weights[value].weight
    return weightValue
end

return stateMachine