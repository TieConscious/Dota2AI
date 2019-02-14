local module = require(GetScriptDirectory().."/functions")
local bot_generic = require(GetScriptDirectory().."/bot_generic")

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

local npcBot = GetBot()
local AP_AttackUnit = npcBot.ActionPush_AttackUnit
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

function castOrder(EHERO)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)

	local Mana = npcBot:GetMana()
	local MaxMana = npcBot:GetMaxMana()
	local manaPer = Mana/MaxMana
	local AllyTowers = npcBot:GetNearbyTowers(700, false)

	if (IsBotCasting()) then
		return
	end

	if (ConsiderCast(abilityE) == 1 and AllyTowers ~= nil and #AllyTowers ~= 0) then
		UseAbility(npcBot, abilityE, EHERO[1])
	end

	if (ConsiderCast(abilityR) == 1 and ConsiderCast(abilityW) == 1 and ConsiderCast(abilityQ) == 1) then
		if (GetUnitToUnitDistance(npcBot,PowUnit) <= abilityW:GetCastRange()) then
			UseAbility(npcBot, abilityQ, PowUnit)
			UseAbility(npcBot, abilityW, PowUnit)
			UseAbility(npcBot, abilityR, PowUnit)
			AP_AttackUnit(npcBot, PowUnit)
		end
	end

	if (ConsiderCast(abilityR) == 1 and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityR:GetCastRange()) then
		UseAbility(npcBot, abilityR, PowUnit)
	end

	if (ConsiderCast(abilityW) == 1 and manaPer >= 0.4 and GetUnitToUnitDistance(npcBot,EHERO[1]) <= abilityW:GetCastRange()) then
		UseAbility(npcBot, abilityW, EHERO[1])
	end

end

function Think()
	local EHERO = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	module.AbilityLevelUp(Ability)
	if (npcBot:GetLevel() >= 1 and (EHERO ~= nil or #EHERO ~= 0)) then
		castOrder(EHERO)
	end

	bot_generic.Think()
end
