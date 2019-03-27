local geneList = {
	geneticTree =
	{
		--['npc_dota_hero_chaos_knight'] = require(GetScriptDirectory().."/genes/gene_chaos_knight"),
		['npc_dota_hero_bane'] = require(GetScriptDirectory().."/genes/gene_bane"),
		--['npc_dota_hero_juggernaut'] = require(GetScriptDirectory().."/genes/gene_juggernaut"),
		--['npc_dota_hero_lich'] = require(GetScriptDirectory().."/genes/gene_lich"),
		['npc_dota_hero_ogre_magi'] = require(GetScriptDirectory().."/genes/gene_ogre_magi"),
		['npc_dota_hero_medusa'] = require(GetScriptDirectory().."/genes/gene_medusa"),
		--['npc_dota_hero_lion'] = require(GetScriptDirectory().."/genes/gene_lion"),
		--['npc_dota_hero_tidehunter'] = require(GetScriptDirectory().."/genes/gene_tidehunter"),
		--['npc_dota_hero_crystal_maiden'] = require(GetScriptDirectory().."/genes/gene_crystal_maiden"),
		--['npc_dota_hero_tinker'] = require(GetScriptDirectory().."/genes/gene_tinker"),
		['npc_dota_hero_skeleton_king'] = require(GetScriptDirectory().."/genes/gene_skeleton_king"),
		['npc_dota_hero_jakiro'] = require(GetScriptDirectory().."/genes/gene_jakiro")
	}
}

function geneList.GetWeight(unitName, weightName)
	return geneList.geneticTree[unitName][weightName]
end

return geneList