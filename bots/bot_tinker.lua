local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "tinker_laser"
local SKILL_W = "tinker_heat_seeking_missile"
local SKILL_E = "tinker_march_of_the_machines"
local SKILL_R = "tinker_rearm"
local TALENT1 = "special_bonus_spell_amplify_6"
local TALENT2 = "special_bonus_cast_range_75"
local TALENT3 = "special_bonus_movement_speed_30"
local TALENT4 = "special_bonus_spell_lifesteal_10"
local TALENT5 = "special_bonus_armor_10"
local TALENT6 = "special_bonus_unique_tinker_2"
local TALENT7 = "special_bonus_unique_tinker"
local TALENT8 = "special_bonus_unique_tinker_3"


local Ability = {
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_E,
	SKILL_R,
	SKILL_E,
	SKILL_E,
	TALENT1,
	TALENT3,
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
--local npcBot:Action_AttackUnit = npcBot:ActionPush_AttackUnit
--local AP_MoveDirectly = npcBot:ActionPush_MoveDirectly
--local AP_MoveToUnit = npcBot:ActionPush_MoveToUnit
--local UseAbilityEnemy = npcBot:Action_UseAbilityOnEntity
--local UseAbility = npcBot:ActionPush_UseAbility

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

--function CompareEnemyHealth(eHero, )
--	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--
--	return target
--end

----Murder closest enemy hero----
function Murder()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local sheepStick = module.ItemSlot(npcBot, "item_sheepstick")
	local shivas = module.ItemSlot(npcBot, "item_shivas_guard")


	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()

	local manaSheepStick = 250
	local manaShivas = 100


	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget(npcBot)

		if (not npcBot:IsSilenced()) then
			----Try various combos on weakened enemy unit----
			if (not IsBotCasting() and ConsiderCast(abilityR, abilityW, abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ, manaW, manaR, manaQ, manaW)) then
				npcBot:ActionPush_UseAbility(abilityW)
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
				npcBot:ActionPush_UseAbility(abilityR)
				npcBot:ActionPush_UseAbility(abilityW)
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)

			elseif (not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW)) then
				npcBot:Action_UseAbility(abilityW)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ, abilityW) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ, manaW)) then
				npcBot:ActionPush_UseAbility(abilityW)
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)

				----add ag's combo----
			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

			elseif (not IsBotCasting() and #eHeroList > 1 and shivas ~= nil and ConsiderCast(shivas) and GetUnitToUnitDistance(npcBot, target) <= 600
					and currentMana >= module.CalcManaCombo(manaShivas) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbility(shivas)

			elseif (not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityE:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaE)) then
				local smartAOEE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), abilityE:GetCastRange(), abilityE:GetAOERadius(), 0.9, 1000000)
				npcBot:Action_UseAbilityOnLocation(abilityE, smartAOEE.targetloc)
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

		module.ConsiderKillPing(npcBot, target)

	end
end

function UseE()
	local currentMana = npcBot:GetMana()
	local eCreepList = npcBot:GetNearbyLaneCreeps(800, true)

	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local manaE = abilityE:GetManaCost()

	if (not IsBotCasting() and eCreepList~= nil and #eCreepList >= 4 and ConsiderCast(abilityE) and currentMana >= module.CalcManaCombo(manaE)) then
		local smartAOEE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), abilityE:GetCastRange(), abilityE:GetAOERadius(), 0.9, 1000000)
		npcBot:Action_UseAbilityOnLocation(abilityE, smartAOEE.targetloc)
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

	module.DangerPing(npcBot)

	module.AbilityLevelUp(Ability)

	if state.state == "hunt" then
		--implement custom hero hunting here
		Murder()
	elseif state.state == "farm" or state.state == "tower" then
		UseE()
		behavior.generic(npcBot, state)
	elseif state.state == "finishHim" then
		behavior.generic(npcBot, state)
		Murder()
	else
		behavior.generic(npcBot, state)
	end
end

function MinionThink(hMinionUnit)
	local state = minionStateMachine.calculateState(hMinionUnit)
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