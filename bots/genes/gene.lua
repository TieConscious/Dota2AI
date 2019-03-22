local geneList = {
	geneticTree =
	{

		['npc_dota_hero_chaos_knight'] = require(GetScriptDirectory().."/genes/gene_chaos_knight"),
		['npc_dota_hero_bane'] = require(GetScriptDirectory().."/genes/gene_bane"),
		['npc_dota_hero_juggernaut'] = require(GetScriptDirectory().."/genes/gene_juggernaut"),
		['npc_dota_hero_lich'] = require(GetScriptDirectory().."/genes/gene_lich"),
		['npc_dota_hero_ogre_magi'] = require(GetScriptDirectory().."/genes/gene_ogre_magi"),
		['npc_dota_hero_medusa'] = require(GetScriptDirectory().."/genes/gene_medusa")
	}
}

return geneList