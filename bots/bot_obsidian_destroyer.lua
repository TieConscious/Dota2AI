local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "obsidian_destroyer_arcane_orb"
local SKILL_W = "obsidian_destroyer_astral_imprisonment"
local SKILL_E = "obsidian_destroyer_equilibrium"
local SKILL_R = "obsidian_destroyer_sanity_eclipse"
local TALENT1 = "special_bonus_hp_250"
local TALENT2 = "special_bonus_attack_speed_20"
local TALENT3 = "special_bonus_movement_speed_25"
local TALENT4 = "special_bonus_armor_6"
local TALENT5 = "special_bonus_strength_20"
local TALENT6 = "special_bonus_unique_outworld_devourer"
local TALENT7 = "special_bonus_unique_outworld_devourer"
local TALENT8 = "special_bonus_spell_lifesteal_15"

local Ability = {
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	SKILL_W,
	SKILL_W,
	SKILL_R,
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	TALENT2,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_E,
	TALENT3,
	SKILL_E,
	"nil",
	SKILL_R,
	"nil",
	TALENT6,
	"nil",
	"nil",
	"nil",
	"nil",
	TALENT7
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


--Murder closest enemy hero----
function Murder()
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	----abilities----
	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)

	----items----
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local sheepStick = module.ItemSlot(npcBot, "item_sheepstick")
	local hurricane = module.ItemSlot(npcBot, "item_hurricane_pike")
	local shivas = module.ItemSlot(npcBot, "item_shivas_guard")

	----cost of mana/items----
	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaE = abilityE:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local qCharges = npcBot:GetModifierStackCount(npcBot:GetModifierByName("modifier_obsidian_destroyer_arcane_orb"))

	local manaSheepStick = 250
	local manaHurricane = 100
	local manaShivas = 100

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

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			----Try various combos on weakened enemy unit----
			if (not IsBotCasting() and hurricane ~= nil and ConsiderCast(hurricane) and currentMana >= module.CalcManaCombo(manaHurricane)
				and GetUnitToUnitDistance(npcBot, eHeroList[1]) <= 250) then
				npcBot:Action_UseAbilityOnEntity(hurricane, eHeroList[1])

			elseif (not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target)

			elseif (not IsBotCasting() and target2 ~= nil and ConsiderCast(abilityW, abilityE) and GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW, manaE) and target ~= target2 and not module.IsHardCC(target2)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target2)
				npcBot:ActionPush_UseAbility(abilityE)

			elseif (not IsBotCasting() and ConsiderCast(abilityW, abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW, manaE) and not module.IsHardCC(target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
				npcBot:ActionPush_UseAbility(abilityE)

			elseif (not IsBotCasting() and ConsiderCast(abilityR, abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaR, manaE)
					and target:GetAttributeValue(ATTRIBUTE_INTELLECT) < npcBot:GetAttributeValue(ATTRIBUTE_INTELLECT) - 30) then
				local smartAOEQ = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), abilityR:GetCastRange(), abilityR:GetAOERadius(), 0.65, 1000000)
				npcBot:ActionPush_UseAbilityOnLocation(abilityR, smartAOEQ.targetloc)
				npcBot:ActionPush_UseAbility(abilityE)

			elseif (not IsBotCasting() and target2 ~= nil and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW) and target ~= target2 and not module.IsHardCC(target2)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target2)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaR)
					and target:GetAttributeValue(ATTRIBUTE_INTELLECT) < npcBot:GetAttributeValue(ATTRIBUTE_INTELLECT) - 30) then
				local smartAOEQ = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), abilityR:GetCastRange(), abilityR:GetAOERadius(), 0.65, 1000000)
				npcBot:Action_UseAbilityOnLocation(abilityR, smartAOEQ.targetloc)

			elseif (not IsBotCasting() and #eHeroList > 1 and shivas ~= nil and ConsiderCast(shivas) and GetUnitToUnitDistance(npcBot, target) <= 600
					and currentMana >= module.CalcManaCombo(manaShivas) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbility(shivas)

			end
		end

		if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)
				and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)
			return
		end

		----Fuck'em up!----
		--ranged, wait til attack finish
		if (not IsBotCasting()) then
			npcBot:Action_AttackUnit(target, true)
		end

		module.ConsiderKillPing(npcBot, target)
	end
end

function SpellRetreat()
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityW = npcBot:GetAbilityByName(SKILL_W)

	local hurricane = module.ItemSlot(npcBot, "item_hurricane_pike")

	local manaW = abilityW:GetManaCost()
	local manaHurricane = 100


	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsSilenced()) then
		local target = eHeroList[1]

		if (not IsBotCasting() and hurricane ~= nil and ConsiderCast(hurricane) and currentMana >= module.CalcManaCombo(manaHurricane)
				and GetUnitToUnitDistance(npcBot, eHeroList[1]) <= hurricane:GetCastRange()) then
			npcBot:Action_UseAbilityOnEntity(hurricane, eHeroList[1])

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
				and GetUnitToUnitDistance(npcBot,target) >= abilityW:GetCastRange() - 200 and currentMana >= module.CalcManaCombo(manaW)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)

		end

	end

end



function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()

	module.DangerPing(npcBot)

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