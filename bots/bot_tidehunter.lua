local module = require(GetScriptDirectory().."/functions")
local bot_generic = require(GetScriptDirectory().."/bot_generic")

local SKILL_Q = "tidehunter_gush"
local SKILL_W = "tidehunter_kraken_shell"
local SKILL_E = "tidehunter_anchor_smash"
local SKILL_R = "tidehunter_ravage"
local TALENT1 = "special_bonus_movement_speed_20"
local TALENT2 = "special_bonus_unique_tidehunter_2"
local TALENT3 = "special_bonus_exp_boost_40"
local TALENT4 = "special_bonus_unique_tidehunter_3"
local TALENT5 = "special_bonus_unique_tidehunter_4"
local TALENT6 = "special_bonus_unique_tidehunter"
local TALENT7 = "special_bonus_cooldown_reduction_25"
local TALENT8 = "special_bonus_attack_damage_250"

local TideAbility = {
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	SKILL_E,
	SKILL_R,
	SKILL_E,
	SKILL_W,
	SKILL_W,
	TALENT2,
	SKILL_W,
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

function ConsiderItem(npcBot, item)
	if (FindItemSlot("item_blink") == nil) then
		return 0
	else
		if (not ability:IsFullyCastable()) then
			return 0
		end

		return 1
	end
end

function ConsiderCast(npcBot, ability)
	npcBot:ActionImmediate_Chat("ConsiderCast Cast", true)
	if (not ability:IsFullyCastable()) then
		return 0
	end

	return 1
end

function castOrder(PowUnit, npcBot)
	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local blink = "item_blink"

	if (IsBotCasting(npcBot)) then
		return
	end

	--if (ConsiderItem(npcBot, blink) and ConsiderCast(npcBot, abilityR)) then
	--	if (GetUnitToUnitDistance(npcBot,PowUnit) <= blink:GetCastRange()) then
	--		npcBot:ActionImmediate_Chat("Wombo", true)
	--		npcBot:ActionPush_UseAbility(abilityR)
	--		npcBot:ActionPush_UseAbilityOnLocation(blink, PowUnit:GetLocation())
	--		return
	--	end
	--elseif (ConsiderCast(npcBot, abilityR)) then
	--	if (GetUnitToUnitDistance(npcBot,PowUnit) <= 600) then
	--		npcBot:ActionImmediate_Chat("eh", true)
	--		npcBot:Action_UseAbility(abilityR)
	--		return
	--	end
	--else
	--	return
	--end

	if (ConsiderCast(npcBot, abilityR)) then
		npcBot:ActionImmediate_Chat("eh", true)
		npcBot:Action_UseAbility(abilityR)
		return
	end

	--if (ConsiderCast(npcBot, abilityR) == 1 and PowUnit ~= nil and GetUnitToUnitDistance(npcBot,PowUnit) <= abilityR:GetCastRange()) then
	--	npcBot:Action_UseAbilityOnEntity(abilityR, PowUnit)
	--end


end

function Think()
	local npcBot = GetBot()
	local EHERO = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	local WeakestEHero,EHeroHealth = module.GetWeakestUnit(EHERO)
	local PowUnit,PowHealth = module.GetStrongestHero(EHERO)

	module.AbilityLevelUp(TideAbility)
	if (npcBot:GetLevel() >= 1 and PowUnit ~= nil) then
		castOrder(PowUnit, npcBot)
	end

	bot_generic.Think()
end
