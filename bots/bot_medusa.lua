local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "medusa_split_shot"
local SKILL_W = "medusa_mystic_snake"
local SKILL_E = "medusa_mana_shield"
local SKILL_R = "medusa_stone_gaze"
local TALENT1 = "special_bonus_attack_damage_15"
local TALENT2 = "special_bonus_evasion_15"
local TALENT3 = "special_bonus_attack_speed_30"
local TALENT4 = "special_bonus_unique_medusa_3"
local TALENT5 = "special_bonus_unique_medusa_5"
local TALENT6 = "special_bonus_unique_medusa"
local TALENT7 = "special_bonus_mp_1000"
local TALENT8 = "special_bonus_unique_medusa_4"

local Ability = {
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_Q,
	TALENT1,
	SKILL_R,
	SKILL_R,
	SKILL_E,
	SKILL_E,
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

function ConsiderCast(...)
	for k,v in pairs({...}) do
		if (v == nil or not v:IsFullyCastable()) then
			return false
		end
	end
	return true
end

function ConsiderW()
	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local eCreepList = npcBot:GetNearbyLaneCreeps(1400, true)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local considerW = nil
	if abilityW:GetLevel() >= 1 and eHeroList ~= nil and #eHeroList > 0 then
		if #eHeroList > 2 then
			considerW = eHeroList[1]
		elseif eCreepList ~= nil and #eCreepList > 0 and #eCreepList - 2 < abilityW:GetLevel() then
			considerW = eCreepList[1]
		end

	end
	return considerW
end

----Murder closest enemy hero----
function Murder(eHero)
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local eCreepList = npcBot:GetNearbyLaneCreeps(1400, true)

	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local manta = module.ItemSlot(npcBot, "item_manta")
	local hurricane = module.ItemSlot(npcBot, "item_hurricane_pike")
	local mjol = module.ItemSlot(npcBot, "item_mjollnir")
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")

	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local manaManta = 125
	local manaHurricane = 100
	local manaMjol = 50


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
		local bounce = module.BounceSpells(npcBot, 475)
		local wTarget = ConsiderW()

		if (not npcBot:IsSilenced()) then
			if (not IsBotCasting() and hurricane ~= nil and ConsiderCast(hurricane) and currentMana >= module.CalcManaCombo(manaHurricane)
				and GetUnitToUnitDistance(npcBot, eHeroList[1]) <= 250) then
				npcBot:Action_UseAbilityOnEntity(hurricane, eHeroList[1])

			elseif (ConsiderCast(abilityE) and not abilityE:GetToggleState()) then
				npcBot:Action_UseAbility(abilityE)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and #eHeroList > #aHeroList and #eHeroList + #aHeroList > 4 and currentMana >= module.CalcManaCombo(manaR)
					and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange() and target:IsFacingLocation(npcBot:GetLocation(), 50)) then
				npcBot:Action_UseAbility(abilityR)

			elseif (not IsBotCasting() and wTarget ~= nil and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
					and GetUnitToUnitDistance(npcBot, wTarget) <= abilityW:GetCastRange()) then
				npcBot:Action_UseAbilityOnEntity(abilityW, wTarget)

			elseif (mjol ~= nil and not IsBotCasting() and ConsiderCast(mjol) and currentMana >= manaMjol and GetUnitToUnitDistance(npcBot, target) <= 200) then
				npcBot:Action_UseAbilityOnEntity(mjol, npcBot)

			end

			if (manta ~= nil) then
				if (not IsBotCasting() and ConsiderCast(manta) and currentMana >= manaManta) then
					npcBot:Action_UseAbility(manta)
				end
			end
		end


		----Fuck'em up!----
		if (not IsBotCasting()) then
			if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK then
				npcBot:Action_AttackUnit(target, true)
			end
		end

		module.ConsiderKillPing(npcBot, target)
	end
end


function SpellRetreat()
	npcBot = GetBot()

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local hurricane = module.ItemSlot(npcBot, "item_hurricane_pike")

	local manaHurricane = 100


	if (eHeroList ~= nil and #eHeroList > 0) then
		if (not npcBot:IsSilenced()) then
			if (ConsiderCast(abilityE) and not abilityE:GetToggleState()) then
				npcBot:Action_UseAbility(abilityE)

			elseif (not IsBotCasting() and hurricane ~= nil and ConsiderCast(hurricane) and currentMana >= module.CalcManaCombo(manaHurricane)
					and GetUnitToUnitDistance(npcBot, eHeroList[1]) <= hurricane:GetCastRange()) then
				npcBot:Action_UseAbilityOnEntity(hurricane, eHeroList[1])
			end
		end
	end
end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)
	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityE = npcBot:GetAbilityByName(SKILL_E)

	if (eHeroList == nil or #eHeroList == 0) then
		if (not npcBot:IsSilenced()) then
			if (ConsiderCast(abilityE) and abilityE:GetToggleState()) then
				npcBot:Action_UseAbility(abilityE)
				return
			end
		end
	end

	module.DangerPing(npcBot)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
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