local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "legion_commander_overwhelming_odds"
local SKILL_W = "legion_commander_press_the_attack"
local SKILL_E = "legion_commander_moment_of_courage"
local SKILL_R = "legion_commander_duel"
local TALENT1 = "special_bonus_strength_8"
local TALENT2 = "special_bonus_exp_boost_25"
local TALENT3 = "special_bonus_attack_speed_30"
local TALENT4 = "special_bonus_unique_legion_commander_4"
local TALENT5 = "special_bonus_movement_speed_35"
local TALENT6 = "special_bonus_unique_legion_commander_3"
local TALENT7 = "special_bonus_unique_legion_commander"
local TALENT8 = "special_bonus_unique_legion_commander_5"


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
	TALENT6,
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

function module.CanSheKillThem(npcBot, target)
    if (target == nil) then
        return false
	end
	local ags = module.ItemSlot(npcBot, "item_ultimate_scepter")

	ultTime = {4, 4.75, 5.5}
	agTime = {6, 7, 8}

	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local targetHealth = target:GetHealth()
	local rLevel = abilityR:GetLevel()
	local seconds

	if ags ~= nil then
		seconds = agTime[rLevel]
	else
		seconds = ultTime[rLevel]
	end

	seconds = seconds - (npcBot:GetSecondsPerAttack() * npcBot:GetAttackPoint())

    return npcBot:GetEstimatedDamageToTarget(true, target, seconds, DAMAGE_TYPE_ALL) >= targetHealth
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
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local shadow = module.ItemSlot(npcBot, "item_invis_sword")
	local bmail = module.ItemSlot(npcBot, "item_blade_mail")
	local silver = module.ItemSlot(npcBot, "item_silver_edge")


	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()

	local manaShadow = 75
	local manaBmail = 25
	local manaSilver = 75

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

		if (not npcBot:IsSilenced() and not target:IsMagicImmune()) then
			if (not IsBotCasting() and shadow ~= nil and ConsiderCast(shadow) and currentMana >= module.CalcManaCombo(manaShadow)) then
				npcBot:ActionPush_UseAbility(shadow)

			elseif (not IsBotCasting() and silver ~= nil and ConsiderCast(silver) and currentMana >= module.CalcManaCombo(manaSilver)) then
				npcBot:ActionPush_UseAbility(silver)

			elseif (not IsBotCasting() and bmail ~= nil and ConsiderCast(abilityW, bmail, abilityR) and currentMana >= module.CalcManaCombo(manaW, manaBmail, manaR)
					and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange() + 100 and module.CanSheKillThem(npcBot, target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityR, target)
				npcBot:ActionPush_UseAbility(bmail)
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, npcBot)

			elseif (not IsBotCasting() and bmail ~= nil and ConsiderCast(bmail, abilityR) and currentMana >= module.CalcManaCombo(manaBmail, manaR)
					and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange() + 100 and module.CanSheKillThem(npcBot, target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityR, target)
				npcBot:ActionPush_UseAbility(bmail)

			elseif (not IsBotCasting() and ConsiderCast(abilityW, abilityR) and currentMana >= module.CalcManaCombo(manaW, manaR)
					and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange() + 100 and module.CanSheKillThem(npcBot, target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityR, target)
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, npcBot)

			elseif (not IsBotCasting() and ConsiderCast(abilityR) and currentMana >= module.CalcManaCombo(manaR)
					and GetUnitToUnitDistance(npcBot, target) <= abilityR:GetCastRange() + 100 and module.CanSheKillThem(npcBot, target)) then
				npcBot:Action_UseAbilityOnEntity(abilityR, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
					and GetUnitToUnitDistance(npcBot, target) <= 250) then
				npcBot:Action_UseAbilityOnEntity(abilityW, npcBot)

			end
		end
		----Fuck'em up!----
		--melee, miss when over 350
		if (not IsBotCasting() and not target:IsNightmared()) then
			if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK and npcBot:GetTarget() == target then
				if GetUnitToUnitDistance(npcBot, target) > 350 then
					npcBot:Action_MoveToUnit(target)
				end
			else
				npcBot:Action_AttackUnit(target, true)
			end
		end

		module.ConsiderKillPing(npcBot, target)
	end

end

function SpellRetreat()
	npcBot = GetBot()
	local perHealth = module.CalcPerHealth(npcBot)
	local currentMana = npcBot:GetMana()
	local manaPer = module.CalcPerMana(npcBot)

	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local abilityW = npcBot:GetAbilityByName(SKILL_W)

	local shadow = module.ItemSlot(npcBot, "item_invis_sword")
	local silver = module.ItemSlot(npcBot, "item_silver_edge")

	local manaW = abilityW:GetManaCost()

	local manaShadow = 75
	local manaSilver = 75

	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsSilenced() and not npcBot:IsInvisible()) then
		local target = eHeroList[1]

		if (not IsBotCasting() and shadow ~= nil and ConsiderCast(shadow) and currentMana >= module.CalcManaCombo(manaShadow)) then
			npcBot:Action_UseAbility(shadow)

		elseif (not IsBotCasting() and silver ~= nil and ConsiderCast(silver) and currentMana >= module.CalcManaCombo(manaSilver)) then
			npcBot:Action_UseAbility(silver)

		elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW) and perHealth <= 0.5) then
			npcBot:Action_UseAbilityOnEntity(abilityW, npcBot)
		end
	end
end

function Think()
	local npcBot = GetBot()
	local state = stateMachine.calculateState(npcBot)

		--local x = -3000
	--local y = 4250
	--npcBot:ActionImmediate_Ping(x, y, true)
	--DebugDrawCircle(Vector(x, y, 0), 10, 255, 0, 0)

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