local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "juggernaut_blade_fury"
local SKILL_W = "juggernaut_healing_ward"
local SKILL_E = "juggernaut_blade_dance"
local SKILL_R = "juggernaut_omni_slash"
local TALENT1 = "special_bonus_all_stats_5"
local TALENT2 = "special_bonus_movement_speed_20"
local TALENT3 = "special_bonus_unique_juggernaut_4"
local TALENT4 = "special_bonus_attack_speed_20"
local TALENT5 = "special_bonus_armor_10"
local TALENT6 = "special_bonus_unique_juggernaut_3"
local TALENT7 = "special_bonus_hp_600"
local TALENT8 = "special_bonus_unique_juggernaut_2"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_W, --W
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_W, --W
	SKILL_W, --W
	TALENT1,
	SKILL_E, --E
	SKILL_R,
	SKILL_E, --E
	SKILL_E, --E
	TALENT4,
	SKILL_E, --E
	"nil",
	SKILL_R,
	"nil",
	TALENT5,
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
	local eCreepList = npcBot:GetNearbyLaneCreeps(800, true)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local phase = module.ItemSlot(npcBot, "item_phase_boots")
	local manta = module.ItemSlot(npcBot, "item_manta")
	local mjol = module.ItemSlot(npcBot, "item_mjollnir")
	local abyssal = module.ItemSlot(npcBot, "item_abyssal_blade")

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local manaManta = 125
	local manaMjol = 50
	local manaAbyssal = 75

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

		if (phase ~= nil and not IsBotCasting() and ConsiderCast(phase)) then
			npcBot:Action_UseAbility(phase)
		end

		if (abyssal ~= nil and not IsBotCasting() and ConsiderCast(abyssal) and currentMana >= manaAbyssal and GetUnitToUnitDistance(npcBot, target) <= abyssal:GetCastRange()
				and not module.IsHardCC(target) ) then
				npcBot:Action_UseAbilityOnEntity(abyssal, target)

		elseif (not IsBotCasting() and #eCreepList < 4 and ConsiderCast(abilityR) and currentMana >= module.CalcManaCombo(manaR)
				and GetUnitToUnitDistance(npcBot,eHeroList[1]) <= abilityR:GetCastRange()) then
			npcBot:Action_UseAbilityOnEntity(abilityR, eHeroList[1])

		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)) then
			if (GetUnitToUnitDistance(npcBot,target) <= 150) then
				npcBot:Action_UseAbility(abilityQ)
			else
				npcBot:Action_MoveToUnit(target)
			end

		elseif (mjol ~= nil and not IsBotCasting() and ConsiderCast(mjol) and currentMana >= manaMjol and GetUnitToUnitDistance(npcBot, target) <= 200) then
			npcBot:Action_UseAbilityOnEntity(mjol, npcBot)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)) then
			npcBot:Action_UseAbilityOnLocation(abilityW, npcBot:GetLocation())
		end

		if (manta ~= nil) then
			if (not IsBotCasting() and ConsiderCast(manta) and currentMana >= manaManta and GetUnitToUnitDistance(npcBot, target) <= 200) then
				npcBot:Action_UseAbility(manta)
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
	end
end


function SpellRetreat()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local phase = module.ItemSlot(npcBot, "item_phase_boots")

	local manaQ = abilityQ:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0) then

		if (phase ~= nil and not IsBotCasting() and ConsiderCast(phase)) then
			npcBot:Action_UseAbility(phase)

		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)) then
			npcBot:Action_UseAbility(abilityQ)
		end

	end

end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		Murder()
	elseif state.state == "retreat" then
		behavior.generic(npcBot, state)
		if (not npcBot:IsSilenced()) then
			SpellRetreat()
		end
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