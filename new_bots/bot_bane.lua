local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")

local SKILL_Q = "bane_enfeeble"
local SKILL_W = "bane_brain_sap"
local SKILL_E = "bane_nightmare"
local SKILL_R = "bane_fiends_grip"
local TALENT1 = "special_bonus_armor_7"
local TALENT2 = "special_bonus_cast_range_100"
local TALENT3 = "special_bonus_unique_bane_4"
local TALENT4 = "special_bonus_exp_boost_40"
local TALENT5 = "special_bonus_unique_bane_1"
local TALENT6 = "special_bonus_movement_speed_50"
local TALENT7 = "special_bonus_unique_bane_2"
local TALENT8 = "special_bonus_unique_bane_3"

local Ability = {
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_R,
	SKILL_W,
	SKILL_E,
	SKILL_E,
	TALENT2,
	SKILL_E,
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

----Check whether an item is useable----
function ConsiderItem(Item)
	if (Item == nil or not Item:IsFullyCastable()) then
		return 0
	end

	return 1
end

----Check whether we can use an ability or not----
function ConsiderCast(ability)
	if (not ability:IsFullyCastable()) then
		return 0
	end

	return 1
end

--function CompareEnemyHealth(eHero, )
--	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--
--	return target
--end

----Murder closest enemy hero----
function Murder()
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	if (eHeroList ~= nil or #eHeroList > 0) then
		local target = module.GetWeakestUnit(eHeroList)
	end

	----Try various combos on weakened enemy unit----
	if (not IsBotCasting() and ConsiderCast(abilityR) == 1 and ConsiderCast(abilityW) == 1 and ConsiderCast(abilityQ) == 1 and manaPer >= 0.5 and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
		npcBot:ActionPush_UseAbilityOnEntity(abilityR, target)
		npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
		npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
	elseif (not IsBotCasting() and ConsiderCast(abilityR) == 1 and manaPer >= 0.5 and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange()) then
		npcBot:Action_UseAbilityOnEntity(abilityR, target)
	elseif (not IsBotCasting() and ConsiderCast(abilityW) == 1 and manaPer >= 0.4 and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
		npcBot:Action_UseAbilityOnEntity(abilityW, target)
	end
	----Fuck'em up!----
	if (not IsBotCasting()) then
		if (GetUnitToUnitDistance(npcBot, target) <= hRange) then
			npcBot:Action_AttackUnit(target, true)
		else
			npcBot:Action_MoveToUnit(target)
		end
	end

end

----Pokes hero if within range----
--function Poke(eHero)
--	local perHealth = module.CalcPerHealth(npcBot)
--	local eHeroClose = module.CalcPerHealth(eHero)
--	local hRange = npcBot:GetAttackRange() - 25
--
--	if (GetUnitToUnitDistance(npcBot, eHero) <= hRange and npcBot:NumQueuedActions() == 0) then
--		npcBot:Action_AttackUnit(eHero, true)
--	end
--end

--function Hunt()
--	local perHealth = module.CalcPerHealth(npcBot)
--
--	local aHero = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
--	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
--	local aTowers = npcBot:GetNearbyTowers(700, false)
--
--	local eHero = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
--	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
--	local eTowers = npcBot:GetNearbyTowers(1000, true)
--
--
--	local powerRatio = module.CalcPowerRatio(npcBot, aHero, eHero)
--
--	if (eHero == nil or #eHero == 0) then
--		return
--	elseif (eTowers ~= nil or #eTowers > 0) then
--		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= 300) then
--			return
--		else
--			local ePerHealth = module.CalcPerHealth(eHero[1])
--			if (ePerHealth <= 0.75 or powerRatio <= 1 or #aTowers ~= 0) then
--				Murder(eHero[1])
--			elseif (ePerHealth > 0.75) then
--				Poke(eHero[1])
--			end
--		end
--	else
--		local ePerHealth = module.CalcPerHealth(eHero[1])
--		if (ePerHealth <= 0.75 or powerRatio <= 1 or #aTowers ~= 0) then
--			Murder(eHero[1])
--		elseif (ePerHealth > 0.75) then
--			Poke(eHero[1])
--		end
--	end
--end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	stateMachine.printState(state)

	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		Murder()
	else
		behavior.generic(npcBot, state)
	end
end
