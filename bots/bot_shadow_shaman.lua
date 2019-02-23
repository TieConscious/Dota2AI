local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")

local SKILL_Q = "shadow_shaman_ether_shock"
local SKILL_W = "shadow_shaman_voodoo"
local SKILL_E = "shadow_shaman_shackles"
local SKILL_R = "shadow_shaman_mass_serpent_ward"
local TALENT1 = "special_bonus_hp_200"
local TALENT2 = "special_bonus_exp_boost_20"
local TALENT3 = "special_bonus_cast_range_125"
local TALENT4 = "special_bonus_unique_shadow_shaman_5"
local TALENT5 = "special_bonus_unique_shadow_shaman_2"
local TALENT6 = "special_bonus_unique_shadow_shaman_1"
local TALENT7 = "special_bonus_unique_shadow_shaman_3"
local TALENT8 = "special_bonus_unique_shadow_shaman_4"

local Ability = {
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_R,
	SKILL_E,
	SKILL_W,
	SKILL_W,
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
 	local perHealth = module.CalcPerHealth(npcBot)
 	local currentMana = npcBot:GetMana()
 	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

 	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
 	local abilityW = npcBot:GetAbilityByName(SKILL_W)
 	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName("shadow_shaman_mass_serpent_ward")


 	local blink = module.ItemSlot(npcBot, "item_blink")
 	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")
 	local bkb = module.ItemSlot(npcBot, "item_black_king_bar")
	local shivas = module.ItemSlot(npcBot, "item_shivas_guard")


 	local manaQ = abilityQ:GetManaCost()
 	local manaW = abilityW:GetManaCost()
 	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()


 	if (eHeroList ~= nil and #eHeroList > 0) then
 		local target,eHealth = module.GetWeakestUnit(eHeroList)
 		local target2,eHealth2 = module.GetStrongestHero(eHeroList)
 		if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and manaPer <= 0.75) then
 			npcBot:Action_UseAbility(arcane)
 		end
 		if (not IsBotCasting() and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
 				and currentMana >= module.CalcManaCombo(manaW) and target ~= target2) then
 			npcBot:Action_UseAbilityOnEntity(abilityW, target2)
 		--elseif (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot,target) <= abilityR:GetCastRange()
 		--		and currentMana >= module.CalcManaCombo(manaR)) then
 		--	npcBot:Action_UseAbilityOnLocation(abilityR, target:GetLocation())
 		elseif (not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot,target) <= abilityE:GetCastRange()
 				and currentMana >= module.CalcManaCombo(manaE)) then
 			npcBot:Action_UseAbilityOnEntity(abilityE, target)
 		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot,target) <= abilityQ:GetCastRange()
 				and currentMana >= module.CalcManaCombo(manaQ)) then
 			npcBot:Action_UseAbilityOnEntity(abilityQ, target)
 		end
 		----Fuck'em up!----
 				--melee, miss when over 350
 		print("check 6")
 		if (not IsBotCasting()) then
 			if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK then
 				if GetUnitToUnitDistance(npcBot, target) <= hRange then
 					npcBot:Action_AttackUnit(target, true)
 				else
 					npcBot:Action_MoveToUnit(target)
 				end
 			end
 		end
 	end
 end

-- ----Pokes hero if within range----
-- --function Poke(target)
-- --	local perHealth = module.CalcPerHealth(npcBot)
-- --	local targetClose = module.CalcPerHealth(target)
-- --	local hRange = npcBot:GetAttackRange() - 50
-- --
-- --	if (GetUnitToUnitDistance(npcBot, target) <= hRange and npcBot:NumQueuedActions() == 0) then
-- --		AP_AttackUnit(npcBot, target, true)
-- --	end
-- --end
-- --
-- --function Hunt()
-- --	local perHealth = module.CalcPerHealth(npcBot)
-- --
-- --	local aHero = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
-- --	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
-- --	local aTowers = npcBot:GetNearbyTowers(700, false)
-- --
-- --	local target = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
-- --	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
-- --	local eTowers = npcBot:GetNearbyTowers(1000, true)
-- --
-- --
-- --	local powerRatio = module.CalcPowerRatio(npcBot, aHero, target)
-- --
-- --	if (target == nil or #target == 0) then
-- --		return
-- --	elseif (etowers ~= nil or #eTowers ~= 0) then
-- --		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= 725) then
-- --			return
-- --		end
-- --	else
-- --		local ePerHealth = module.CalcPerHealth(target[1])
-- --		if ((ePerHealth <= 0.75 or powerRatio <= 1 or #aTowers ~= 0) and eTowers == nil) then
-- --			Murder(target[1])
-- --		elseif (ePerHealth > 0.75) then
-- --			Poke(target[1])
-- --		end
-- --	end
-- --end

 function Think()
 	npcBot = GetBot()
 	local state = stateMachine.calculateState(npcBot)
 	print("check 1")
 	module.AbilityLevelUp(Ability)
 	if state.state == "hunt" then
 		print("check 2")
 		Murder()
 		print("check 3")
 	else
 		print("check 4")
 		behavior.generic(npcBot, state)
 		print("check 5")
 	end
 end