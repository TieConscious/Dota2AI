local module = require(GetScriptDirectory().."/functions")
local bot_generic = require(GetScriptDirectory().."/bot_generic")

local SKILL_Q = "juggernaut_blade_fury"
local SKILL_W = "juggernaut_healing_ward"
local SKILL_E = "juggernaut_blade_dance"
local SKILL_R = "juggernaut_omni_slash"
local TALENT1 = "special_bonus_all_stats_5"
local TALENT2 = "special_bonus_movement_speed_20"
local TALENT3 = "special_bonus_unique_juggernaut_4"
local TALENT4 = "special_bonus_attack_speed_20"
local TALENT5 = "special_bonus_armor_10"
local TALENT6 = "special_bonus_unique_juggernaut_3"
local TALENT7 = "special_bonus_hp_600"
local TALENT8 = "special_bonus_unique_juggernaut_2"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_W,
	SKILL_W,
	TALENT1,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_E,
	TALENT4,
	SKILL_E,
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

function IsBotCasting(npcBot)
	return npcBot:IsChanneling()
		  or npcBot:IsUsingAbility()
		  or npcBot:IsCastingAbility()
end

function ConsiderItem(npcBot, Item)
	if (Item == nil or not Item:IsFullyCastable()) then
		return 0
	end

		return 1
end

function ConsiderCast(npcBot, ability)
	if (not ability:IsFullyCastable()) then
		return 0
	end

	return 1
end

function castOrder(PowUnit, PowHealth, npcBot)
	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)

	local Mana = npcBot:GetMana()
	local MaxMana = npcBot:GetMaxMana()
	local manaPer = Mana/MaxMana

	if (IsBotCasting(npcBot)) then
		return
	end

	if (ConsiderCast(npcBot, abilityR) == 1) then
		if (PowUnit:IsStunned()) then
			npcBot:ActionPush_UseAbilityOnEntity(abilityR, PowUnit)
		end
	end

	if (ConsiderCast(npcBot, abilityR) == 1 and abilityR:GetAbilityDamage() >= PowHealth) then
		npcBot:Action_UseAbilityOnEntity(abilityR, PowUnit)
	end


end

function Think()
	local npcBot = GetBot()
	local EHERO = npcBot:GetNearbyHeroes(1800, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	module.AbilityLevelUp(Ability)
	if (npcBot:GetLevel() >= 1 and PowUnit ~= nil) then
		castOrder(PowUnit, PowHealth, npcBot)
	end

	bot_generic.Think()
end
