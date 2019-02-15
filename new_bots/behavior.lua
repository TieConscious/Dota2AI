local movement = require(GetScriptDirectory().."/movement_util")
local module = require(GetScriptDirectory().."/helpers")

local behavior = {}

function behavior.generic(npcBot, stateMachine)
	--run generic behavior based on state
	if stateMachine.state == "retreat" then
		Retreat()
	elseif stateMachine.state == "heal" then
		Heal()
	elseif  stateMachine.state == "hunt" then
		Hunt()
	elseif stateMachine.state == "tower" then
		Tower()
	elseif stateMachine.state == "farm" then
		Farm()
	else
		Farm()
	end
end

function Retreat()
--retreating logic
end

function Heal()
--healing logic
end

function Hunt()
--Generic enemy hunting logic
end

function Tower()
--tower fighting logic
end

function Farm()
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()
	------Enemy and Creep stats----
	local eCreeps = npcBot:GetNearbyLaneCreeps(1600, true)
	local eWeakestCreep,eCreepHealth = module.GetWeakestUnit(eCreeps)
	local aCreeps = npcBot:GetNearbyLaneCreeps(1600, false)
	local aWeakestCreep,aCreepHealth = module.GetWeakestUnit(aCreeps)


	----Last-hit Creep----
	if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 2.5) then
		if (eCreepHealth <= npcBot:GetAttackDamage() or #aCreeps == 0) then
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= attackRange) then
				npcBot:Action_AttackUnit(eWeakestCreep, false)
			else
				npcBot:Action_AttackUnit(eWeakestCreep, false)
				npcBot:ActionPush_MoveToUnit(eWeakestCreep)
			end
		end
		if (GetUnitToUnitDistance(npcBot,WeakestCreep) > attackRange) then
			npcBot:ActionPush_MoveToUnit(eWeakestCreep)
		end
	----Deny creep----
	elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetAttackDamage()) then
		if (GetUnitToUnitDistance(npcBot,aWeakestCreep) <= attackRange) then
			npcBot:Action_AttackUnit(aWeakestCreep, false)
		end
	----Wack nearest creep----
	elseif (eCreeps[1] ~= nil) then
		if (GetUnitToUnitDistance(npcBot, eCreeps[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eCreeps[1], true)
		else
			npcBot:Action_AttackUnit(eCreeps[1], true)
			npcBot:ActionPush_MoveToUnit(eCreeps[1])
		end
	else
		movement.MTL_Farm(npcBot)
	end
end

return behavior
