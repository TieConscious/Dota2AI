local module = require(GetScriptDirectory().."/helpers")

--conditionals--
--tower-----------------------------------------------------------------------------
function willEnemyTowerTargetMeWithAlly(npcBot)
	local ACreepsInTowerRange = module.GetAllyCreepInTowerRange(npcBot, 800)
	local nearbyEnemyTowers = npcBot:GetNearbyTowers(700, true)
	if nearbyEnemyTowers[1] ~= nil and nearbyEnemyTowers[1]:GetAttackTarget() == npcBot and #ACreepsInTowerRange ~= 0 then
		return true
	end
	return false
end

function possibleDeaggro(npcBot)
	return 80
end
------------------------------------------------------------------------------------
local deaggro_weight = {
    settings =
    {
        name = "deaggro", 
    
        components = {
		},
    
        conditionals = {
			{func=possibleDeaggro, condition=willEnemyTowerTargetMeWithAlly, weight=1},	
        }
    }
}

return deaggro_weight