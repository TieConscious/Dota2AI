local module = require(GetScriptDirectory().."/functions")

local SKILL_Q = "bane_enfeeble"
local SKILL_W = "bane_brain_sap"
local SKILL_E = "bane_nightmare"
local SKILL_R = "bane_fiends_grip"
local TALENT1 = "special_bonus_armor_7"
local TALENT2 = "special_bonus_cast_range_100"
local TALENT3 = "special_bonus_unique_bane_4"
local TALENT4 = "special_bonus_exp_boost_40"
local TALENT5 = "special_bonus_unique_bane_1"
local TALENT6 = "special_bonus_movement_speed_50"
local TALENT7 = "special_bonus_unique_bane_2"
local TALENT8 = "special_bonus_unique_bane_3"

local Ability = {
	"nil",
	"nil",
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_R,
	SKILL_W,
	SKILL_E,
	SKILL_E,
	TALENT2,
	SKILL_E,
	SKILL_R,
	SKILL_Q,
	SKILL_Q,
	TALENT4,
	SKILL_Q,
	"nil",
	SKILL_R,
	"nil",
	TALENT6,
	"nil",
	"nil",
	"nil",
	"nil",
	TALENT8
}

function AbilityLevelUpThink()
	module.AbilityLevelUp(Ability)
end