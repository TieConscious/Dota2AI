local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

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
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange()

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local sheepStick = module.ItemSlot(npcBot, "item_sheepstick")
	local blink = module.ItemSlot(npcBot, "item_blink")
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")
	local refresh = module.ItemSlot(npcBot, "item_refresher")
	local shivas = module.ItemSlot(npcBot, "item_shivas_guard")

	local manaQ = abilityQ:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local manaRefresh = 375
	local manaShivas = 100

	if (not IsBotCasting() and stick ~= nil and ConsiderCast(stick) and stick:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (stick:GetCurrentCharges() * 15))) then
		npcBot:Action_UseAbility(stick)
		return
	end

	if (not IsBotCasting() and wand ~= nil and ConsiderCast(wand) and wand:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (wand:GetCurrentCharges() * 15))) then
		npcBot:Action_UseAbility(wand)
		return
	end

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget(npcBot)

		----Try various combos on weakened enemy unit----
		if (not npcBot:IsSilenced()) then
			if (not IsBotCasting() and refresh ~= nil and blink ~= nil and ConsiderCast(abilityQ, abilityR, blink, refresh)
				and GetUnitToUnitDistance(npcBot, target) <= 1500 and currentMana >= module.CalcManaCombo(manaQ, manaR, manaRefresh, manaR)) then
				npcBot:ActionPush_UseAbility(refresh)
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())

			elseif (not IsBotCasting() and blink ~= nil and ConsiderCast(abilityQ, abilityR, blink)
					and GetUnitToUnitDistance(npcBot, target) <= 1500 and currentMana >= module.CalcManaCombo(manaQ, manaR)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())

			elseif (not IsBotCasting() and refresh ~= nil and ConsiderCast(abilityR, refresh) and GetUnitToUnitDistance(npcBot, target) <= 800
					and currentMana >= module.CalcManaCombo(manaR, refresh, manaR)) then
				npcBot:ActionPush_UseAbility(refresh)
				npcBot:ActionPush_UseAbility(abilityR)

			elseif (not IsBotCasting() and blink ~= nil and ConsiderCast(abilityR, blink) and GetUnitToUnitDistance(npcBot, target) <= 1500 and currentMana >= module.CalcManaCombo(manaR)) then
				npcBot:Action_UseAbility(abilityR)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target) <= 800 and currentMana >= module.CalcManaCombo(manaR)) then
				npcBot:Action_UseAbility(abilityR)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

			elseif (not IsBotCasting() and #eHeroList > 1 and shivas ~= nil and ConsiderCast(shivas) and GetUnitToUnitDistance(npcBot, target) <= 600
					and currentMana >= module.CalcManaCombo(manaShivas) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbility(shivas)

			elseif (not IsBotCasting() and ConsiderCast(abilityE)) then
				npcBot:Action_UseAbility(abilityE)
			end
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

		if (module.CalcPerHealth(target) <= 0.15) then
			local ping = target:GetExtrapolatedLocation(1)
			npcBot:ActionImmediate_Ping(ping.x, ping.y, true)
		end
	end

end

function SpellRetreat()
	npcBot = GetBot()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)

	local manaQ = abilityQ:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = eHeroList[1]

		if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
			and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)
		end
	end
end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and currentMana <= (maxMana - 180)) then
		npcBot:Action_UseAbility(arcane)
		return
	end

	--stateMachine.printState(state)
	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		Murder()
	elseif state.state == "retreat" then
		behavior.generic(npcBot, state)
		if (not npcBot:IsSilenced()) then
			SpellRetreat()
		end
	elseif state.state == "finishHim" then
		behavior.generic(npcBot, state)
		Murder()
	else
		behavior.generic(npcBot, state)
	end
end

function MinionThink(hMinionUnit)
	local state = minionStateMachine.calculateState(hMinionUnit)
	--stateMachine.printState(state)
	local master = GetBot()
	if (hMinionUnit == nil) then
		return
	end

	if hMinionUnit:IsIllusion() then
		minionBehavior.generic(hMinionUnit, master, state)
	else
		return
	end
end