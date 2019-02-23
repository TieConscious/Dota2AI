local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")

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

local Ability = {
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

local npcBot = GetBot()

--local AP_AttackUnit = npcBot.ActionPush_AttackUnit
--local AP_MoveDirectly = npcBot.ActionPush_MoveDirectly
--local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit
--local UseAbilityEnemy = npcBot.ActionPush_UseAbilityOnEntity
--local UseAbility = npcBot.ActionPush_UseAbility

function IsBotCasting()
	return npcBot:IsChanneling()
		  or npcBot:IsUsingAbility()
		  or npcBot:IsCastingAbility()
end

function ConsiderCast(...)
	for k,v in pairs({...}) do
		if (v == nil or not v:IsFullyCastable()) then
			return false
		end
	end
	return true
end

----Murder closest enemy hero----
function Murder()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange()

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local blink = module.ItemSlot(npcBot, "item_blink")
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")
	local refresh = module.ItemSlot(npcBot, "item_refresher")

	local manaQ = abilityQ:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local manaRefresh = 375

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget()

		if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and manaPer <= 0.75) then
			npcBot:Action_UseAbility(arcane)
		end

		----Try various combos on weakened enemy unit----
		if (not IsBotCasting() and refresh ~= nil and ConsiderCast(abilityQ, abilityR, blink, refresh)
			and GetUnitToUnitDistance(npcBot, target) <= 1500 and currentMana >= module.CalcManaCombo(manaQ, manaR, manaRefresh, manaR)) then
			npcBot:ActionPush_UseAbility(abilityR)
			npcBot:ActionPush_UseAbility(refresh)
			npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
			npcBot:ActionPush_UseAbility(abilityR)
			npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())
		elseif (not IsBotCasting() and ConsiderCast(abilityQ, abilityR, blink)
				and GetUnitToUnitDistance(npcBot, target) <= 1500 and currentMana >= module.CalcManaCombo(manaQ, manaR, manaRefresh)) then
			npcBot:ActionPush_UseAbility(abilityR)
			npcBot:ActionPush_UseAbility(refresh)
			npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
			npcBot:ActionPush_UseAbility(abilityR)
			npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())
		elseif (not IsBotCasting() and refresh ~= nil and ConsiderCast(abilityR, refresh) and GetUnitToUnitDistance(npcBot, target) <= 800
				and currentMana >= module.CalcManaCombo(manaR, refresh, manaR)) then
			npcBot:ActionPush_UseAbility(abilityR)
			npcBot:ActionPush_UseAbility(refresh)
			npcBot:ActionPush_UseAbility(abilityR)
		elseif (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target) <= 800 and currentMana >= module.CalcManaCombo(manaR)) then
			npcBot:Action_UseAbility(abilityR)
		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaR)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)
		elseif (not IsBotCasting() and ConsiderCast(abilityE)) then
			npcBot:Action_UseAbility(abilityE)
		end
		----Fuck'em up!----
		--melee, miss when over 350
		if (not IsBotCasting()) then
			if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK then
				if GetUnitToUnitDistance(npcBot, target) > 350 then
					npcBot:Action_MoveToUnit(target)
				end
			else
				if (GetUnitToUnitDistance(npcBot, target) <= hRange) then
					npcBot:Action_AttackUnit(target, true)
				else
					npcBot:Action_MoveToUnit(target)
				end
			end
		end
	end

end

----Pokes hero if within range----
--function Poke(target)
--	local perHealth = module.CalcPerHealth(npcBot)
--	local targetClose = module.CalcPerHealth(target)
--	local hRange = npcBot:GetAttackRange()
--
--	if (GetUnitToUnitDistance(npcBot, target) <= hRange) then
--		AP_AttackUnit(npcBot, target, true)
--	end
--end
--
--function Hunt()
--	local perHealth = module.CalcPerHealth(npcBot)
--
--	local aHero = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
--	local aTowers = npcBot:GetNearbyTowers(700, false)
--
--	local target = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
--	local eTowers = npcBot:GetNearbyTowers(1000, true)
--
--
--	local powerRatio = module.CalcPowerRatio(npcBot, aHero, target)
--
--	if (target == nil or #target == 0) then
--		return
--	elseif (etowers ~= nil or #eTowers ~= 0) then
--		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= 725) then
--			return
--		end
--	else
--		local ePerHealth = module.CalcPerHealth(target[1])
--		if ((ePerHealth <= 0.75 or powerRatio <= 1 or #aTowers ~= 0) and eTowers == nil) then
--			Murder(target[1])
--		elseif (ePerHealth > 0.75) then
--			Poke(target[1])
--		end
--	end
--end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		Murder()
	else
		behavior.generic(npcBot, state)
	end
end