local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "ogre_magi_fireblast"
local SKILL_W = "ogre_magi_ignite"
local SKILL_E = "ogre_magi_bloodlust"
local SKILL_R = "ogre_magi_multicast"
local SKILL_UF = "ogre_magi_unrefined_fireblast"
local TALENT1 = "special_bonus_gold_income_15"
local TALENT2 = "special_bonus_cast_range_100"
local TALENT3 = "special_bonus_attack_damage_90"
local TALENT4 = "special_bonus_hp_300"
local TALENT5 = "special_bonus_strength_40"
local TALENT6 = "special_bonus_unique_ogre_magi"
local TALENT7 = "special_bonus_movement_speed_75"
local TALENT8 = "special_bonus_unique_ogre_magi_2"

local Ability = {
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_W,
	SKILL_R,
	SKILL_W,
	SKILL_Q,
	SKILL_Q,
	TALENT2,
	SKILL_E,
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


----Murder closest enemy hero----
function Murder()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local abilityUF = npcBot:GetAbilityByName(SKILL_UF)
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	if (abilityUF ~= nil) then
		local manaUF = abilityUF:GetManaCost()
	end

	if (eHeroList ~= nil and #eHeroList > 0) then
		local target = module.SmartTarget(npcBot)


		if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and manaPer <= 0.75) then
			npcBot:Action_UseAbility(arcane)
		end

		----Try various combos on weakened enemy unit----
		if (not IsBotCasting() and ConsiderCast(abilityW, abilityQ, abilityUF) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaQ, manaW, manaUF)) then
			npcBot:ActionPush_UseAbilityOnEntity(abilityUF, target)
			npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
			npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaQ)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaW)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityUF) and GetUnitToUnitDistance(npcBot, target) <= abilityUF:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaUF)) then
			npcBot:Action_UseAbilityOnEntity(abilityUF, target)

		elseif (aHeroList ~= nil and #aHeroList > 1 and not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot,aHeroList[2]) <= abilityE:GetCastRange()
				and GetUnitToUnitDistance(aHeroList[2],target) <= 250 and currentMana >= module.CalcManaCombo(manaE)) then
			npcBot:Action_UseAbilityOnEntity(abilityE, aHeroList[2])

		elseif (not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(aHeroList[1],target) <= 250 and currentMana >= module.CalcManaCombo(manaE)) then
			npcBot:Action_UseAbilityOnEntity(abilityE, aHeroList[1])
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

		if (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaQ)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaW)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)

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

	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and currentMana <= (maxMana - 180)) then
		npcBot:Action_UseAbility(arcane)
		return
	end

	--stateMachine.printState(state)
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