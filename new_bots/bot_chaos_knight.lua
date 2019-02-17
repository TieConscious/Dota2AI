local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/next_gen_state_machine")

local SKILL_Q = "chaos_knight_chaos_bolt"
local SKILL_W = "chaos_knight_reality_rift"
local SKILL_E = "chaos_knight_chaos_strike"
local SKILL_R = "chaos_knight_phantasm"
local TALENT1 = "special_bonus_all_stats_5"
local TALENT2 = "special_bonus_movement_speed_20"
local TALENT3 = "special_bonus_strength_15"
local TALENT4 = "special_bonus_cooldown_reduction_12"
local TALENT5 = "special_bonus_gold_income_25"
local TALENT6 = "special_bonus_unique_chaos_knight"
local TALENT7 = "special_bonus_unique_chaos_knight_2"
local TALENT8 = "special_bonus_unique_chaos_knight_3"

local Ability = {
	SKILL_Q,
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	SKILL_E,
	SKILL_R,
	SKILL_W,
	SKILL_Q,
	SKILL_Q,
	TALENT1,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_W,
	TALENT3,
	SKILL_E,
	"nil",
	SKILL_R,
	"nil",
	TALENT5,
	"nil",
	"nil",
	"nil",
	"nil",
	TALENT7
}

function OnStart()
	print("init")
end

function Think()
	local npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)
	
	stateMachine.printState(state)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		behavior.generic(npcBot, state)
	else
		behavior.generic(npcBot, state)
	end
end
