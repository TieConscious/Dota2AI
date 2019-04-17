local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "skeleton_king_hellfire_blast"
local SKILL_W = "skeleton_king_vampiric_aura"
local SKILL_E = "skeleton_king_mortal_strike"
local SKILL_R = "skeleton_king_reincarnation"
local TALENT1 = "special_bonus_unique_wraith_king_7"
local TALENT2 = "special_bonus_attack_speed_20"
local TALENT3 = "special_bonus_strength_15"
local TALENT4 = "special_bonus_unique_wraith_king_6"
local TALENT5 = "special_bonus_unique_wraith_king_1"
local TALENT6 = "special_bonus_unique_wraith_king_8"
local TALENT7 = "special_bonus_unique_wraith_king_2"
local TALENT8 = "special_bonus_unique_wraith_king_4"


local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_E,
	SKILL_E,
	TALENT1,
	SKILL_E,
	SKILL_R,
	SKILL_W,
	SKILL_W,
	TALENT3,
	SKILL_W,
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

function skeleCharge()
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	return abilityE:GetLevel() * 2
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
	local abyssal = module.ItemSlot(npcBot, "item_abyssal_blade")

	local manaQ = abilityQ:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local eCharges = npcBot:GetModifierStackCount(npcBot:GetModifierByName("modifier_skeleton_king_mortal_strike"))
	local manaR = abilityR:GetManaCost()
	local manaAbyssal = 75

	if abilityR:IsCooldownReady() and abilityR:IsTrained() then
		currentMana = currentMana - manaR
	end
	--GetModifierStackCount(modifier_skeleton_king_mortal_strike_summon)

-- 	modifier_skeleton_king_vampiric_aura_buff
-- modifier_skeleton_king_mortal_strike_summon_thinker
-- modifier_skeleton_king_mortal_strike
-- modifier_skeleton_king_mortal_strike_summon

	--if eHeroList ~= nil or #eHeroList >= 0 then
	--	print(abilityQ)
	--	npcBot:Action_UseAbilityOnEntity(abilityQ, target)
	--end

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

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			if (phase ~= nil and not IsBotCasting() and ConsiderCast(phase)) then
				npcBot:Action_UseAbility(phase)
			end

			if (abyssal ~= nil and not IsBotCasting() and ConsiderCast(abyssal) and currentMana >= module.CalcManaCombo(manaAbyssal)
					and GetUnitToUnitDistance(npcBot, target) <= abyssal:GetCastRange() and not module.IsHardCC(target) ) then
				npcBot:Action_UseAbilityOnEntity(abyssal, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityE) and eCharges > 0 and currentMana >= module.CalcManaCombo(manaE) and manaPer >= 0.75) then
				npcBot:Action_UseAbility(abilityE)
			end
		end

		----Fuck'em up!----
				--melee, miss when over 350
		if (not IsBotCasting() and not target:IsNightmared()) then
			if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK and npcBot:GetTarget() == target then
				if GetUnitToUnitDistance(npcBot, target) > 350 then
					npcBot:Action_MoveToUnit(target)
				end
			else
				npcBot:Action_AttackUnit(target, true)
			end
		end

		module.ConsiderKillPing(npcBot, target)
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

		--elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ,) and GetUnitToUnitDistance(npcBot, eHeroList[1]) <= 800) then
		--	npcBot:Action_UseAbility(abilityQ)
		end

	end

end



function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	module.DangerPing(npcBot)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		Murder()
	elseif state.state == "retreat" then
		behavior.generic(npcBot, state)
		if (not npcBot:IsSilenced() and not npcBot:IsSilenced()) then
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