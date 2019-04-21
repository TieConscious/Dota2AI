local module = require(GetScriptDirectory().."/helpers")
local fortify_think = {

}

function fortify_think.Decide()
	local team = GetTeam()
	local npcBot = GetBot()
	local top = GetTower(team, TOWER_TOP_1)
	local mid = GetTower(team, TOWER_MID_1)
	local bot = GetTower(team, TOWER_BOT_1)

	if GetGlyphCooldown() ~= 0 then
		return
	end
	local unitList = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	if top ~= nil and top:IsAlive() and module.CalcPerHealth(top) < 0.15 then 
		for _,unit in pairs(unitList) do
			if unit:CanBeSeen() and GetUnitToUnitDistance(unit, top) < 1400 then
				npcBot:ActionImmediate_Glyph()
				return
			end
		end
	end
	if mid ~= nil and mid:IsAlive() and module.CalcPerHealth(mid) < 0.15 then
		for _,unit in pairs(unitList) do
			if unit:CanBeSeen() and GetUnitToUnitDistance(unit, mid) < 1400 then
				npcBot:ActionImmediate_Glyph()
				return
			end
		end
	end
	if bot ~= nil and bot:IsAlive() and module.CalcPerHealth(bot) < 0.15 then
		for _,unit in pairs(unitList) do
			if unit:CanBeSeen() and GetUnitToUnitDistance(unit, bot) < 1400 then
				npcBot:ActionImmediate_Glyph()
				return
			end
		end
	end
end	
return fortify_think
