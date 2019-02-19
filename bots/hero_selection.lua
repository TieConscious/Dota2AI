
local BotPicks = {
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_bane',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_medusa',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_abyssal_underlord',

	'npc_dota_hero_pugna',
	'npc_dota_hero_lich',
	'npc_dota_hero_sven',
	'npc_dota_hero_shadow_shaman',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_tinker',
	'npc_dota_hero_jakiro'
}

local BotBans = {
	'npc_dota_hero_sniper',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	'npc_dota_hero_ursa',
    'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_venomancer',
    'npc_dota_hero_warlock',
    'npc_dota_hero_windrunner',
    'npc_dota_hero_witch_doctor',
	'npc_dota_hero_zuus',
	'npc_dota_hero_slark'
}

function GetBotNames ()
	local bot_names = {}
	table.insert(bot_names, "@42SiliconValley");
	table.insert(bot_names, "@DOTA2");
	table.insert(bot_names, "@Lyd");
	table.insert(bot_names, "@QwolfBLG");
	table.insert(bot_names, "@mschroed098");
	return bot_names
end

local picks = {};
local maxPlayerID = 15;
-- CHANGE THESE VALUES IF YOU'RE GETTING BUGS WITH BOTS NOT PICKING (or infinite loops)
-- To find appropriate values, start a game, open a console, and observe which slots are
-- being used by which players/teams. maxPlayerID shoulud just be the highest-numbered
-- slot in use.

local slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
local ListPickedHeroes = {};
local AllHeroesSelected = false;
local BanCycle = 1;
local PickCycle = 1;
local NeededTime = 300;

function Think()
	if GetGameMode() == GAMEMODE_CM then
		CaptainModeLogic();
	end
end

------------------------------------------CAPTAIN'S MODE GAME MODE-------------------------------------------
--Picking logic for Captain's Mode Game Mode
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
		SelectsHero()
	end
end

----Pick the captain
function PickCaptain()
	if GetCMCaptain() == -1 then
		local CaptBot = GetFirstBot()
		if CaptBot ~= nil then
			print("CAPTAIN PID : "..CaptBot)
			SetCMCaptain(CaptBot)
		end
	end
end

----Get the first bot to be the captain
function GetFirstBot()
	local BotId = nil
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id;
			return BotId;
        end
    end
	return BotId;
end

----Ban hero function
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	local BannedHero = RandomBan();
	print(BannedHero.." is banned")
	CMBanHero(BannedHero);
	BanCycle = BanCycle + 1;
end

----Pick hero function
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	local PickedHero = RandomHero();
	if PickCycle == 1 then
		PickedHero = RandomHero();
	elseif	PickCycle == 2 then
		PickedHero = RandomHero();
	elseif	PickCycle == 3 then
		PickedHero = RandomHero();
	elseif	PickCycle == 4 then
		PickedHero = RandomHero();
	elseif	PickCycle == 5 then
		PickedHero = RandomHero();
	end
	print(PickedHero.." is picked")
	CMPickHero(PickedHero);
	PickCycle = PickCycle + 1;
end

----Random hero which is non picked, non banned, or non human picked heroes if the human is the captain
function RandomHero()
	local hero = BotPicks[1]
	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero))
	do
		table.remove(BotPicks, 1)
        hero = BotPicks[1]
    end
	return hero
end

----Random ban
function RandomBan()
	local hero = BotBans[1]
	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero))
	do
        table.remove(BotBans, 1)
        hero = BotBans[1]
    end
	return hero
end

----Select the rest of the heroes that the human players don't pick in captain's mode
function SelectsHero()
	if not AllHeroesSelected and GetCMPhaseTimeRemaining() < 1 then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();

		for _,id in pairs(Players)
		do
			local hero_name =  GetSelectedHeroName(id)
			if (hero_name ~= nil and hero_name ~= "") then
				table.insert(RestBotPlayers, id)
			end
		end

		for i = 1, #RestBotPlayers
		do
			SelectHero(RestBotPlayers[i], ListPickedHeroes[i])
		end

		AllHeroesSelected = true;
	end
end

----Get the team picked heroes
function GetTeamSelectedHeroes()
	for _,sName in pairs(BotPicks)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
end
