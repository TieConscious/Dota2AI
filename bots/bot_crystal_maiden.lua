local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "crystal_maiden_crystal_nova"
local SKILL_W = "crystal_maiden_frostbite"
local SKILL_E = "crystal_maiden_brilliance_aura"
local SKILL_R = "crystal_maiden_freezing_field"
local TALENT1 = "special_bonus_hp_250"
local TALENT2 = "special_bonus_cast_range_100"
local TALENT3 = "special_bonus_unique_crystal_maiden_4"
local TALENT4 = "special_bonus_gold_income_25"
local TALENT5 = "special_bonus_attack_speed_250"
local TALENT6 = "special_bonus_unique_crystal_maiden_3"
local TALENT7 = "special_bonus_unique_crystal_maiden_1"
local TALENT8 = "special_bonus_unique_crystal_maiden_2"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_E,
	SKILL_R,
	SKILL_E,
	SKILL_Q,
	SKILL_Q,
	TALENT2,
	SKILL_Q,
	SKILL_R,
	SKILL_W,
	SKILL_W,
	TALENT4,
	SKILL_W,
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


----Function pointers----
--local AP_AttackUnit = npcBot.ActionPush_AttackUnit
--local AP_MoveDirectly = npcBot.ActionPush_MoveDirectly
--local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit
--local UseAbilityEnemy = npcBot.ActionPush_UseAbilityOnEntity
--local UseAbility = npcBot.ActionPush_UseAbility

----Checks whether bot is in process of casting an ability----
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
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local blink = module.ItemSlot(npcBot, "item_blink")
	local bkb = module.ItemSlot(npcBot, "item_black_king_bar")
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()


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

		if (not npcBot:IsSilenced()) then
			if (not IsBotCasting() and ConsiderCast(abilityW, abilityQ) and currentMana >= module.CalcManaCombo(manaQ, manaW)) then
				if (GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
					npcBot:ActionPush_UseAbilityOnLocation(abilityQ, target:GetLocation())
					npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
				elseif (GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()) then
					npcBot:Action_UseAbilityOnLocation(abilityQ, target:GetLocation())
				end

			elseif (not IsBotCasting() and bkb ~= nil and #eHeroList > 1 and ConsiderCast(blink, abilityR, bkb) and currentMana >= module.CalcManaCombo(manaR)
					and GetUnitToUnitDistance(npcBot, target) <= 1300) then
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbility(bkb)
				npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())

			elseif (not IsBotCasting() and #eHeroList > 1 and ConsiderCast(blink, abilityR) and currentMana >= module.CalcManaCombo(manaR)
					and GetUnitToUnitDistance(npcBot, target) <= 1300) then
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbilityOnLocation(blink, target:GetLocation())

			elseif (not IsBotCasting() and bkb ~= nil and ConsiderCast(abilityR, bkb) and GetUnitToUnitDistance(npcBot, target) <= 250
					and currentMana >= module.CalcManaCombo(manaR) and not module.IsHardCC(target)) then
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbility(bkb)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target) <= 250
					and currentMana >= module.CalcManaCombo(manaR)) then
				npcBot:Action_UseAbility(abilityR)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnLocation(abilityQ, target:GetLocation())

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnLocation(abilityW, target:GetLocation())
			end
		end

		----Fuck'em up!----
		--ranged, wait til attack finish
		if (not IsBotCasting()) then
			if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK then
				if GetUnitToUnitDistance(npcBot, target) <= hRange then
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
	local abilityW = npcBot:GetAbilityByName(SKILL_W)

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = eHeroList[1]

		if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
			and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
			and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)
		end
	end
end


function Think()
	local npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

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