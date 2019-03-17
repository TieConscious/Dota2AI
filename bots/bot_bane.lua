local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

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
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local sheepStick = module.ItemSlot(npcBot, "item_sheepstick")
	local manaSheepStick = 250

	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()

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
		local target2,eHealth2 = module.GetStrongestHero(eHeroList)
		local targetFastAttack = module.HighestAttackSpeed(eHeroList)

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			----Try various combos on weakened enemy unit----
			if (not target:IsNightmared() and not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityE:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaE) and target ~= target2 and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityE, target)

			elseif (not target:IsNightmared() and not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target)

			elseif (not targetFastAttack:IsNightmared() and not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, targetFastAttack) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ) and targetFastAttack ~= target2 and not module.IsHardCC(targetFastAttack)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, targetFastAttack)

			elseif (target2 ~= nil and not target2:IsNightmared() and not IsBotCasting() and ConsiderCast(abilityR, abilityW) and GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW, manaR) and not module.IsHardCC(target2)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityR, target2)
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target2)

			elseif (target2 ~= nil and not target2:IsNightmared() and not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target2) <= abilityR:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaR)) then
				npcBot:Action_UseAbilityOnEntity(abilityR, target2)

			elseif (target2 ~= nil and not target:IsNightmared() and not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target)
			end
		end
		----Fuck'em up!----
		--ranged, wait til attack finish
		if (not IsBotCasting()) then
			npcBot:Action_AttackUnit(target, true)
		end

		if (module.CalcPerHealth(target) <= 0.15) then
			local ping = target:GetExtrapolatedLocation(1)
			npcBot:ActionImmediate_Ping(ping.x, ping.y, true)
		end
	end
end

function SpellRetreat()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local glimmer = module.ItemSlot(npcBot, "item_glimmer_cape")

	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaGlimmer = 90

	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsInvisible() and not npcBot:IsSilenced()) then
		local target = eHeroList[1]

		if (not IsBotCasting() and glimmer ~= nil and ConsiderCast(glimmer) and currentMana >= module.CalcManaCombo(manaGlimmer)) then
			npcBot:Action_UseAbilityOnEntity(glimmer, npcBot)

		elseif (not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityE:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaE) and target ~= target2 and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityE, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
				and currentMana >= module.CalcManaCombo(manaW)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)
		end

	end

end

function DangerPing()
	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

	if (eHeroList ~= nil and #eHeroList > 0 and #eHeroList > #aHeroList and npcBot:IsAlive()) then
		local dangerPing = eHeroList[1]:GetLocation()
		npcBot:ActionImmediate_Ping(dangerPing.x, dangerPing.y, false)
	end
end


function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	DangerPing()

	if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and currentMana <= (maxMana - 180)) then
		npcBot:Action_UseAbility(arcane)
		return
	end

	stateMachine.printState(state)
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