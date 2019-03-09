local movement = require(GetScriptDirectory().."/movement_util")
local module = require(GetScriptDirectory().."/helpers")
local buy_weight = require(GetScriptDirectory().."/weights/buy")
local courier_think = require(GetScriptDirectory().."/courier_think")
local consumable_think = require(GetScriptDirectory().."/consumable_think")
local buyback_think = require(GetScriptDirectory().."/buyback_think")
local globalState = require(GetScriptDirectory().."/global_state")
local behavior = {}

function behavior.generic(npcBot, stateMachine)
	courier_think.Decide()
	consumable_think.Decide()
	buyback_think.Decide()
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
	elseif stateMachine.state == "buy" then
		Buy()
	elseif stateMachine.state == "deaggro" then
		Deaggro()
	elseif stateMachine.state == "rune" then
		Rune()
	elseif stateMachine.state == "gank" then
		Gank()
	elseif stateMachine.state == "dodge" then
		Dodge()
	elseif stateMachine.state == "defend" then
		Defend()
	elseif stateMachine.state == "finishHim" then
		FinishHim()
	else
		Idle()
	end
end

function Idle()
	local npcBot = GetBot()
	local manaPer = module.CalcPerMana(npcBot)
	local team = GetTeam()
	local tower = module.GetTower1(npcBot)
	local lane = module.GetLane(npcBot)

	if npcBot:IsChanneling() then
		return
	end

	local front = GetLaneFrontLocation(team, lane, 0)

	local otherPlayers = GetTeamPlayers(team)
	local isInPosition = false
	for _,id in pairs(otherPlayers) do
		local hero = GetTeamMember(id)
		if hero ~= nil and GetUnitToLocationDistance(hero, front) < 2500 then
			isInPosition = true
		end
	end
	local time = DotaTime()

	local tpScroll = npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"))
	if tower ~= nil and time > 0 and not isInPosition and npcBot:DistanceFromFountain() == 0 and tpScroll ~= nil and tpScroll:IsCooldownReady()
		and tower:GetHealth() > 400 and manaPer >= 0.85 then
		npcBot:Action_UseAbilityOnLocation(tpScroll, tower:GetLocation())
	else
		movement.MTL_Farm(npcBot)
	end
end

function Retreat()
	local npcBot = GetBot()
	if npcBot:IsChanneling() then
		return
	end
	movement.Retreat(npcBot)
end

function Heal()
	local npcBot = GetBot()
	local salve = module.ItemSlot(npcBot, "item_flask")
	local clarity = module.ItemSlot(npcBot, "item_clarity")
	local nearbyAllyTower = npcBot:GetNearbyTowers(1600, false)

	if #nearbyAllyTower ~= 0 and GetUnitToUnitDistance(nearbyAllyTower[1], npcBot) < 500 and salve ~= nil and not npcBot:HasModifier("modifier_flask_healing") then
		npcBot:Action_UseAbilityOnEntity(salve, npcBot)
		return
	end
	if #nearbyAllyTower ~= 0 and GetUnitToUnitDistance(nearbyAllyTower[1], npcBot) < 500 and clarity ~= nil and not npcBot:HasModifier("modifier_clarity_potion") then
		npcBot:Action_UseAbilityOnEntity(clarity, npcBot)
		return
	end
	if #nearbyAllyTower ~= 0 then
		npcBot:Action_MoveToUnit(nearbyAllyTower[1])
		return
	end
	if salve ~= nil and not npcBot:HasModifier("modifier_flask_healing") then
		npcBot:Action_UseAbilityOnEntity(salve, npcBot)
		return
	end
	if clarity ~= nil and not npcBot:HasModifier("modifier_clarity_potion") then
		npcBot:Action_UseAbilityOnEntity(clarity, npcBot)
		return
	end
	movement.RetreatToBase(npcBot)
end

function Hunt()
	--Generic enemy hunting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eHeros = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if (eHeros ~= nil and #eHeros > 0) then
		if (GetUnitToUnitDistance(npcBot, eHeros[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eHeros[1], true)
		else
			npcBot:Action_MoveToUnit(eHeros[1])
		end
		return
	end
end

function Tower()
	--building fighting logic
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()

	local eTowers = npcBot:GetNearbyTowers(800, true)
	local eBarracks = npcBot:GetNearbyBarracks(1600, true)
	if (eBarracks ~= nil and #eBarracks > 0 and (eTowers == nil or #eTowers == 0)) then
		if (GetUnitToUnitDistance(npcBot, eBarracks[1]) <= attackRange + (eBarracks[1]:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eBarracks[1], true)
		else
			npcBot:Action_MoveToUnit(eBarracks[1])
		end
		return
	end

	eTowers = npcBot:GetNearbyTowers(1600, true)
	if (eTowers ~= nil and #eTowers > 0) then
		if (GetUnitToUnitDistance(npcBot, eTowers[1]) <= attackRange + (eTowers[1]:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eTowers[1], true)
		else
			npcBot:Action_MoveToUnit(eTowers[1])
		end
		return
	end

	local eAncient
	if npcBot:GetTeam() == 2 then
		eAncient = GetAncient(3)
	else
		eAncient = GetAncient(2)
	end
	if (eAncient ~= nil and GetUnitToUnitDistance(npcBot, eAncient) <= 1500) then
		if (GetUnitToUnitDistance(npcBot, eAncient) <= attackRange + (eAncient:GetBoundingRadius() - 50)) then
			npcBot:Action_AttackUnit(eAncient, true)
		else
			npcBot:Action_MoveToUnit(eAncient)
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
	if (eCreeps[1] ~= nil and npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE) ~= nil and #(npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)) == 0) then
		if (GetUnitToUnitDistance(npcBot, eCreeps[1]) <= attackRange) then
			npcBot:Action_AttackUnit(eCreeps[1], true)
		else
			npcBot:Action_MoveToUnit(eCreeps[1])
		end
	elseif (eWeakestCreep ~= nil and eCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 2) then
		if (eCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) * 1.1 or #aCreeps < 0) then --number of enemies in the future
			if (GetUnitToUnitDistance(npcBot,WeakestCreep) <= attackRange) then
				npcBot:Action_AttackUnit(eWeakestCreep, true)
			else
				npcBot:Action_MoveToUnit(eWeakestCreep)
			end
		elseif (GetUnitToUnitDistance(npcBot,WeakestCreep) > attackRange) then
			npcBot:Action_MoveToUnit(eWeakestCreep)
		else
			npcBot:Action_ClearActions(true)
		end
	----Deny creep----
	elseif (aWeakestCreep ~= nil and aCreepHealth <= npcBot:GetEstimatedDamageToTarget(true, eWeakestCreep, npcBot:GetAttackSpeed(), DAMAGE_TYPE_PHYSICAL) + 5) then
		if (GetUnitToUnitDistance(npcBot,aWeakestCreep) <= attackRange) then
			npcBot:Action_AttackUnit(aWeakestCreep, true)
		end
	----Push when no enemy heros around----
	else
		movement.MTL_Farm(npcBot)
	end
end

function Buy()
	local npcBot = GetBot()
	local nextItem = buy_weight.itemTree[npcBot:GetUnitName()][1]
	local SS1 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET)
	local SS2 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET2)
	local wand = module.ItemSlot(npcBot, "item_magic_wand")
	local closerSecretShop = nil
	if GetUnitToLocationDistance(npcBot, SS1) < GetUnitToLocationDistance(npcBot, SS2) then
		closerSecretShop = SS1
	else
		closerSecretShop = SS2
	end
	if (npcBot:GetItemInSlot(5) ~= nil and wand ~= nil) then
		npcBot:Action_DropItem(wand, npcBot:GetLocation())
		return
	end
	if IsItemPurchasedFromSecretShop(nextItem) then
		if npcBot:DistanceFromSecretShop() == 0 then
			npcBot:ActionImmediate_PurchaseItem(nextItem)
			table.remove(buy_weight.itemTree[npcBot:GetUnitName()], 1)
		else
			npcBot:Action_MoveToLocation(closerSecretShop)
		end
	else
		npcBot:ActionImmediate_PurchaseItem(nextItem)
		table.remove(buy_weight.itemTree[npcBot:GetUnitName()], 1)
	end
end

function Deaggro()
	local npcBot = GetBot()
	local attackRange = npcBot:GetAttackRange()
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 800)

	if GetUnitToUnitDistance(ACreepsInTowerRange[1], npcBot) > attackRange then
		npcBot:Action_MoveToUnit(ACreepsInTowerRange[1])
	else
		npcBot:Action_AttackUnit(ACreepsInTowerRange[1], true)
	end

end

local runes = {
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4
}

function Rune()
	local npcBot = GetBot()
	local pID = npcBot:GetPlayerID()
	local team = npcBot:GetTeam()
	local runeLoc
    for _,rune in pairs(runes) do
        runeLoc = GetRuneSpawnLocation(rune)
        if (GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE and GetUnitToLocationDistance(npcBot, runeLoc) < 1500) then
			if GetUnitToLocationDistance(npcBot, runeLoc) < 120 then
				npcBot:Action_PickUpRune(rune)
			else
				npcBot:Action_MoveToLocation(runeLoc)
			end
			return
        end
    end
	--if Dire--
	local myLane = module.GetLane(npcBot)
	if (team == 3) then
		if (myLane == LANE_TOP) then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_4))
		elseif (myLane == LANE_BOT) then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_2))
		else
            Farm()
		end
	--if Radiant--
	elseif (team == 2) then
		if (myLane == LANE_TOP) then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_1))
		elseif (myLane == LANE_BOT) then
            npcBot:Action_MoveToLocation(GetRuneSpawnLocation(RUNE_BOUNTY_3))
		else
			Farm()
		end
	else
		Farm()
    end
end

local pulledPushed = {
	[TEAM_RADIANT] =
	{
		[LANE_TOP] = {0.42, 0.65},
		[LANE_MID] = {0.52, 0.61},
		[LANE_BOT] = {0.65, 0.7}
	},
	[TEAM_DIRE] =
	{
		[LANE_TOP] = {0.7, 0.65},
		[LANE_MID] = {0.52, 0.61},
		[LANE_BOT] = {0.65, 0.42}
	},
}

local midTargetLane = LANE_BOT

function Gank()
	local npcBot = GetBot()
	local lane = module.GetLane(npcBot)
	local team = GetTeam()
	local targetLane = LANE_MID

	if npcBot:IsChanneling() then
		return
	end

	if lane == LANE_MID then
		local midDist = GetUnitToLocationDistance(npcBot, GetLaneFrontLocation(team, LANE_MID, 0))
		if  midDist < 2000 then
			if pulledPushed[team][LANE_BOT][1] < GetLaneFrontAmount(team, LANE_BOT, false) then
				midTargetLane = LANE_BOT
			elseif pulledPushed[team][LANE_TOP][1] < GetLaneFrontAmount(team, LANE_TOP, false) then
				midTargetLane = LANE_TOP
			else
				midTargetLane = LANE_BOT
			end
		end
		targetLane = midTargetLane
	else
		targetLane = LANE_MID
	end
	npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, targetLane, GetLaneFrontAmount(team, targetLane, false) + 0.15))
end

function Dodge()
	local npcBot = GetBot()
	local myLocation = npcBot:GetLocation()
	local projectile = module.GetDodgableIncomingLinearProjectiles(npcBot)[1]
	local perp = Vector(projectile.velocity.y, -projectile.velocity.x, 0)
	local angle = math.acos(module.dot(myLocation, projectile.location) / (module.length(myLocation) * module.length(projectile.location)))
	if math.pi < angle or angle < 0 then
		npcBot:Action_MoveDirectly(myLocation - perp)
	else
		npcBot:Action_MoveDirectly(myLocation + perp)
	end
end

function Defend()
	local npcBot = GetBot()
	local tpScroll = npcBot:GetItemInSlot(npcBot:FindItemSlot("item_tpscroll"))
	local eHeros = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local ancient
	local defendLane = LANE_TOP

	for lane,laneInfo in pairs(globalState.state.laneInfo) do
		if (laneInfo.numEnemies >  globalState.state.laneInfo[defendLane].numEnemies) then
			defendLane = lane
		end
	end

	if (npcBot:GetTeam() == 2) then
		ancient = GetAncient(2)
	else
		ancient = GetAncient(3)
	end

	if npcBot:IsChanneling() then
		return
	end

	if ancient ~= nil and #eHeros == 0 and npcBot:DistanceFromFountain() >= 5000 and tpScroll ~= nil and tpScroll:IsCooldownReady() then
		npcBot:Action_UseAbilityOnLocation(tpScroll, ancient:GetLocation())
	else
		npcBot:Action_MoveToLocation(GetLaneFrontLocation(GetTeam(), defendLane, 0))
	end
end

function FinishHim()
	local npcBot = GetBot()
	local pingLocation = npcBot:GetMostRecentPing().location
	local timeSince = npcBot:GetMostRecentPing().time
	local timeNow = GameTime()

	if (pingLocation ~= nil and timeSince ~= nil and (timeNow - timeSince) <= 2.0 and GetUnitToLocationDistance(npcBot, pingLocation) <= 1000) then
		npcBot:Action_MoveToLocation(pingLocation)
	end
end

return behavior
