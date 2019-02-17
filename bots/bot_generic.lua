local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")

function Think()
	local npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)
	behavior.generic(npcBot, state)
end
