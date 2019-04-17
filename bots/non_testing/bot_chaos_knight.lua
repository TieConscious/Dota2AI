local module = require(GetScriptDirectory().."/helpers")
local behavior = require(GetScriptDirectory().."/behavior")
local stateMachine = require(GetScriptDirectory().."/state_machine")
local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

local SKILL_Q = "chaos_knight_chaos_bolt"
local SKILL_W = "chaos_knight_reality_rift"
local SKILL_E = "chaos_knight_chaos_strike"
local SKILL_R = "chaos_knight_phantasm"
local TALENT1 = "special_bonus_all_stats_5"
local TALENT2 = "special_bonus_movement_speed_20"
local TALENT3 = "special_bonus_strength_15"
local TALENT4 = "special_bonus_cooldown_reduction_12"
local TALENT5 = "special_bonus_gold_income_25"
local TALENT6 = "special_bonus_unique_chaos_knight"
local TALENT7 = "special_bonus_unique_chaos_knight_2"
local TALENT8 = "special_bonus_unique_chaos_knight_3"

local Ability = {
	SKILL_Q,
	SKILL_W,
	SKILL_E,
	SKILL_Q,
	SKILL_E,
	SKILL_R,
	SKILL_W,
	SKILL_Q,
	SKILL_Q,
	TALENT1,
	SKILL_W,
	SKILL_R,
	SKILL_E,
	SKILL_W,
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
	local abilityE = npcBot:GetAbilityByName(SKILL_E)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local manta = module.ItemSlot(npcBot, "item_manta")
	local stick = module.ItemSlot(npcBot, "item_magic_stick")
	local wand = module.ItemSlot(npcBot, "item_magic_wand")


	local manaQ = abilityQ:GetManaCost()
	local manaW = abilityW:GetManaCost()
	local manaR = abilityR:GetManaCost()
	local manaManta = 125

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
			if (not IsBotCasting() and ConsiderCast(abilityR, abilityW, abilityQ) and currentMana >= module.CalcManaCombo(manaQ, manaW, manaR) and not module.IsHardCC(target)) then
				if (GetUnitToUnitDistance(npcBot,target) >= (abilityW:GetCastRange() * 0.75) and abilityW:GetCastRange() >= GetUnitToUnitDistance(npcBot,target)) then
					npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
					npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
					npcBot:ActionPush_UseAbility(abilityR)
				elseif (GetUnitToUnitDistance(npcBot,target) <= abilityQ:GetCastRange()) then
					npcBot:ActionPush_UseAbility(abilityR)
					npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
				end

			elseif (not IsBotCasting() and ConsiderCast(abilityR, abilityW) and currentMana >= module.CalcManaCombo(manaW, manaR)
					and GetUnitToUnitDistance(npcBot,target) >= (abilityW:GetCastRange() * 0.75) and abilityW:GetCastRange() >= GetUnitToUnitDistance(npcBot,target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)
				npcBot:ActionPush_UseAbility(abilityR)

			elseif (not IsBotCasting() and ConsiderCast(abilityW, abilityQ) and currentMana >= module.CalcManaCombo(manaQ, manaW)
					and	GetUnitToUnitDistance(npcBot,target) >= (abilityW:GetCastRange() * 0.75) and abilityW:GetCastRange() >= GetUnitToUnitDistance(npcBot,target)
					and not module.IsHardCC(target)) then
				npcBot:ActionPush_UseAbilityOnEntity(abilityQ, target)
				npcBot:ActionPush_UseAbilityOnEntity(abilityW, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)
					and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange() and not module.IsHardCC(target)) then
				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

			elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
					and GetUnitToUnitDistance(npcBot,target) >= (abilityW:GetCastRange() * 0.75) and abilityW:GetCastRange() >= GetUnitToUnitDistance(npcBot,target)) then
				npcBot:Action_UseAbilityOnEntity(abilityW, target)

			end

			if (manta ~= nil) then
				if (not IsBotCasting() and ConsiderCast(manta) and currentMana >= manaManta and GetUnitToUnitDistance(npcBot, target) <= 200) then
					npcBot:Action_UseAbility(manta)
				end
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

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)

	local manaQ = abilityQ:GetManaCost()

	if (eHeroList ~= nil and #eHeroList > 0 and not npcBot:IsSilenced()) then
		local target = eHeroList[1]

		if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ) and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()
			and GetUnitToUnitDistance(npcBot,target) >= abilityQ:GetCastRange() - 200 and not module.IsHardCC(target)) then
			npcBot:Action_UseAbilityOnEntity(abilityQ, target)
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