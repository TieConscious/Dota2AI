local picks = {}

picks.TopPicks = {
--	['npc_dota_hero_bane'] = 1,
--	['npc_dota_hero_chaos_knight'] = 1
}

picks.MidPicks = {
--	['npc_dota_hero_ogre_magi'] = 1
}

picks.BotPicks = {
--	['npc_dota_hero_juggernaut'] = 1,
--	['npc_dota_hero_lich'] = 1
}

function picks.InsertTop(name)
	picks.TopPicks[name] = 1
end

function picks.InsertMid(name)
	picks.TopPicks[name] = 1
end

function picks.InsertBot(name)
	picks.TopPicks[name] = 1
end

return picks