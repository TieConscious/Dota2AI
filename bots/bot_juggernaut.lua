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
	SKILL_E, --W
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_E, --W
	SKILL_E, --W
	TALENT1,
	SKILL_W, --E
	SKILL_R,
	SKILL_W, --E
	SKILL_W, --E
	TALENT4,
	SKILL_W, --E
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

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()


	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget(npcBot)



		if (not IsBotCasting() and #eCreepList < 4 and ConsiderCast(abilityR) and currentMana >= module.CalcManaCombo(manaR)
				and GetUnitToUnitDistance(npcBot,eHeroList[1]) <= abilityR:GetCastRange()) then
			npcBot:Action_UseAbilityOnEntity(abilityR, eHeroList[1])
		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)) then
			if (GetUnitToUnitDistance(npcBot,target) <= 150) then
				npcBot:Action_UseAbility(abilityQ)
			else
				npcBot:Action_MoveToUnit(target)
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

----Pokes hero if within range----
--function Poke(target)
--	local perHealth = module.CalcPerHealth(npcBot)
--	local targetClose = module.CalcPerHealth(target)
--	local hRange = npcBot:GetAttackRange() - 50
--
--	if (GetUnitToUnitDistance(npcBot, target) <= hRange and npcBot:NumQueuedActions() == 0) then
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

function SpellRetreat()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)

	local manaQ = abilityQ:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0) then

		if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)) then
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
		SpellRetreat()
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