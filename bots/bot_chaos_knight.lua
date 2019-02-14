local module = require(GetScriptDirectory().."/functions")
local bot_generic = require(GetScriptDirectory().."/bot_generic")

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

local npcBot = GetBot()
local UseAbility = npcBot.ActionPush_UseAbilityOnEntity

function IsBotCasting()
	return npcBot:IsChanneling()
		  or npcBot:IsUsingAbility()
		  or npcBot:IsCastingAbility()
end

function ConsiderItem(Item)
	if (Item == nil or not Item:IsFullyCastable()) then
		return 0
	end

		return 1
end

function ConsiderCast(ability)
	if (not ability:IsFullyCastable()) then
		return 0
	end

	return 1
end

function castOrder(PowUnit)
	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)

	local Mana = npcBot:GetMana()
	local MaxMana = npcBot:GetMaxMana()
	local manaPer = Mana/MaxMana

	if (IsBotCasting()) then
		return
	end

	if (ConsiderCast(abilityR) == 1 and ConsiderCast(abilityW) == 1) then
		if (GetUnitToUnitDistance(npcBot,PowUnit) <= abilityW:GetCastRange()) then
			UseAbility(npcBot, abilityW, PowUnit)
			UseAbility(npcBot, abilityR, PowUnit)
			UseAbility(npcBot, abilityW, PowUnit)
		end
	end

	if (ConsiderCast(abilityW) == 1 and manaPer >= 0.4 and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityW:GetCastRange()) then
		UseAbility(npcBot, abilityW, PowUnit)
	end

	if (ConsiderCast(abilityR) == 1 and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityR:GetCastRange()) then
		UseAbility(npcBot, abilityR, PowUnit)
	end


end

function Think()
	local npcBot = GetBot()
	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	module.AbilityLevelUp(Ability)
	if (npcBot:GetLevel() >= 1 and PowUnit ~= nil) then
		castOrder(PowUnit)
	end

	bot_generic.Think()
end
