local movement = require(GetScriptDirectory().."/movement_util")
local module = require(GetScriptDirectory().."/helpers")
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local courier_think = require(GetScriptDirectory().."/courier_think")
local consumable_think = require(GetScriptDirectory().."/consumable_think")
local buyback_think = require(GetScriptDirectory().."/buyback_think")
local minionBehavior = {}

function minionBehavior.generic(minion, master, stateMachine)
	--run generic minionBehavior based on state
	if  stateMachine.state == "hunt" then
		minionBehavior.Hunt(minion)
	elseif stateMachine.state == "tower" then
		minionBehavior.Tower(minion)
	elseif stateMachine.state == "farm" then
		minionBehavior.Farm(minion)
	else
		--minionBehavior.Farm(minion)
		minionBehavior.Idle(minion, master)
	end
end

function minionBehavior.Idle(minion, master)
	minion:Action_MoveToUnit(master)
end

function minionBehavior.Hunt(minion)
	--Generic enemy hunting logic
	local attackRange = minion:GetAttackRange()

	local eHeros = minion:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if (eHeros ~= nil and #eHeros > 0) then
		if (GetUnitToUnitDistance(minion, eHeros[1]) <= attackRange) then
			minion:Action_AttackUnit(eHeros[1], true)
		else
			minion:Action_MoveToUnit(eHeros[1])
		end
		return
	end
end

function minionBehavior.Tower(minion)
	--building fighting logic
	local attackRange = minion:GetAttackRange()

	local eTowers = minion:GetNearbyTowers(800, true)
	local eBarracks = minion:GetNearbyBarracks(1600, true)
	if (eBarracks ~= nil and #eBarracks > 0 and (eTowers == nil or #eTowers == 0)) then
		if (GetUnitToUnitDistance(minion, eBarracks[1]) <= attackRange + (eBarracks[1]:GetBoundingRadius() - 50)) then
			minion:Action_AttackUnit(eBarracks[1], true)
		else
			minion:Action_MoveToUnit(eBarracks[1])
		end
		return
	end

	eTowers = minion:GetNearbyTowers(1600, true)
	if (eTowers ~= nil and #eTowers > 0) then
		if (GetUnitToUnitDistance(minion, eTowers[1]) <= attackRange + (eTowers[1]:GetBoundingRadius() - 50)) then
			minion:Action_AttackUnit(eTowers[1], true)
		else
			minion:Action_MoveToUnit(eTowers[1])
		end
		return
	end

	local eAncient
	if minion:GetTeam() == 2 then
		eAncient = GetAncient(3)
	else
		eAncient = GetAncient(2)
	end
	if (eAncient ~= nil and GetUnitToUnitDistance(minion, eAncient) <= 1500) then
		if (GetUnitToUnitDistance(minion, eAncient) <= attackRange + (eAncient:GetBoundingRadius() - 50)) then
			minion:Action_AttackUnit(eAncient, true)
		else
			minion:Action_MoveToUnit(eAncient)
		end
		return
	end

end

function minionBehavior.Farm(minion)
	local attackRange = minion:GetAttackRange()
	------Enemy and Creep stats----
	local eCreeps = minion:GetNearbyLaneCreeps(1600, true)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(eCreeps)
	local aCreeps = minion:GetNearbyLaneCreeps(1600, false)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(aCreeps)


	----Last-hit Creep----
	if (eWeakestCreep ~= nil and eCreepHealth <= minion:GetEstimatedDamageToTarget(true, eWeakestCreep, minion:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 2) then
		if (eCreepHealth <= minion:GetEstimatedDamageToTarget(true, eWeakestCreep, minion:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 1.1 or #aCreeps < 0) then --number of enemies in the future
			if (GetUnitToUnitDistance(minion,WeakestCreep) <= attackRange) then
				minion:Action_AttackUnit(eWeakestCreep, true)
			else
				minion:Action_MoveToUnit(eWeakestCreep)
			end
		end
		if (GetUnitToUnitDistance(minion,WeakestCreep) > attackRange) then
			minion:Action_MoveToUnit(eWeakestCreep)
		end
	----Deny creep----
	elseif (aWeakestCreep ~= nil and aCreepHealth <= minion:GetEstimatedDamageToTarget(true, eWeakestCreep, minion:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) + 5) then
		if (GetUnitToUnitDistance(minion,aWeakestCreep) <= attackRange) then
			minion:Action_AttackUnit(aWeakestCreep, true)
		end
	----Push when no enemy heros around----
	elseif (eCreeps[1] ~= nil and minion:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ~= nil and #(minion:GetNearbyHeroes(1600, true, BOT_MODE_NONE)) == 0) then
		if (GetUnitToUnitDistance(minion, eCreeps[1]) <= attackRange) then
			minion:Action_AttackUnit(eCreeps[1], true)
		else
			minion:Action_MoveToUnit(eCreeps[1])
		end
	-- else
		--movement.MTL_Farm(minion)
	end
end

return minionBehavior
