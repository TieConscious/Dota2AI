local botPicks = {}

local ZeroHeroes = {}
local ZeroBadGuyPicks = {
	'npc_dota_hero_drow_ranger',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_zuus',
	'npc_dota_hero_earthshaker',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_axe',
	'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_lina',
	'npc_dota_hero_lion',
	'npc_dota_hero_luna',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_oracle',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_pudge',
	'npc_dota_hero_razor',
	'npc_dota_hero_sand_king',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_sven',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_tiny',
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_viper',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_witch_doctor',
	--'npc_dota_hero_skeleton_king'
}

local APPicks = {
	'npc_dota_hero_jakiro',
	'npc_dota_hero_bane',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_medusa',
 	'npc_dota_hero_tinker',
 	'npc_dota_hero_crystal_maiden',
 	'npc_dota_hero_tidehunter',
 	'npc_dota_hero_ursa', --broken
 	'npc_dota_hero_shadow_shaman', --broken
 	'npc_dota_hero_phantom_assassin',
 	'npc_dota_hero_abyssal_underlord',
 	'npc_dota_hero_pugna',
 	'npc_dota_hero_sven',
	'npc_dota_hero_dazzle'
	--'npc_dota_hero_lion',
	--'npc_dota_hero_chaos_knight',
 	--'npc_dota_hero_juggernaut',
 	--'npc_dota_hero_lich',
}

local TopCarry = {
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_tiny",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_legion_commander"

	--"npc_dota_hero_chaos_knight",
	--"npc_dota_hero_viper",
	--"npc_dota_hero_lycan"
	--"npc_dota_hero_sven",
}

local BotCarry = {
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_juggernaut",
	"npc_dot_hero_naga_siren"

	--"npc_dota_hero_medusa"
}

local Mid = {
	"npc_dota_hero_medusa",
	--"npc_dota_hero_ogre_magi",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_tinker"
}

local TopSupport = {
	"npc_dota_hero_jakiro",
	"npc_dota_hero_lich",
	--"npc_dota_hero_bane",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_riki"
}

local BotSupport = {
	"npc_dota_hero_bane",
	--"npc_dota_hero_lich",

	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_lion"
}



local Bans = {
	--'npc_dota_hero_jakiro',
	'npc_dota_hero_warlock',
	'npc_dota_hero_phantom_lancer',
	'npc_dota_hero_sniper',
	'npc_dota_hero_silencer',
	'npc_dota_hero_tinker',
    'npc_dota_hero_slark',
	'npc_dota_hero_riki',
    'npc_dota_hero_medusa',
    'npc_dota_hero_witch_doctor',
	'npc_dota_hero_naga_siren',
	'npc_dota_hero_sven',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_winter_wyvern'
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

local picks = {}
local maxPlayerID = 20
-- CHANGE THESE VALUES IF YOU'RE GETTING BUGS WITH BOTS NOT PICKING (or infinite loops)

-- To find appropriate values, start a game, open a console, and observe which slots are
-- being used by which players/teams. maxPlayerID shoulud just be the highest-numbered
-- slot in use.

local slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}
local ListPickedHeroes = {}
local AllHeroesSelected = false
local BanCycle = 1
local NeededTime = 300

function Think()
	if GetGameMode() == GAMEMODE_CM then
		CaptainModeLogic()
	elseif GetGameMode() == GAMEMODE_AP then
		AllPickModeLogic()
	elseif GetGameMode() == 0 then
		ZeroPickLogic()
	else
		return
	end
end

------------------------------------------ALL PICK MODE GAME MODE-------------------------------------------
--Picking logic for All Pick Mode Game Mode

function ZeroPickLogic()
	if (GetTeam() == TEAM_RADIANT) then
		SelectsHero(APPicks)
	elseif (GetTeam() == TEAM_DIRE) then
		for i = 1, 5 do
			RandomZeroHero()
		end
		SelectsHero(ZeroHeroes)
	end
end

function AllPickModeLogic()
	if (GetTeam() == TEAM_RADIANT) then
		print("selecting radiant")
		SelectsHero(APPicks)
	elseif (GetTeam() == TEAM_DIRE) then
		print("selecting dire")
		for i = 1, 5 do
			RandomZeroHero()
		end
		SelectsHero(ZeroHeroes)
	end
end

local randomSeed = nil

function RandomZeroHero()
	if randomSeed == nil then
		math.randomseed(RealTime())
		randomSeed = true
	end
	local number = math.random(1, #ZeroBadGuyPicks)
	local hero = ZeroBadGuyPicks[number]
	table.insert(ZeroHeroes, hero)
	table.remove(ZeroBadGuyPicks, number)
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
		SelectsHero(ListPickedHeroes)
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
	if PickCycle == 1 then
		hero = TopCarry[1]
		table.remove(TopCarry, 1)
	elseif PickCycle == 2 then
		hero = BotCarry[1]
		table.remove(BotCarry, 1)
	elseif PickCycle == 3 then
		hero = Mid[1]
		table.remove(Mid, 1)
	elseif	PickCycle == 4 then
		hero = TopSupport[1]
		table.remove(TopSupport, 1)
	elseif PickCycle == 5 then
		hero = BotSupport[1]
		table.remove(BotSupport, 1)
	end
	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero)) do
		if PickCycle == 1 then
			hero = TopCarry[1]
			table.remove(TopCarry, 1)
		elseif PickCycle == 2 then
			hero = BotCarry[1]
			table.remove(BotCarry, 1)
		elseif PickCycle == 3 then
			hero = Mid[1]
			table.remove(Mid, 1)
		elseif	PickCycle == 4 then
			hero = TopSupport[1]
			table.remove(TopSupport, 1)
		elseif PickCycle == 5 then
			hero = BotSupport[1]
			table.remove(BotSupport, 1)
		end
	end
	local heroName = hero
	if PickCycle == 1 then
		botPicks[heroName] = 1
	elseif PickCycle == 2 then
		botPicks[heroName] = 1
	elseif PickCycle == 3 then
		botPicks[heroName] = 1
	elseif PickCycle == 4 then
		botPicks[heroName] = 1
	elseif PickCycle == 5 then
		botPicks[heroName] = 1
	end
	return hero
end

--Random ban
function PickBan()
	local hero = Bans[1]
	while (IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero)) do
        table.remove(Bans, 1)
        hero = Bans[1]
    end
	return hero
end

--Get player selected heroes--
function PlayerSelect(heroTable)
	local TeamPlayers = GetTeamPlayers(GetTeam())

	for _,pID in pairs(TeamPlayers) do
		if not IsPlayerBot(pID) then
			local playerPick = GetSelectedHeroName(pID)
			if playerPick ~= nil then
				print(pID.." chose "..playerPick)
				for i = 1, 5 do
					if playerPick == heroTable[i] then
						table.remove(heroTable, i)
					end
				end
			end
		end
	end
end

--Select the rest of the heroes
function SelectsHero(heroTable)
	local RestBotPlayers = GetTeamPlayers(GetTeam())
	PlayerSelect(heroTable)
	if not AllHeroesSelected then
		if GetGameMode() == GAMEMODE_CM then
			if GetCMPhaseTimeRemaining() > 30 then
				return
			end
		end
		local i = 1
		for _,pID in pairs(RestBotPlayers) do
			if IsPlayerBot(pID) then
				SelectHero(pID, heroTable[i])
				print(pID.." chose "..heroTable[i])
				i = i + 1
			end
		end

		AllHeroesSelected = true
	end
end
