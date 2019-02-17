local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")

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

----Murder closest enemy hero----
function Murder(target)
	local perHealth = module.CalcPerHealth(npcBot)
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	if (eHeroList ~= nil or #eHeroList > 0) then
		local target = module.GetWeakestUnit(eHeroList)
	end

	if (not IsBotCasting() and ConsiderCast(abilityR) == 1 and ConsiderCast(abilityW) == 1 and ConsiderCast(abilityQ) == 1 and manaPer >= 0.5 and GetUnitToUnitDistance(npcBot,target) <= abilityW:GetCastRange()) then
			npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
			npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
			npcBot:ActionPush_UseAbility(abilityR)
	elseif (not IsBotCasting() and ConsiderCast(abilityW) == 1 and ConsiderCast(abilityQ) == 1 and GetUnitToUnitDistance(npcBot,target) <= abilityW:GetCastRange() and manaPer >= 0.4) then
		npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
		npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
	elseif (not IsBotCasting() and ConsiderCast(abilityQ) == 1 and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange() and manaPer >= 0.3) then
		npcBot:Action_UseAbilityOnEntity(abilityQ, target)
	elseif (not IsBotCasting() and ConsiderCast(abilityW) == 1 and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange() and manaPer >= 0.3) then
		npcBot:Action_UseAbilityOnEntity(abilityW, target)
	end

	----Fuck'em up!----
	if (not IsBotCasting()) then
		if (GetUnitToUnitDistance(npcBot, target) <= hRange) then
			npcBot:Action_AttackUnit(target, true)
		else
			npcBot:Action_MoveToUnit(target)
		end
	end

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
