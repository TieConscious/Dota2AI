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
	local npcBot = GetBot()
	movement.Retreat(npcBot)
end

function Heal()
	local npcBot = GetBot()
	movement.RetreatToBase(npcBot)
end

function Hunt()
	--Generic enemy hunting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eHeros = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if (eHeros ~= nil and #eHeros > 0) then
		if (GetUnitToUnitDistance(npcBot, eHeros[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eHeros[1], false)
		else
			npcBot:Action_AttackUnit(eHeros[1], false)
			npcBot:ActionPush_MoveToUnit(eHeros[1])
		end
		return
	end
end

function Tower()
	--building fighting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eTowers = npcBot:GetNearbyTowers(1600, true)
	if (eTowers ~= nil and #eTowers > 0) then
		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eTowers[1], false)
		else
			npcBot:Action_AttackUnit(eTowers[1], false)
			npcBot:ActionPush_MoveToUnit(eTowers[1])
		end
		return
	end

	local eBarracks = npcBot:GetNearbyBarracks(1600, true)
	if (eBarracks ~= nil and #eBarracks > 0) then
		if (GetUnitToUnitDistance(npcBot, eBarracks[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eBarracks[1], false)
		else
			npcBot:Action_AttackUnit(eBarracks[1], false)
			npcBot:ActionPush_MoveToUnit(eBarracks[1])
		end
		return
	end

	local eAncient 
	if npcBot:getTeam() == 2 then
		eAncient = GetAncient(3)
	else
		eAncient = GetAncient(2)
	end
	if (eAncient ~= nil and GetUnitToUnitDistance(npcBot, eAncient) <= 1500) then
		if (GetUnitToUnitDistance(npcBot, eAncient) <= attackRange) then
			npcBot:Action_AttackUnit(eAncient, false)
		else
			npcBot:Action_AttackUnit(eAncient, false)
			npcBot:ActionPush_MoveToUnit(eAncient)
		end
		return
	end
	
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
	if (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetAttackDamage() * 3) then
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
