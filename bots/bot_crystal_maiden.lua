local module = require(GetScriptDirectory().."/helpers")
local bot_generic = require(GetScriptDirectory().."/bot_generic")

local SKILL_Q = "crystal_maiden_crystal_nova"
local SKILL_W = "crystal_maiden_frostbite"
local SKILL_E = "crystal_maiden_brilliance_aura"
local SKILL_R = "crystal_maiden_freezing_field"
local TALENT1 = "special_bonus_hp_250"
local TALENT2 = "special_bonus_cast_range_100"
local TALENT3 = "special_bonus_unique_crystal_maiden_4"
local TALENT4 = "special_bonus_gold_income_25"
local TALENT5 = "special_bonus_attack_speed_250"
local TALENT6 = "special_bonus_unique_crystal_maiden_3"
local TALENT7 = "special_bonus_unique_crystal_maiden_1"
local TALENT8 = "special_bonus_unique_crystal_maiden_2"

local Ability = {
	SKILL_Q,
	SKILL_E,
	SKILL_W,
	SKILL_E,
	SKILL_E,
	SKILL_R,
	SKILL_E,
	SKILL_Q,
	SKILL_Q,
	TALENT2,
	SKILL_Q,
	SKILL_R,
	SKILL_W,
	SKILL_W,
	TALENT4,
	SKILL_W,
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
local AP_AttackUnit = npcBot.ActionPush_AttackUnit
local AP_MoveDirectly = npcBot.ActionPush_MoveDirectly
local AP_MoveToUnit = npcBot.ActionPush_MoveToUnit
local UseAbilityEnemy = npcBot.ActionPush_UseAbilityOnEntity
local UseAbility = npcBot.ActionPush_UseAbility

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


----Murder closest enemy hero----
function Murder(eHero)
	local perHealth = module.CalcPerHealth(npcBot)
	local manaPer = module.CalcPerMana(npcBot)
	local hRange = npcBot:GetAttackRange() - 50
	--local spamSkill = comboList[npcBot:GetUnitName()]

	local abilityQ = npcBot:GetAbilityByName(SKILL_Q)
	local abilityW = npcBot:GetAbilityByName(SKILL_W)
	local abilityR = npcBot:GetAbilityByName(SKILL_R)
	local blink = module.ItemSlot(npcBot, "item_blink")
	local arcane = module.ItemSlot(npcBot, "item_arcane_boots")

	if (not IsBotCasting() and ConsiderItem(blink) == 1 and ConsiderCast(abilityR) == 1 and manaPer >= 0.3 and GetUnitToUnitDistance(npcBot, eHero) <= 1500) then
		npcBot:ActionPush_UseAbility(abilityR)
		npcBot:ActionPush_UseAbilityOnLocation(blink, eHero:GetLocation())
	elseif (not IsBotCasting() and ConsiderCast(abilityR) == 1 and GetUnitToUnitDistance(npcBot, eHero) <= 500) then
		npcBot:ActionPush_UseAbility(abilityR)
	elseif (not IsBotCasting() and ConsiderCast(abilityW) == 1 and ConsiderCast(abilityQ) == 1 and manaPer >= 0.3) then
		if (GetUnitToUnitDistance(npcBot, eHero) <= abilityW:GetCastRange()) then
			npcBot:ActionPush_UseAbilityOnLocation(abilityQ, eHero:GetLocation())
			npcBot:ActionPush_UseAbilityOnEntity(abilityW, eHero)
		elseif (GetUnitToUnitDistance(npcBot, eHero) <= abilityQ:GetCastRange()) then
			npcBot:ActionPush_UseAbilityOnLocation(abilityQ, eHero:GetLocation())
		end
	elseif (not IsBotCasting() and ConsiderCast(abilityQ) == 1 and GetUnitToUnitDistance(npcBot, eHero) <= abilityQ:GetCastRange() and manaPer >= 0.3) then
		npcBot:ActionPush_UseAbilityOnLocation(abilityQ, eHero:GetLocation())
	end

	----Fuck'em up!----
	if (not IsBotCasting()) then
		if (GetUnitToUnitDistance(npcBot, eHero) <= hRange) then
			AP_AttackUnit(npcBot, eHero, true)
		else
			AP_AttackUnit(npcBot, eHero, true)
			AP_MoveToUnit(npcBot, eHero)
		end
	end

end

----Pokes hero if within range----
function Poke(eHero)
	local perHealth = module.CalcPerHealth(npcBot)
	local eHeroClose = module.CalcPerHealth(eHero)
	local hRange = npcBot:GetAttackRange() - 50

	if (GetUnitToUnitDistance(npcBot, eHero) <= hRange and npcBot:NumQueuedActions() == 0) then
		AP_AttackUnit(npcBot, eHero, true)
	end
end

function Hunt()
	local perHealth = module.CalcPerHealth(npcBot)

	local aHero = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local aTowers = npcBot:GetNearbyTowers(700, false)

	local eHero = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local eTowers = npcBot:GetNearbyTowers(1000, true)

	local powerRatio = module.CalcPowerRatio(npcBot, aHero, eHero)

	if (eHero == nil or #eHero == 0) then
		return
	elseif (etowers ~= nil or #eTowers ~= 0) then
		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= 725) then
			return
		end
	else
		local ePerHealth = module.CalcPerHealth(eHero[1])
		if ((ePerHealth <= 0.75 or powerRatio <= 1 or #aTowers ~= 0) and eTowers == nil) then
			Murder(eHero[1])
			return
		elseif (ePerHealth > 0.75) then
			Poke(eHero[1])
			return
		end
	end
end

function Think()
	----Level up Abilities in order----
	module.AbilityLevelUp(Ability)
	----Determine and execute whether to poke or hunt the enemy----
	Hunt()
	----After executing Hunt, go back to generic state machines----
	bot_generic.Think()
end
