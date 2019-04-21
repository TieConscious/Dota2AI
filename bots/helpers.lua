local module = {}
local heroSel = require(GetScriptDirectory().."/hero_selection")

---- Function Pointers -----
local npcBot = GetBot()
local MoveDirectly = npcBot.Action_MoveDirectly
local AttackMove = npcBot.Action_AttackMove

----Item Purchasing Modules----
function module.ItemPurchase(Items)
	local PurchaseResult = -5
	local npcBot = GetBot()

	--If table is empty, don't do shit
	if (#Items == 0) then
		npcBot:SetNextItemPurchaseValue(0)
		return
	end

	npcBot:SetNextItemPurchaseValue(GetItemCost(list))

	--Gets location of both Secret Shops
	local SS1 = GetShopLocation(GetTeam(), SHOP_SECRET)
	local SS2 = GetShopLocation(GetTeam(), SHOP_SECRET2)

	local list = Items[1]

	if (npcBot:GetGold() >= GetItemCost(list)) then
		if (IsItemPurchasedFromSecretShop(list) == true) then
			--Finds which Secret Shop is closer and goes towards the nearest
			npcBot:ActionImmediate_Chat("Secret Shop", true)
			if (GetUnitToLocationDistance(npcBot, SS1) <= GetUnitToLocationDistance(npcBot, SS2)) then
				MoveDirectly(npcBot, SS1)
			else
				MoveDirectly(npcBot, SS2)
			end
		end

		PurchaseResult = npcBot:ActionImmediate_PurchaseItem(list)
		--Confirm whether the item was purchased, then remove from table
		if (PurchaseResult == PURCHASE_ITEM_SUCCESS) then
			table.remove(Items, 1)
			npcBot:ActionImmediate_Chat("Bought", true)
			return
		end
	end
end

----Ability Leveling Modules----
function module.AbilityLevelUp(Ability)
	local npcBot = GetBot()

	if (npcBot:GetAbilityPoints() < 1 or #Ability == 0) then
		return
	end


	local ability_name = Ability[1]

	--If level up is "nil", delete nil
	if (ability_name == "nil") then
		table.remove(Ability, 1)
		return
	end

	local ability = npcBot:GetAbilityByName(ability_name)

	--If ability can be upgraded, upgrade appropriate ability
	if (ability:CanAbilityBeUpgraded() and npcBot:GetAbilityPoints() > 0) then
		print("Skill: "..ability_name.."  upgraded!")
		npcBot:ActionImmediate_LevelAbility(ability_name)
		--npcBot:ActionImmediate_Chat("Upgraded Ability", true)
		table.remove(Ability, 1)
		return
	end
end

----Caluclate total mana cost of a combo----
function module.CalcManaCombo(...)
	local sum = 0
    for k,v in pairs({...}) do
        sum = sum + v
    end

    return sum
end

function module.UseForceStaff(npcBot)
	local nearbyEnemies = npcBot:GetNearbyHeroes(750, true, BOT_MODE_NONE)
	local nearbyAllyTower = npcBot:GetNearbyTowers(1600, false)[1]
	local myPerHealth = module.CalcPerHealth(npcBot)
	for k,v in pairs(nearbyEnemies) do
		if not v:IsNightmared() and myPerHealth > 0.3 then
			local movementVector = Vector(0, 0, 0)
			local direction = math.pi * v:GetFacing() / 180
			movementVector.x = math.cos(direction)
			movementVector.y = math.sin(direction)
			local estimatedPosition = v:GetLocation() + movementVector * 600
			local enemyPerHealth = module.CalcPerHealth(v)
			if nearbyAllyTower ~= nil and GetUnitToLocationDistance(nearbyAllyTower, estimatedPosition) then
				return v
			elseif GetUnitToLocationDistance(npcBot, estimatedPosition) < 300 then
				local enemyAttackRange = v:GetAttackRange()
				if enemyAttackRange <= 200 and enemyPerHealth < 0.15 then
					return v
				elseif enemyPerHealth < 0.2 then
					return v
				end
			end
		end
	end
	return nil
end

--use percent health as another ratio unit
----Calculate power ratios----
function module.CalcPowerRatio(npcBot, aHero, eHero)
	--GetOffensivePower calculates a more accurate power level of heroes, but is only usable on allies
	--GetRawOffensivePower calculates the "theoretical" power level of heroes

	local aPower = 0.0--npcBot:GetRawOffensivePower()
	local ePower = 0.0
	local powerRatio = 0

	----Get power level of allied heroes----
	if (aHero ~= nil or #aHero ~= 0) then
		for _,unit in pairs(aHero) do
			if (unit ~= nil and unit:IsAlive()) then
				aPower = aPower + unit:GetRawOffensivePower()
			end
		end
	end

	----Get power level of enemy heroes----
	for _,unit in pairs(eHero) do
		if (unit ~= nil and unit:IsAlive()) then
			ePower = ePower + unit:GetRawOffensivePower()
		end
	end

	----Calculate power ratio----
	if aPower < ePower then
		powerRatio = ePower / aPower - 1
	else
		powerRatio = (-aPower / ePower) + 1
	end
	return powerRatio

end

--nearbyTower is only usable by heroes, doesn't work with creeps. vise versa.
----TowerRangeCreepSearch, order of distance to npcBot----
function module.GetAllyCreepInTowerRange(npcBot, searchRange)
	local nearbyAllyCreeps = npcBot:GetNearbyLaneCreeps(searchRange, false)
	local nearbyEnemyTower = npcBot:GetNearbyTowers(searchRange, true)[1]
	local empty = {}
	if nearbyEnemyTower == nil then
		return empty
	end
	for i,creep in pairs(nearbyAllyCreeps) do
		if GetUnitToUnitDistance(nearbyEnemyTower, creep) > 700 then
			nearbyAllyCreeps[i] = nil;
		end
	end
	local j=1
	local n=#nearbyAllyCreeps
	for i=1,n do
        if nearbyAllyCreeps[i]~=nil then
			nearbyAllyCreeps[j]=nearbyAllyCreeps[i]
			j=j+1
        end
	end
	for i=n,j,-1 do
			table.remove(nearbyAllyCreeps, i)
	end
	return nearbyAllyCreeps
end

----Calculate units percent health----
function module.CalcPerHealth(unit)
	local Health = unit:GetHealth()
	local MaxHealth = unit:GetMaxHealth()
	local percentHealth = Health/MaxHealth

	return percentHealth
end

----Calculate units percent mana----
function module.CalcPerMana(unit)
	local Mana = unit:GetMana()
	local MaxMana = unit:GetMaxMana()
	local percentMana = Mana/MaxMana

	return percentMana
end


local picks = nil

function ReconstructPicks()
	local hero = nil
	picks = {}

	local teamPlayers = GetTeamPlayers(GetTeam())
	local pickedHero = {}
	for k,v in pairs(teamPlayers) do
		pickedHero[GetSelectedHeroName(v)] = true
	end

	for PickCycle=1,5 do
		if PickCycle == 1 then
			hero = heroSel.TopCarry[1]
			table.remove(heroSel.TopCarry, 1)
		elseif PickCycle == 2 then
			hero = heroSel.BotCarry[1]
			table.remove(heroSel.BotCarry, 1)
		elseif PickCycle == 3 then
			hero = heroSel.Mid[1]
			table.remove(heroSel.Mid, 1)
		elseif	PickCycle == 4 then
			hero = heroSel.TopSupport[1]
			table.remove(heroSel.TopSupport, 1)
		elseif PickCycle == 5 then
			hero = heroSel.BotSupport[1]
			table.remove(heroSel.BotSupport, 1)
		end
		while picks[hero] ~= nil or pickedHero[hero] == nil do
			if PickCycle == 1 then
				hero = heroSel.TopCarry[1]
				table.remove(heroSel.TopCarry, 1)
			elseif PickCycle == 2 then
				hero = heroSel.BotCarry[1]
				table.remove(heroSel.BotCarry, 1)
			elseif PickCycle == 3 then
				hero = heroSel.Mid[1]
				table.remove(heroSel.Mid, 1)
			elseif	PickCycle == 4 then
				hero = heroSel.TopSupport[1]
				table.remove(heroSel.TopSupport, 1)
			elseif PickCycle == 5 then
				hero = heroSel.BotSupport[1]
				table.remove(heroSel.BotSupport, 1)
			end
		end
		if PickCycle == 1 then
			picks[hero] = LANE_TOP
		elseif PickCycle == 2 then
			picks[hero] = LANE_BOT
		elseif PickCycle == 3 then
			picks[hero] = LANE_MID
		elseif PickCycle == 4 then
			picks[hero] = LANE_TOP
		elseif PickCycle == 5 then
			picks[hero] = LANE_BOT
		end
	end
end

function module.GetLane(npcBot)
	local team = GetTeam()
	local hero = npcBot:GetUnitName()
	if (picks == nil) then
		ReconstructPicks()
	end
	return picks[hero]
end

function module.GetTower1(npcBot)
	local team = GetTeam()
	local tower = nil
	local myLane = module.GetLane(npcBot)
	local pID = npcBot:GetPlayerID()
	if (myLane == LANE_TOP) then
		tower = GetTower(team, TOWER_TOP_1)
	elseif (myLane == LANE_BOT) then
		tower = GetTower(team, TOWER_BOT_1)
	else
		tower = GetTower(team, TOWER_MID_1)
	end
	return tower
end

function module.GetTower2(npcBot)
	local team = GetTeam()
	local tower = nil
	local myLane = module.GetLane(npcBot)
	local pID = npcBot:GetPlayerID()
	if (myLane == LANE_TOP) then
		tower = GetTower(team, TOWER_TOP_2)
	elseif (myLane == LANE_BOT) then
		tower = GetTower(team, TOWER_BOT_2)
	else
		tower = GetTower(team, TOWER_MID_2)
	end
	return tower
end

----Assign castable item so it can be used----
function module.ItemSlot(npcBot, ItemName)
	local Slot = npcBot:FindItemSlot(ItemName)

	if (Slot >= 0 and Slot <= 5) then
		local Item = npcBot:GetItemInSlot(Slot)
		Slot = nil
		return Item
	end

	return nil
end

local MELEE = 1
local RANGED = 2
local attackType =
{
	["npc_dota_hero_chaos_knight"] = MELEE,
	["npc_dota_hero_sven"] = MELEE,
	["npc_dota_hero_mars"] = MELEE,
	["npc_dota_hero_phantom_lancer"] = MELEE,
	["npc_dota_hero_axe"] = MELEE,
	["npc_dota_hero_juggernaut"] = MELEE,
	["npc_dota_hero_tidehunter"] = MELEE,
	["npc_dota_hero_abaddon"] = MELEE,
	["npc_dota_hero_ogre_magi"] = MELEE,
	["npc_dota_hero_medusa"] = RANGED,
	["npc_dota_hero_obsidian_destroyer"] = RANGED,
	["npc_dota_hero_tinker"] = RANGED,
	["npc_dota_hero_bane"] = RANGED,
	["npc_dota_hero_lich"] = RANGED,
	["npc_dota_hero_crystal_maiden"] = RANGED,
	["npc_dota_hero_lion"] = RANGED,
	["npc_dota_hero_skeleton_king"] = MELEE,
	["npc_dota_hero_jakiro"] = RANGED,
	["npc_dota_hero_legion_commander"] = MELEE,
	["npc_dota_abyssal_underlord"] = MELEE
}

local turnRate =
{
	["npc_dota_hero_chaos_knight"] = 0.5,
	["npc_dota_hero_sven"] = 0.6,
	["npc_dota_hero_mars"] = 0.8,
	["npc_dota_hero_phantom_lancer"] = 0.6,
	["npc_dota_hero_axe"] = 0.6,
	["npc_dota_hero_juggernaut"] = 0.6,
	["npc_dota_hero_tidehunter"] = 0.5,
	["npc_dota_hero_abaddon"] = 0.5,
	["npc_dota_hero_ogre_magi"] = 0.6,
	["npc_dota_hero_medusa"] = 0.5,
	["npc_dota_hero_obsidian_destroyer"] = 0.5,
	["npc_dota_hero_tinker"] = 0.6,
	["npc_dota_hero_bane"] = 0.6,
	["npc_dota_hero_lich"] = 0.5,
	["npc_dota_hero_crystal_maiden"] = 0.5,
	["npc_dota_hero_lion"] = 0.5,
	["npc_dota_hero_skeleton_king"] = 0.5,
	["npc_dota_hero_jakiro"] = 0.5,
	["npc_dota_hero_legion_commander"] = 0.5,
	["npc_dota_hero_abyssal_underlord"] = 0.6
}

function module.GetTimeToFace(npcBot, unit)
	local angle = npcBot:GetFacing()
	local dirFacing = Vector(math.cos(angle), math.sin(angle), 0)
	local enemyLocation = unit:GetLocation()
	enemyLocation.z = 0
	local myLocation = npcBot:GetLocation()
	myLocation.z = 0
	local dirToUnit = enemyLocation - myLocation
	dirToUnit = dirToUnit / math.sqrt(dirToUnit.x^2 + dirToUnit.y^2)
	local myTurnRate = turnRate[npcBot:GetUnitName()]
	return math.acos(module.dot(dirFacing, dirToUnit)) * 0.03 / myTurnRate
end

function module.findKillableCreep(npcBot, enemyCreepList, allyCreepList, damage)
	for _,v in pairs(enemyCreepList) do
		local health = module.PredictTiming(npcBot, v, allyCreepList)
		if health > 0 and health <= v:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL) then
			return v
		end
	end
	for _,v in pairs(allyCreepList) do
		if module.CalcPerHealth(v) < 0.5 then
			local health = module.PredictTiming(npcBot, v, enemyCreepList)
			if health > 0 and health <= v:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL) then
				return v
			end
		end
	end
	return nil
end

function module.PredictTiming(npcBot, weakestCreep, opposingCreepsList)
	local attackTime =  npcBot:GetSecondsPerAttack() * npcBot:GetAttackPoint() + module.GetTimeToFace(npcBot, weakestCreep)
	local attackRange = npcBot:GetAttackRange()
	if (GetUnitToUnitDistance(npcBot, weakestCreep) <= attackRange) then
		if attackType[npcBot:GetUnitName()] == RANGED then
			attackTime = attackTime + GetUnitToUnitDistance(npcBot, weakestCreep) / npcBot:GetAttackProjectileSpeed()
		end
	else
		attackTime = attackTime + (GetUnitToUnitDistance(npcBot, weakestCreep) - attackRange) / npcBot:GetCurrentMovementSpeed()
		if attackType[npcBot:GetUnitName()] == RANGED then
			attackTime = attackTime + attackRange / npcBot:GetAttackProjectileSpeed()
		end
	end
	return module.predictHealth(npcBot, weakestCreep, opposingCreepsList, attackTime)
end

function module.predictHealth(npcBot, creep, opposingCreepList, time)
	local health = creep:GetHealth()
	local targetingCreeps = {}
	for k,v in pairs(opposingCreepList) do
		if v:GetAttackTarget() == creep then
			table.insert(targetingCreeps, v)
		end
	end
	for k,v in pairs(targetingCreeps) do
		local name = v:GetUnitName()
		local anim = v:GetAnimActivity()
		local attackPoint = v:GetAttackPoint()
		local animCycle = v:GetAnimCycle()
		local spa = v:GetSecondsPerAttack()
		local projSpeed = v:GetAttackProjectileSpeed()
		if (anim == ACTIVITY_ATTACK or anim == ACTIVITY_ATTACK2 or anim == ACTIVITY_ATTACK_EVENT) and attackPoint > animCycle then
			if name == "npc_dota_creep_goodguys_melee" or name == "npc_dota_creep_badguys_melee" then
				if (attackPoint - animCycle) * spa < time then
					health = health - creep:GetActualIncomingDamage(v:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
				end
			else
				if (attackPoint - animCycle) * spa + GetUnitToUnitDistance(v, creep) / projSpeed < time then
					health = health - creep:GetActualIncomingDamage(v:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
				end
			end
		end
	end
	for k,v in pairs(creep:GetIncomingTrackingProjectiles()) do
		if v.is_attack and v.ability == nil and v.caster ~= nil and GetUnitToLocationDistance(creep, v.location) / v.caster:GetAttackProjectileSpeed() < time then
			health = health - creep:GetActualIncomingDamage(v.caster:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
		end
	end
--	if npcBot:GetUnitName() == "npc_dota_hero_bane" then
--		print(health)
--	end
 	return health
end

function module.IsDisabled(unit)
	if (not unit:IsNightmared() and
	(unit:IsBlind() or
	unit:IsBlockDisabled() or
	unit:IsDisarmed() or
	unit:IsEvadeDisabled() or
	unit:IsHexed() or
	unit:IsMuted() or
	unit:IsRooted() or
	unit:IsSilenced() or
	unit:IsStunned())) then
		return true
	else
		return false
	end
end

function module.IsHardCC(unit)
	if (unit:IsHexed() or
	unit:IsRooted() or
	unit:IsStunned()) then
		return true
	else
		return false
	end
end

function module.IsEnhanced(unit)
	if (unit:IsInvulnerable() or unit:IsMagicImmune() or unit:IsAttackImmune()) then
		return true
	else
		return false
	end
end

----Find weakest enemy unit (Creep or Hero) and their health----
function module.GetWeakestUnit(Enemy)
	if (Enemy == nil or #Enemy == 0) then
		return nil, 0
	end

	local WeakestUnit = Enemy[1]
	local LowestHealth = Enemy[1]:GetHealth()
	for _,unit in pairs(Enemy)
	do
		if (unit ~= nil and unit:IsAlive()) then
			if (unit:GetHealth() < LowestHealth) then
				LowestHealth = unit:GetHealth()
				WeakestUnit = unit
			end
		end
	end

	return WeakestUnit,LowestHealth
end

function module.GetHighestHealth(Enemy)
	if (Enemy == nil or #Enemy == 0) then
		return nil, 0
	end

	local highestUnit = Enemy[1]
	local highestHealth = Enemy[1]:GetHealth()
	for _,unit in pairs(Enemy) do
		if (unit ~= nil and unit:IsAlive()) then
			if (unit:GetHealth() > highestHealth) then
				highestHealth = unit:GetHealth()
				highestUnit = unit
			end
		end
	end

	return highestUnit,highestHealth
end

----Find theoretically most powerful unit (ally or enemy)----
function module.GetStrongestHero(Hero)
	if (Hero == nil or #Hero == 0) then
		return nil, 10000
	end

	local PowUnit = nil
	local PowHealth = 1
	local Power = 0.0
	for _,unit in pairs(Hero)
	do
		if (unit ~= nil and unit:IsAlive()) then
			if (unit:GetRawOffensivePower() > Power) then
				PowHealth = unit:GetHealth()
				PowUnit = unit
			end
		end
	end

	return PowUnit,PowHealth
end


function module.HighestAttackSpeed(HeroList)
	if (HeroList ~= nil and #HeroList > 0) then
		local target = HeroList[1]
		for _,unit in pairs(HeroList) do
			if (unit:GetAttackSpeed() >= target:GetAttackSpeed()) then
				target = unit
			end
		end
		return target
	end

	return nil
end

function module.CanWeKillThem(npcBot, target)
    if (target == nil) then
        return false
    end

    local targetHealth = target:GetHealth()
    return npcBot:GetEstimatedDamageToTarget(true, target, 3.0, DAMAGE_TYPE_ALL) >= targetHealth
end


function module.ConsiderKillPing(npcBot, target)
	if (module.CanWeKillThem(npcBot, target)) then
		local ping = target:GetExtrapolatedLocation(1)
		npcBot:ActionImmediate_Ping(ping.x, ping.y, true)
	end
end

----Smart Target----
function module.SmartTarget(npcBot)
	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local unitName = npcBot:GetUnitName()
	local target = nil

	if (eHeroList ~= nil and #eHeroList > 0) then
		if (aHeroList ~= nil and #aHeroList > 1 and aHeroList[2]:GetAttackTarget() ~= nil
				and (aHeroList[2]:GetAttackTarget()):IsHero()) and not aHeroList[2]:GetAttackTarget():IsNightmared() then
			target = aHeroList[2]:GetAttackTarget()
			return target
		end

		for _,unit in pairs(eHeroList) do
			if (unit:IsChanneling()) then
				target = unit
				return target
			end
		end

		for _,unit in pairs(eHeroList) do
			if (module.IsDisabled(unit)) then
				target = unit
				return target
			end
		end

		---percent health


		lowHero,lowHealth = module.GetWeakestUnit(eHeroList)
		powHero,powHealth = module.GetStrongestHero(eHeroList)
		if (lowHero ~= eHeroList[1] and GetUnitToUnitDistance(npcBot, lowHero) > 600 and GetUnitToUnitDistance(npcBot, eHeroList[1]) < 300
				and not eHeroList[1]:IsNightmared()) then
			target = eHeroList[1]
			return target
		elseif (lowHealth <= powHealth and not lowHero:IsNightmared()) then
			target = lowHero
			return target
		elseif (not powHero:IsNightmared()) then
			target = powHero
			return target
		end

		for _,unit in pairs(eHeroList)do
			if (not unit:IsNightmared()) then
				target = unit
				return target
			end
		end
		if target == nil then
			target = eHeroList[1]
		end
	end

	return target

end

function module.DangerPing(npcBot)
	local eHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local aHeroList = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local actualAlly = 0
	local actualEnemy = 0

	for _,unit in pairs(aHeroList) do
		if (unit ~= nil and unit:IsAlive()) then
			actualAlly = actualAlly + 1
		end
	end

	for _,unit in pairs(eHeroList) do
		if (unit ~= nil and unit:IsAlive()) then
			actualEnemy = actualEnemy + 1
		end
	end

	if (eHeroList ~= nil and #eHeroList > 0 and actualEnemy > actualAlly and npcBot:IsAlive()) then
		local dangerPing = eHeroList[1]:GetLocation()
		npcBot:ActionImmediate_Ping(dangerPing.x, dangerPing.y, false)
	end
end

function module.BounceSpells(npcBot, bounceRadius)
	local bounceCount = 0
	local bouncer = npcBot
	local bounceList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if (#bounceList <= 1) then
		return bounceCount
	end

	--hit heroes that are close to us
	for _,unit in pairs(bounceList) do
		if (GetUnitToLocationDistance(bouncer, unit:GetLocation()) <= bounceRadius - 25) then
			bounceCount = bounceCount + 1
		end
		bouncer = unit
	end
	return bounceCount
end

----Last hit minions----
function module.lastHit(WeakestCreep, CreepHealth, npcBot)
	if (WeakestCreep ~= nil) then
		if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= 1500) then
			if (CreepHealth <= npcBot:GetAttackDamage()) then
				--if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= npcBot:GetAttackRange()) then
				--npcBot:Action_AttackUnit(WeakestCreep, false)
				--else
				npcBot:Action_MoveToUnit(WeakestCreep)
				--	npcBot:Action_AttackUnit(WeakestCreep)
				--end
			end
		end
	end
end

function module.dot(vec1, vec2)
	return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

function module.length(vec1)
	return math.sqrt(module.dot(vec1, vec1))
end

function PointInRect(p, a, b, c, d)
	local ap = p - a
	local ab = b - a
	local ad = d - a
	return 0 <= module.dot(ap, ab) and module.dot(ap, ab) <= module.dot(ab, ab) and
		0 <= module.dot(ap, ad) and module.dot(ap, ad) <= module.dot(ad, ad)
	-- local ap = Vector(p.x - a.x, p.y - a.y, 0)
	-- local ab = Vector(b.x - a.x, b.y - a.y, 0)
	-- local ad = Vector(d.x - a.x, d.y - a.y, 0)
	-- return 0 <= ap.x * ab.x + ap.y * ab.y and
	-- 	ap.x * ab.x + ap.y * ab.y <= ab.x^2 + ab.y^2 and
	-- 	0 <= ap.x * ad.x + ap.y * ad.y and
	-- 	ap.x * ad.x + ap.y * ad.y <= ad.x^2 + ad.y^2 and
end

function IntersectCR(circleCenter, r, a, b, c, d)
	circleCenter.z = 0
	a.z = 0
	b.z = 0
	c.z = 0
	d.z = 0
	return PointInRect(circleCenter, a, b, c, d) or
		PointToLineDistance(a, b, circleCenter).distance <= r or
		PointToLineDistance(b, c, circleCenter).distance <= r or
		PointToLineDistance(c, d, circleCenter).distance <= r or
		PointToLineDistance(d, a, circleCenter).distance <= r
end

function VectorNormalize(vec)
	return vec / math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
end

function module.GetDodgableIncomingLinearProjectiles(npcBot)
	local projectiles = GetLinearProjectiles()
	local bounding = npcBot:GetBoundingRadius()
	local output = {}
	for k,v in pairs(projectiles) do
		if GetUnitToLocationDistance(npcBot, v.location) < 1200 then
			local prepVec = VectorNormalize(Vector(v.velocity.y, -v.velocity.x, 0))
			local normalVelocity = VectorNormalize(v.velocity)
			prepVec = prepVec * v.radius * 1.05
			if IntersectCR(npcBot:GetLocation(), bounding,
				v.location + prepVec,
				v.location + prepVec + normalVelocity,
				v.location - prepVec + normalVelocity,
				v.location - prepVec) then
				--little bit conservative.
				local timeToDodge = GetUnitToLocationDistance(npcBot, v.location) /
					(math.sqrt(v.velocity.x^2 + v.velocity.y^2 + v.velocity.z^2))
				local distanceToDodge = v.radius + bounding - PointToLineDistance(v.location, v.location + v.velocity * timeToDodge, npcBot:GetLocation()).distance
				if distanceToDodge / npcBot:GetCurrentMovementSpeed() < timeToDodge then
					table.insert(output, v)
				end
			end
		end
	end
	return output
end

----Retreat Function----
function module.BTFO(npcBot)
	local Health = npcBot:GetHealth()
	local MaxHealth = npcBot:GetMaxHealth()
	local percentHealth = Health/MaxHealth

	RADIANT_FOUNTAIN = Vector(-6750 ,-6550, 512)
	DIRE_FOUNTAIN = Vector(6780, 6124, 512)

	if (percentHealth <= 0.9) then
		npcBot:ActionImmediate_Chat("RUN 1!!!", true)
		if (npcBot:GetTeam() == 3) then
			AttackMove(npcbot, DIRE_FOUNTAIN)
		else
			AttackMove(npcbot, RADIANT_FOUNTAIN)
		end
		npcBot:ActionImmediate_Chat("RUN 2!!!", true)
	end
end
----End of Functions----

return module
