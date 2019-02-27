
-- local BotPicks = {
-- 	'npc_dota_hero_bane',
-- 	'npc_dota_hero_chaos_knight',
-- 	'npc_dota_hero_juggernaut',
-- 	'npc_dota_hero_lich',
-- 	'npc_dota_hero_ogre_magi',
-- 	'npc_dota_hero_tinker',

-- 	'npc_dota_hero_medusa',


-- 	'npc_dota_hero_crystal_maiden',

-- 	'npc_dota_hero_tidehunter',

-- 	'npc_dota_hero_ursa', --broken
-- 	'npc_dota_hero_shadow_shaman', --broken

-- 	'npc_dota_hero_phantom_assassin',
-- 	'npc_dota_hero_abyssal_underlord',

-- 	'npc_dota_hero_pugna',

-- 	'npc_dota_hero_sven',

-- 	'npc_dota_hero_dazzle',

-- 	'npc_dota_hero_jakiro'
-- };

local TopPicks = {
	'npc_dota_hero_bane',
	'npc_dota_hero_chaos_knight'
}

local MidPicks = {
	'npc_dota_hero_ogre_magi'
}

local BotPicks = {
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_lich'
}

local BotBans = {
	'npc_dota_hero_sniper',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
    'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_venomancer',
    'npc_dota_hero_warlock',
    'npc_dota_hero_windrunner',
    'npc_dota_hero_witch_doctor',
	'npc_dota_hero_zuus',
	'npc_dota_hero_sven',
	'npc_dota_hero_slark'
}

function GetBotNames ()
	local bot_names = {}
	table.insert(bot_names, "@42SiliconValley")
	table.insert(bot_names, "@QwolfBLG")
	table.insert(bot_names, "@Lyd")
	table.insert(bot_names, "@mschroed098")
	table.insert(bot_names, "@2ne1ugly1")
	return bot_names
end

local picks = {};
local maxPlayerID = 20;
-- CHANGE THESE VALUES IF YOU'RE GETTING BUGS WITH BOTS NOT PICKING (or infinite loops)
-- To find appropriate values, start a game, open a console, and observe which slots are
-- being used by which players/teams. maxPlayerID shoulud just be the highest-numbered
-- slot in use.

local slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16, 17, 18,19,20}
local ListPickedHeroes = {};
local AllHeroesSelected = false
local BanCycle = 1
local NeededTime = 300

function Think()
	if GetGameMode() == GAMEMODE_CM then
		CaptainModeLogic()
	elseif GetGameMode() == GAMEMODE_AP then
		AllPickModeLogic()
	else
		return
	end
end

------------------------------------------ALL PICK MODE GAME MODE-------------------------------------------
--Picking logic for All Pick Mode Game Mode

function AllPickModeLogic()
	if ( GetTeam() == TEAM_RADIANT ) then
		print( "selecting radiant" );
		SelectHero( 2, 'npc_dota_hero_bane')
		SelectHero( 3, 'npc_dota_hero_chaos_knight')
		SelectHero( 4, 'npc_dota_hero_juggernaut')
		SelectHero( 5, 'npc_dota_hero_lich')
		SelectHero( 6, 'npc_dota_hero_ogre_magi')
	elseif ( GetTeam() == TEAM_DIRE ) then
		print( "selecting dire" );
		SelectHero( 7, 'npc_dota_hero_drow_ranger')
		SelectHero( 8, 'npc_dota_hero_kunkka')
		SelectHero( 9, 'npc_dota_hero_zuus')
		SelectHero( 10, 'npc_dota_hero_earthshaker')
		SelectHero( 11, 'npc_dota_hero_nevermore')
	end
end

------------------------------------------CAPTAIN'S MODE GAME MODE-------------------------------------------
--Picking logic for Captain's Mode Game Mode
local lastState = -1
function CaptainModeLogic()
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
        return
    end
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		PickCaptain()
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 18 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero()
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero()
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		--SelectsHero()
		return
	end
end

--Pick the captain
function PickCaptain()
	local CaptBot = GetFirstBot();
	if CaptBot ~= nil then
		SetCMCaptain(CaptBot)
	end

end

--Get the first bot to be the captain
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id
			return BotId
        end
    end
	return BotId;
end

--Ban hero function
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	local BannedHero = PickBan()
	CMBanHero(BannedHero)
	BanCycle = BanCycle + 1
end

local PickCycle = 1
--Pick hero function
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	local PickedHero = nil
	if PickCycle == 1 then
		PickedHero = PickHero()
		table.insert(ListPickedHeroes, PickedHero)
	elseif	PickCycle == 2 then
		PickedHero = PickHero()
		table.insert(ListPickedHeroes, PickedHero)
	elseif	PickCycle == 3 then
		PickedHero = PickHero()
		table.insert(ListPickedHeroes, PickedHero)
	elseif	PickCycle == 4 then
		PickedHero = PickHero()
		table.insert(ListPickedHeroes, PickedHero)
	elseif	PickCycle == 5 then
		PickedHero = PickHero()
		table.insert(ListPickedHeroes, PickedHero)
	end

	if PickedHero ~= nil then
		CMPickHero(PickedHero)
		PickCycle = PickCycle + 1
	end
end

--Random hero which is non picked, non banned, or non human picked heroes if the human is the captain
function PickHero()
	local hero = nil
	if PickCycle == 1 or PickCycle == 2 then
		hero = TopPicks[1]
	elseif	PickCycle == 3 then
		hero = MidPicks[1]
	elseif	PickCycle == 4 or PickCycle == 5 then
		hero = BotPicks[1]
	end

	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero)) do
		if PickCycle == 1 or PickCycle == 2 then
			hero = TopPicks[1]
			table.remove(TopPicks, 1)
		elseif	PickCycle == 3 then
			hero = MidPicks[1]
			table.remove(MidPicks, 1)
		elseif	PickCycle == 4 or PickCycle == 5 then
			hero = BotPicks[1]
			table.remove(BotPicks, 1)
		end
	end
	if PickCycle == 1 or PickCycle == 2 then
		table.remove(TopPicks, 1)
	elseif	PickCycle == 3 then
		table.remove(MidPicks, 1)
	elseif	PickCycle == 4 or PickCycle == 5 then
		table.remove(BotPicks, 1)
	end
	return hero
end

--Random ban
function PickBan()
	local hero = BotBans[1]
	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero)) do
        table.remove(BotBans, 1)
        hero = BotBans[1]
    end
	return hero
end

--Select the rest of the heroes
--function SelectsHero()
--	if not AllHeroesSelected and GetCMPhaseTimeRemaining() < 30  then
--		--local RestBotPlayers = {}
--		local Bots = GetTeam()
--
--		--for i = 1, #RestBotPlayers do
--		if (Bots == TEAM_RADIANT) then
--			for i = 1, 5 do
--				SelectHero(ListPickedHeroes[i])
--			end
--		elseif (Bots == TEAM_DIRE) then
--			for i = 1, 5 do
--
--			SelectHero(ListPickedHeroes[i])
--			end
--		end
--
--		AllHeroesSelected = true
--	end
--end
