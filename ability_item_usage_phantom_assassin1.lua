local module = require(GetScriptDirectory().."/functions")

local SKILL_Q = "phantom_assassin_stifling_dagger"
local SKILL_W = "phantom_assassin_phantom_strike"
local SKILL_E = "phantom_assassin_blur"
local SKILL_R = "phantom_assassin_coup_de_grace"
local TALENT1 = "special_bonus_hp_150"
local TALENT2 = "special_bonus_attack_damage_15"
local TALENT3 = "special_bonus_lifesteal_15"
local TALENT4 = "special_bonus_cleave_25"
local TALENT5 = "special_bonus_corruption_4"
local TALENT6 = "special_bonus_unique_phantom_assassin_3"
local TALENT7 = "special_bonus_unique_phantom_assassin_2"
local TALENT8 = "special_bonus_unique_phantom_assassin"

local Ability = {
	"nil",
	"nil",
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_W,
	SKILL_W,
	TALENT2,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_E,
	TALENT4,
	SKILL_E,
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

--function AbilityUsageThink()
--	--local enemys = npcBot:GetNearbyHeroes(CastRange+300, true, BOT_MODE_NONE)
--	--local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
--	local creeps = npcBot:GetNearbyCreeps(CastRange+300, true)
--	local WeakestCreep,CreepHealth = module.GetWeakestUnit(creeps)
--
--	module.LastHit(WeakestCreep, CreepHealth)
--end