local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "phantom_assassin_stifling_dagger"
local SKILL_W = "phantom_assassin_phantom_strike"
local SKILL_E = "phantom_assassin_blur"
local SKILL_R = "phantom_assassin_coup_de_grace"
local TALENT1 = "special_bonus_hp_150"
local TALENT2 = "special_bonus_attack_damage_15"
local TALENT3 = "special_bonus_lifesteal_15"
local TALENT4 = "special_bonus_cleave_25"
local TALENT5 = "special_bonus_corruption_4"
local TALENT6 = "special_bonus_unique_phantom_assassin_3"
local TALENT7 = "special_bonus_unique_phantom_assassin_2"
local TALENT8 = "special_bonus_unique_phantom_assassin"

local Ability = {
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_W,
	SKILL_W,
	TALENT2,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_E,
	TALENT4,
	SKILL_E,
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
	local abilityE = npcBot:GetAbilityByName(SKILL_E)

	local manta = module.ItemSlot(npcBot, "item_manta")
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")


	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaManta = 125


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
			if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)
					and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)
			elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
					and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
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

	local abilityE = npcBot:GetAbilityByName(SKILL_E)

	local manaE = abilityE:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = eHeroList[1]

		if (not IsBotCasting() and ConsiderCast(abilityE) and currentMana >= module.CalcManaCombo(manaE)) then
			npcBot:Action_UseAbility(abilityE)
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