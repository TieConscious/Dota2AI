local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "jakiro_dual_breath"
local SKILL_W = "jakiro_ice_path"
local SKILL_E = "jakiro_liquid_fire"
local SKILL_R = "jakiro_macropyre"
local TALENT1 = "special_bonus_attack_range_300"
local TALENT2 = "special_bonus_spell_amplify_8"
local TALENT3 = "special_bonus_exp_boost_40"
local TALENT4 = "special_bonus_unique_jakiro_2"
local TALENT5 = "special_bonus_unique_jakiro_4"
local TALENT6 = "special_bonus_gold_income_25"
local TALENT7 = "special_bonus_unique_jakiro_3"
local TALENT8 = "special_bonus_unique_jakiro"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_Q,
	SKILL_W,
	SKILL_Q,
	SKILL_R,
	SKILL_Q,
	SKILL_E,
	SKILL_E,
	TALENT2,
	SKILL_E,
	SKILL_R,
	SKILL_W,
	SKILL_W,
	TALENT4,
	SKILL_W,
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

function CalculateBreath(target, npcBot)
	-- p0 = target:GetLocation()
	-- p1 = npcBot:GetLocation()
	-- velocity = target:GetVelocity()
	-- a = p0.x
	-- b = p1.x
	-- c = velocity.x
	-- d = p0.y
	-- e = p1.y
	-- f = velocity.y
	-- x = (-math.sqrt((-8*a*c + 8*b*c - 8*d*f + 8*e*f + 4851000)^2
	-- 	- 4*(4*(c^2) + 4*(f^2) - 4410000)
	-- 	* (4*(a^2) - 8*a*b + 4*(b^2) + 4*(d^2) - 8*d*e + 4*(e^2) - 1334025))
	-- 	+ 8*a*c - 8*b*c + 8*d*f - 8*e*f - 4851000)
	-- 	/ (2*(4*(c^2) + 4*(f^2) - 4410000))
	-- print(x)
	-- return target:GetExtrapolatedLocation(x), x
	x = GetUnitToUnitDistance(target, npcBot) / 1050 + 0.55
	return target:GetExtrapolatedLocation(x)
end


----Murder closest enemy hero----
function Murder()
	local currentHealth = npcBot:GetHealth()
	local maxHealth = npcBot:GetMaxHealth()
	local manaPer = module.CalcPerMana(npcBot)
	local currentMana = npcBot:GetMana()
	local hRange = npcBot:GetAttackRange() - 25

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

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

	----cost of mana/items----
	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()

	local manaSheepStick = 250

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
		local forceTarget = module.UseForceStaff(npcBot)

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			----Try various combos on weakened enemy unit----
			local extraLocation = CalculateBreath(target, npcBot)
			if (not IsBotCasting() and ConsiderCast(abilityQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaQ)) then
				npcBot:Action_UseAbilityOnLocation(abilityQ, extraLocation)

			elseif (not IsBotCasting() and sheepStick ~= nil and ConsiderCast(sheepStick) and GetUnitToUnitDistance(npcBot, target) <= sheepStick:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaSheepStick) and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(sheepStick, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaW)) then
				local targetLocation = target:GetExtrapolatedLocation(0.65)
				npcBot:Action_UseAbilityOnLocation(abilityW, targetLocation)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and  GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange()
					and currentMana >= module.CalcManaCombo(manaR)) then
					local targetLocation = target:GetExtrapolatedLocation(0.55)
					npcBot:Action_UseAbilityOnLocation(abilityR, targetLocation)

			end
		end

		----Fuck'em up!----
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

	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")

	local manaW = abilityW:GetManaCost()


	local ancient
	if (npcBot:GetTeam() == 2) then
		ancient = GetAncient(2)
	else
		ancient = GetAncient(3)
	end

	--if (not IsBotCasting() and stick ~= nil and ConsiderCast(stick) and stick:GetCurrentCharges() >= 2 and currentHealth <= (maxHealth - (stick:GetCurrentCharges() * 15))) then
	--	npcBot:Action_UseAbility(stick)
	--	return
	--end

	--if (not IsBotCasting() and wand ~= nil and ConsiderCast(wand) and wand:GetCurrentCharges() >= 2 and currentHealth <= (maxHealth - (wand:GetCurrentCharges() * 15))) then
	--	npcBot:Action_UseAbility(wand)
	--	return
	--end


	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsSilenced()) then
		local target = eHeroList[1]

		if (not IsBotCasting() and ConsiderCast(abilityW) and  GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()
				and GetUnitToUnitDistance(npcBot,target) >= abilityW:GetCastRange() - 200 and currentMana >= module.CalcManaCombo(manaW)) then
				local targetLocation = target:GetExtrapolatedLocation(0.65)
				npcBot:Action_UseAbilityOnLocation(abilityW, targetLocation)

		end

	end

end

function UseE()
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local eHeroList = npcBot:GetNearbyHeroes(abilityE:GetCastRange(), true, BOT_MODE_NONE)
	local eTowers = npcBot:GetNearbyTowers(abilityE:GetCastRange(), true)
	local eCreeps = npcBot:GetNearbyLaneCreeps(abilityE:GetCastRange(), true)

	if not IsBotCasting() and ConsiderCast(abilityE) then
		if eHeroList ~= nil and #eHeroList > 0 then
			npcBot:Action_UseAbilityOnEntity(abilityE, eHeroList[1])
		elseif eTowers ~= nil and #eTowers > 0 then
			npcBot:Action_UseAbilityOnEntity(abilityE, eTowers[1])
		elseif eCreeps ~= nil and #eCreeps > 0 then
			npcBot:Action_UseAbilityOnEntity(abilityE, eCreeps[1])
		end
	end
end


function Think()
	npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

	local currentMana = npcBot:GetMana()
	local currentHealth = npcBot:GetHealth()
	local maxMana = npcBot:GetMaxMana()
	local maxHealth = npcBot:GetMaxHealth()
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")
	local greaves = module.ItemSlot(npcBot, "item_guardian_greaves")
	local mek = module.ItemSlot(npcBot, "item_mekansm")

	local manaMek = 225 --halfhealth

	module.DangerPing(npcBot)

	if (not IsBotCasting() and arcane ~= nil and ConsiderCast(arcane) and currentMana <= (maxMana - 180)) then
		npcBot:Action_UseAbility(arcane)
		return
	end

	if (not IsBotCasting() and mek ~= nil and ConsiderCast(mek) and currentMana >= module.CalcManaCombo(manaMek) and currentHealth <= maxHealth / 2) then
		npcBot:Action_UseAbility(mek)
		return
	end

	if not IsBotCasting() and greaves ~= nil and ConsiderCast(greaves) and (currentHealth <= maxHealth / 2 or (currentMana <= (maxMana - 200) and currentHealth <= (maxHealth - 300))) then
		npcBot:Action_UseAbility(greaves)
		return
	end


	--stateMachine.printState(state)
	module.AbilityLevelUp(Ability)
	if state.state == "hunt" then
		--implement custom hero hunting here
		UseE()
		Murder()
	elseif state.state == "farm" or state.state == "tower" then
		behavior.generic(npcBot, state)
		UseE()
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