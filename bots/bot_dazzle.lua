local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "dazzle_poison_touch"
local SKILL_W = "dazzle_shallow_grave"
local SKILL_E = "dazzle_shadow_wave"
local SKILL_R = "dazzle_bad_juju"
local TALENT1 = "special_bonus_attack_damage_75"
local TALENT2 = "special_bonus_hp_200"
local TALENT3 = "special_bonus_cast_range_125"
local TALENT4 = "special_bonus_unique_dazzle_2"
local TALENT5 = "special_bonus_movement_speed_40"
local TALENT6 = "special_bonus_unique_dazzle_3"
local TALENT7 = "special_bonus_unique_dazzle_1"
local TALENT8 = "special_bonus_unique_dazzle_4"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_W,
	SKILL_Q,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_E,
	SKILL_E,
	TALENT1,
	SKILL_E,
	SKILL_R,
	SKILL_W,
	SKILL_W,
	TALENT4,
	SKILL_W,
	"nil",
	SKILL_R,
	"nil",
	TALENT5,
	"nil",
	"nil",
	"nil",
	"nil",
	TALENT8
}