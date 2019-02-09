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

function IsBotCasting(npcBot)
	return npcBot:IsChanneling()
		  or npcBot:IsUsingAbility()
		  or npcBot:IsCastingAbility()
end

function ConsiderW(npcBot, abilityW)
	npcBot:ActionImmediate_Chat("Consider W", true)
	if (not abilityW:IsFullyCastable()) then
		return 0
	end

	return 1
end

function ConsiderR(npcBot, abilityR)
	npcBot:ActionImmediate_Chat("Consider R", true)
	if (not abilityR:IsFullyCastable()) then
		return 0
	end

	return 1
end

function castOrder(PowUnit, npcBot)
	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)

	npcBot:ActionImmediate_Chat("Gonna cast shit", true)

	if (IsBotCasting(npcBot)) then
		return
	end

	if (ConsiderR(npcBot, abilityR) and ConsiderW(npcBot, abilityW)) then
		if (GetUnitToUnitDistance(npcBot,PowUnit) <= abilityW:GetCastRange()) then
			npcBot:ActionPush_UseAbilityOnEntity(abilityW, PowUnit)
			npcBot:ActionPush_UseAbilityOnEntity(abilityR, PowUnit)
			npcBot:ActionPush_UseAbilityOnEntity(abilityW, PowUnit)
		end
	end

	if (ConsiderW(npcBot, abilityW) == 1 and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityW:GetCastRange()) then
		npcBot:Action_UseAbilityOnEntity(abilityW, PowUnit)
	end

	if (ConsiderR(npcBot, abilityR) == 1 and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityR:GetCastRange()) then
		npcBot:Action_UseAbilityOnEntity(abilityR, PowUnit)
	end


end

function Think()
	local npcBot = GetBot()
	local EHERO = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	module.AbilityLevelUp(Ability)
	if (npcBot:GetLevel() >= 1 and PowUnit ~= nil) then
		castOrder(PowUnit, npcBot)
	end

	bot_generic.Think()
end
