local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "lion_impale"
local SKILL_W = "lion_voodoo"
local SKILL_E = "lion_mana_drain"
local SKILL_R = "lion_finger_of_death"
local TALENT1 = "special_bonus_cast_range_100"
local TALENT2 = "special_bonus_attack_damage_90"
local TALENT3 = "special_bonus_unique_lion_3"
local TALENT4 = "special_bonus_gold_income_25"
local TALENT5 = "special_bonus_hp_500"
local TALENT6 = "special_bonus_unique_lion"
local TALENT7 = "special_bonus_unique_lion_2"
local TALENT8 = "special_bonus_unique_lion_4"


local Ability = {
	SKILL_Q,
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_W,
	SKILL_W,
	TALENT1,
	SKILL_W,
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
		local target3 = module.HighestAttackSpeed(eHeroList)

		--rsheepwq
		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			----Try various combos on weakened enemy unit----
			if (not IsBotCasting() and ConsiderCast(abilityR) and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaR) and abilityR:GetAbilityDamage() + 100 >= target:GetHealth()) then
				npcBot:Action_UseAbilityOnEntity(abilityR, target)

			elseif (target2 ~= nil and not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target2) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target2)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target2)

			elseif (target2 ~= nil and not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target2) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW) and not module.IsHardCC(target2)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target2)

			elseif (target3 ~= nil and not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target3) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target3)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target3)

			elseif (target3 ~= nil and not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target3) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW) and not module.IsHardCC(target3)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target3)

			elseif (target ~= nil and not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

			end
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
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local sheepStick = module.ItemSlot(npcBot, "item_sheepstick")

	local manaSheepStick = 250
	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()


	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsInvisible() and not npcBot:IsSilenced()) then
		local target = eHeroList[1]


		if (not IsBotCasting() and ConsiderCast(abilityW) and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
				and GetUnitToUnitDistance(npcBot,target) >= abilityW:GetCastRange() - 200 and currentMana >= module.CalcManaCombo(manaW) and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityW, target)

		elseif (not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target) <= sheepStick:GetCastRange()
				and GetUnitToUnitDistance(npcBot,target) >= sheepStick:GetCastRange() - 200 and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(sheepStick, target)

		elseif (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
				and GetUnitToUnitDistance(npcBot,target) >= abilityQ:GetCastRange() - 200 and currentMana >= module.CalcManaCombo(manaQ) and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)


		end

	end

end

function FarmSpells()
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local manaE = abilityE:GetManaCost()
	local currentMana = npcBot:GetMana()

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsSilenced()) then
		local target = eHeroList[1]
		if (not IsBotCasting() and ConsiderCast(abilityE) and GetUnitToUnitDistance(npcBot, target) <= abilityE:GetCastRange()
			and GetUnitToUnitDistance(npcBot,target) >= abilityE:GetCastRange() - 400 and currentMana >= module.CalcManaCombo(manaE)) then
			npcBot:Action_UseAbilityOnEntity(abilityE, target)
		end
	end
end

function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	local currentMana = npcBot:GetMana()
	local maxMana = npcBot:GetMaxMana()
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	module.DangerPing(npcBot)

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
		if (not npcBot:IsSilenced()) then
			SpellRetreat()
		end
	elseif state.state == "finishHim" then
		behavior.generic(npcBot, state)
		Murder()
	elseif state.state == "farm" then
		behavior.generic(npcBot, state)
		FarmSpells()
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