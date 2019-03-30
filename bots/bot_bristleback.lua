local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "bristleback_viscous_nasal_goo"
local SKILL_W = "bristleback_quill_spray"
local SKILL_E = "bristleback_bristleback"
local SKILL_R = "bristleback_warpath"
local TALENT1 = "special_bonus_movement_speed_20"
local TALENT2 = "special_bonus_mp_regen_3"
local TALENT3 = "special_bonus_hp_250"
local TALENT4 = "special_bonus_unique_bristleback"
local TALENT5 = "special_bonus_hp_regen_25"
local TALENT6 = "special_bonus_unique_bristleback_2"
local TALENT7 = "special_bonus_spell_lifesteal_15"
local TALENT8 = "special_bonus_unique_bristleback_3"


local Ability = {
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_R,
	SKILL_W,
	SKILL_E,
	SKILL_E,
	TALENT2,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_Q,
	TALENT3,
	SKILL_Q,
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
	local aHeroList = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)


	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local pipe = module.ItemSlot(npcBot, "item_pipe")
	local buckler = module.ItemSlot(npcBot, "item_recipe_buckler")
	local crimson = module.ItemSlot(npcBot, "item_crimson_guard")
	local solar = module.ItemSlot(npcBot, "item_solar_crest")


	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaPipe = 100
	local manaBuckler = 10


	if (not IsBotCasting() and stick ~= nil and ConsiderCast(stick) and stick:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (stick:GetCurrentCharges() * 15))) then
		npcBot:Action_UseAbility(stick)
		return
	end

	if (not IsBotCasting() and wand ~= nil and ConsiderCast(wand) and wand:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (wand:GetCurrentCharges() * 15))) then
		npcBot:Action_UseAbility(wand)
		return
	end

	if (not IsBotCasting() and buckler ~= nil and ConsiderCast(buckler) and currentMana >= module.CalcManaCombo(manaBuckler)) then
		npcBot:Action_UseAbility(buckler)
		return
	end

	if (not IsBotCasting() and crimson ~= nil and ConsiderCast(crimson)and #aHeroList > 1 and #eHeroList > 1) then
		npcBot:Action_UseAbility(crimson)
		return
	end

	if (not IsBotCasting() and pipe ~= nil and ConsiderCast(pipe) and currentMana >= module.CalcManaCombo(manaPipe) and #aHeroList > 1 and #eHeroList > 1) then
		npcBot:Action_UseAbility(pipe)
		return
	end

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget(npcBot)

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			if (not IsBotCasting() and solar ~= nil and ConsiderCast(solar)
					and GetUnitToUnitDistance(npcBot, target) <= solar:GetCastRange()) then
				npcBot:Action_UseAbilityOnEntity(solar, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
					and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
				npcBot:Action_UseAbility(abilityW)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)
					and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)
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


function Think()
	local npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	module.DangerPing(npcBot)

	--stateMachine.printState(state)
	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		Murder()
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