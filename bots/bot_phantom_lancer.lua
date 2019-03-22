-- local module = require(GetScriptDirectory().."/helpers")
-- local behavior = require(GetScriptDirectory().."/behavior")
-- local stateMachine = require(GetScriptDirectory().."/state_machine")
-- local minionBehavior = require(GetScriptDirectory().."/minion_behavior")
-- local minionStateMachine = require(GetScriptDirectory().."/minion_state_machine")

-- local SKILL_Q = "phantom_lancer_spirit_lance"
-- local SKILL_W = "phantom_lancer_doppelwalk"
-- local SKILL_E = "phantom_lancer_phantom_edge"
-- local SKILL_R = "phantom_lancer_juxtapose"
-- local TALENT1 = "special_bonus_evasion_15"
-- local TALENT2 = "special_bonus_attack_speed_20"
-- local TALENT3 = "special_bonus_hp_250"
-- local TALENT4 = "special_bonus_unique_phantom_lancer_2"
-- local TALENT5 = "special_bonus_unique_phantom_lancer"
-- local TALENT6 = "special_bonus_unique_phantom_lancer_3"
-- local TALENT7 = "special_bonus_unique_phantom_lancer_4"
-- local TALENT8 = "special_bonus_30_crit_2"


-- local Ability = {
-- 	SKILL_Q,
-- 	SKILL_E,
-- 	SKILL_W,
-- 	SKILL_E,
-- 	SKILL_E,
-- 	SKILL_R,
-- 	SKILL_E,
-- 	SKILL_W,
-- 	SKILL_W,
-- 	TALENT2,
-- 	SKILL_W,
-- 	SKILL_R,
-- 	SKILL_Q,
-- 	SKILL_Q,
-- 	TALENT3,
-- 	SKILL_Q,
-- 	"nil",
-- 	SKILL_R,
-- 	"nil",
-- 	TALENT5,
-- 	"nil",
-- 	"nil",
-- 	"nil",
-- 	"nil",
-- 	TALENT7
-- }

-- local npcBot = GetBot()
-- local increment = 1

-- function IsBotCasting()
-- 	return npcBot:IsChanneling()
-- 		  or npcBot:IsUsingAbility()
-- 		  or npcBot:IsCastingAbility()
-- end

-- function ConsiderCast(...)
-- 	for k,v in pairs({...}) do
-- 		if (v == nil or not v:IsFullyCastable()) then
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end

-- ----Murder closest enemy hero----
-- function Murder()
-- 	local currentHealth = npcBot:GetHealth()
-- 	local maxHealth = npcBot:GetMaxHealth()
-- 	local perHealth = module.CalcPerHealth(npcBot)
-- 	local currentMana = npcBot:GetMana()
-- 	local manaPer = module.CalcPerMana(npcBot)
-- 	local hRange = npcBot:GetAttackRange() - 25

-- 	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
-- 	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

-- 	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
-- 	local abilityW = npcBot:GetAbilityByName(SKILL_W)

-- 	local manta = module.ItemSlot(npcBot, "item_manta")
-- 	local stick = module.ItemSlot(npcBot, "item_magic_stick")
-- 	local wand = module.ItemSlot(npcBot, "item_magic_wand")

-- 	local manaQ = abilityQ:GetManaCost()
-- 	local manaW = abilityW:GetManaCost()
-- 	local manaManta = 125

-- 	if (not IsBotCasting() and stick ~= nil and ConsiderCast(stick) and stick:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (stick:GetCurrentCharges() * 15))) then
-- 		npcBot:Action_UseAbility(stick)
-- 		return
-- 	end

-- 	if (not IsBotCasting() and wand ~= nil and ConsiderCast(wand) and wand:GetCurrentCharges() >= 5 and currentHealth <= (maxHealth - (wand:GetCurrentCharges() * 15))) then
-- 		npcBot:Action_UseAbility(wand)
-- 		return
-- 	end

-- 	if (eHeroList ~= nil and #eHeroList > 0) then
-- 		local target = module.SmartTarget(npcBot)

-- 		if (not npcBot:IsSilenced()) then
-- 			if (not IsBotCasting() and ConsiderCast(abilityQ) and currentMana >= module.CalcManaCombo(manaQ)
-- 					and GetUnitToUnitDistance(npcBot, target) <= abilityQ:GetCastRange()) then
-- 				npcBot:Action_UseAbilityOnEntity(abilityQ, target)

-- 			elseif (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)
-- 					and GetUnitToUnitDistance(npcBot, target) <= abilityW:GetCastRange()) then
-- 				npcBot:Action_UseAbilityOnLocation(abilityW, target:GetLocation())

-- 			end

-- 			if (manta ~= nil) then
-- 				if (not IsBotCasting() and ConsiderCast(manta) and currentMana >= manaManta) then
-- 					npcBot:Action_UseAbility(manta)
-- 				end
-- 			end
-- 		end


-- 		----Fuck'em up!----
-- 		if (not IsBotCasting()) then
-- 			if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK then
-- 				if GetUnitToUnitDistance(npcBot, target) > 350 then
-- 					npcBot:Action_MoveToUnit(target)
-- 				end
-- 			else
-- 				if (GetUnitToUnitDistance(npcBot, target) <= hRange) then
-- 					npcBot:Action_AttackUnit(target, true)
-- 				else
-- 					npcBot:Action_MoveToUnit(target)
-- 				end
-- 			end
-- 		end

-- 		if (module.CalcPerHealth(target) <= 0.15) then
-- 			local ping = target:GetExtrapolatedLocation(1)
-- 			npcBot:ActionImmediate_Ping(ping.x, ping.y, true)
-- 		end
-- 	end
-- end


-- function SpellRetreat()
-- 	npcBot = GetBot()
-- 	local perHealth = module.CalcPerHealth(npcBot)
-- 	local currentMana = npcBot:GetMana()
-- 	local manaPer = module.CalcPerMana(npcBot)

-- 	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

-- 	local abilityW = npcBot:GetAbilityByName(SKILL_W)


-- 	if (eHeroList ~= nil and #eHeroList > 0) then
-- 		if (not npcBot:IsSilenced()) then
-- 			if (not IsBotCasting() and ConsiderCast(abilityW) and currentMana >= module.CalcManaCombo(manaW)) then
-- 				npcBot:Action_UseAbilityOnLocation(abilityW, npcBot:GetLocation())
-- 			end
-- 		end
-- 	end
-- end

-- -----------------------------------------------------------------------------------------------------

-- ----Ability Leveling Modules----
-- function AbilityLevelUp()
-- 	npcBot = GetBot()

-- 	if (npcBot:GetAbilityPoints() < 1 or #Ability == 0) then
-- 		print("naw, breh")
-- 		return
-- 	end


-- 	local ability_name = Ability[increment]

-- 	--If level up is "nil", delete nil
-- 	if (ability_name == "nil") then
-- 		--table.remove(Ability, 1)
-- 		--increment = increment + 1
-- 		return
-- 	end

-- 	local ability = npcBot:GetAbilityByName(ability_name)

-- 	--If ability can be upgraded, upgrade appropriate ability
-- 	if (ability:CanAbilityBeUpgraded() and npcBot:GetAbilityPoints() > 0) then
-- 		print("Skill: "..ability_name.."  upgraded!")
-- 		--increment = increment + 1
-- 		npcBot:ActionImmediate_LevelAbility(ability_name)
-- 		--npcBot:ActionImmediate_Chat("Upgraded Ability", true)
-- 		--table.remove(Ability, 1)
-- 		return
-- 	end
-- end
-- -----------------------------------------------------------------------------------------------------

-- function Think()
-- 	npcBot = GetBot()
-- 	local state = stateMachine.calculateState(npcBot)
-- 	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

-- 	--print("Skill: "..npcBot:GetAbilityInSlot(0)..)
-- 	--print("Ability: "..npcBot:GetAbilityByName("phantom_lancer_spirit_lance")..)

-- 	if (npcBot:GetAbilityPoints() == 1) then
-- 		AbilityLevelUp()
-- 	end
-- 	if state.state == "hunt" then
-- 		Murder()
-- 	elseif state.state == "retreat" then
-- 		behavior.generic(npcBot, state)
-- 		if (not npcBot:IsSilenced()) then
-- 			SpellRetreat()
-- 		end
-- 	elseif state.state == "finishHim" then
-- 		behavior.generic(npcBot, state)
-- 		Murder()
-- 	else
-- 		behavior.generic(npcBot, state)
-- 	end
-- end

-- function MinionThink(hMinionUnit)
-- 	local state = minionStateMachine.calculateState(hMinionUnit)
-- 	local master = GetBot()
-- 	if (hMinionUnit == nil) then
-- 		return
-- 	end

-- 	if hMinionUnit:IsIllusion() then
-- 		minionBehavior.generic(hMinionUnit, master, state)
-- 	else
-- 		return
-- 	end
-- end