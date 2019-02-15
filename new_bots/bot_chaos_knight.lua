local module = require(GetScriptDirectory().."/functions")
local bot_generic = require(GetScriptDirectory().."/bot_generic")
local cu  = require(GetScriptDirectory().."/chaos_util")

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
	local gameTime = DotaTime()
	local health = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local percentHealth = health/maxHealth
	local attackRange = npcBot:GetAttackRange()
	------Enemy and Creep stats----
	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(eCreeps)
	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(aCreeps)
	local eTowers = npcBot:GetNearbyTowers(700, true)
	local aTowers = npcBot:GetNearbyTowers(700, false)
	local eHeros = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local eWeakestHero,eWHeroHealth = module.GetWeakestUnit(EHERO)
	local eStrongest,eSHeroHealth = module.GetStrongestHero(EHERO)

	module.AbilityLevelUp(Ability)
	if (npcBot:GetLevel() >= 1 and PowUnit ~= nil) then
		castOrder(eWeakestHero)
	end

	if (gameTime <= 20) then
		cu.MTL_Start(npcBot)
	end

-- ----Last-hit Creep----
-- 	if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 2.5) then
-- 		if (eCreepHealth <= npcBot:GetAttackDamage() or #aCreeps == 0) then
-- 			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= attackRange) then
-- 				npcBot:Action_AttackUnit(eWeakestCreep, false)
-- 			else
-- 				npcBot:Action_AttackUnit(eWeakestCreep, false)
-- 				npcBot:ActionPush_MoveToUnit(eWeakestCreep)
-- 			end
-- 		end
-- 		if (GetUnitToUnitDistance(npcBot,WeakestCreep) > attackRange) then
-- 			npcBot:ActionPush_MoveToUnit(eWeakestCreep)
-- 		end
-- ----Deny creep----
-- 	elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetAttackDamage()) then
-- 		if (GetUnitToUnitDistance(npcBot,aWeakestCreep) <= attackRange) then
-- 			npcBot:Action_AttackUnit(aWeakestCreep, false)
-- 		end
-- ----Wack something----
-- 	elseif (eCreeps[1] ~= nil) then
-- 		if (GetUnitToUnitDistance(npcBot, eCreeps[1]) <= attackRange) then
-- 			npcBot:Action_AttackUnit(eCreeps[1], false)
-- 		else
-- 			npcBot:Action_AttackUnit(eCreeps[1], false)
-- 			npcBot:ActionPush_MoveToUnit(eCreeps[1])
-- 		end
-- 	else
-- 		cu.MTL_Farm(npcBot)
-- 	end

	bot_generic.Think()
end
