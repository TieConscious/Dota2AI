
local BotPicks = {
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_medusa',
	'npc_dota_hero_pugna',
	'npc_dota_hero_axe',
	'npc_dota_hero_bane',
	'npc_dota_hero_earthshaker',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_furion',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_sniper',
	'npc_dota_hero_phoenix',
	'npc_dota_hero_phantom_assassin'
};

local BotBans = {
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
	'npc_dota_hero_slark',
	'npc_dota_hero_sniper'
};

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
local lastState = -1;
function CaptainModeLogic()
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
        return
    end
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		PickCaptain();
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 18 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero();
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero();
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectsHero();
	end
end
--Pick the captain
function PickCaptain()
	local CaptBot = GetFirstBot();
	if CaptBot ~= nil then
		print("CAPTAIN PID : "..CaptBot)
		SetCMCaptain(CaptBot)
	end

end

--Get the first bot to be the captain
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id;
			return BotId;
        end
    end
	return BotId;
end
--Ban hero function
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) then
		return
	end
	local BannedHero = RandomBan();
	print(BannedHero.." is banned")
	CMBanHero(BannedHero);
	BanCycle = BanCycle + 1;
end
--Pick hero function
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) then
		return
	end
	local PickedHero = RandomHero();
	if PickCycle == 1 then
		--while not role.CanBeOfflaner(PickedHero) do
		PickedHero = RandomHero();
		--end
		--PairsHeroNameNRole[PickedHero] = "offlaner";
	elseif	PickCycle == 2 then
		--while not role.CanBeSupport(PickedHero) do
		PickedHero = RandomHero();
		--end
		--PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 3 then
		--while not role.CanBeMidlaner(PickedHero) do
		PickedHero = RandomHero();
		--end
		--PairsHeroNameNRole[PickedHero] = "midlaner";
	elseif	PickCycle == 4 then
		--while not role.CanBeSupport(PickedHero) do
		PickedHero = RandomHero();
		--end
		--PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 5 then
		--while not role.CanBeSafeLaneCarry(PickedHero) do
		PickedHero = RandomHero();
		--end
		--PairsHeroNameNRole[PickedHero] = "carry";
	end
	print(PickedHero.." is picked")
	CMPickHero(PickedHero);
	PickCycle = PickCycle + 1;
end

--Random hero which is non picked, non banned, or non human picked heroes if the human is the captain
function RandomHero()
	local hero = BotPicks[RandomInt(1, #BotPicks)];
	while ( IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) )
	do
        hero = BotPicks[RandomInt(1, #BotPicks)];
    end
	return hero;
end

--Random ban
function RandomBan()
	local hero = BotBans[RandomInt(1, #BotBans)];
	while ( IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) )
	do
        hero = BotBans[RandomInt(1, #BotBans)];
    end
	return hero;
end

--Select the rest of the heroes that the human players don't pick in captain's mode
function SelectsHero()
	if not AllHeroesSelected and GetCMPhaseTimeRemaining() < 1 then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();

		for _,id in pairs(Players)
		do
			local hero_name =  GetSelectedHeroName(id);
			if hero_name ~= nil and hero_name ~= "" then
				UpdateSelectedHeroes(hero_name)
				print(hero_name.." Removed")
			else
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
--Get the team picked heroes
function GetTeamSelectedHeroes()
	for _,sName in pairs(BotPicks)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
	for _,sName in pairs(UnImplementedHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
end
--Update team picked heroes after human players select their desired hero
function UpdateSelectedHeroes(selected)
	for i=1, #ListPickedHeroes
	do
		if ListPickedHeroes[i] == selected then
			table.remove(ListPickedHeroes, i);
		end
	end
end

function CMLaneAssignment()
	if IsPlayerBot(GetCMCaptain()) then
		FillLaneAssignmentTable();
	else
		FillLAHumanCaptain()
	end
	return HeroLanes;
end
--Lane Assignment if the captain is not human
function FillLaneAssignmentTable()
	local supportAlreadyAssigned = false;
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name =  GetTeamMember(i):GetUnitName();
			if PairsHeroNameNRole[unit_name] == "support" and not supportAlreadyAssigned then
				HeroLanes[i] = LANE_TOP;
				supportAlreadyAssigned = true;
			elseif PairsHeroNameNRole[unit_name] == "support" and supportAlreadyAssigned then
				HeroLanes[i] = LANE_BOT;
			elseif PairsHeroNameNRole[unit_name] == "midlaner" then
				HeroLanes[i] = LANE_MID;
			elseif PairsHeroNameNRole[unit_name] == "offlaner" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_TOP;
				else
					HeroLanes[i] = LANE_BOT;
				end
			elseif PairsHeroNameNRole[unit_name] == "carry" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_BOT;
				else
					HeroLanes[i] = LANE_TOP;
				end
			end
		end
	end
end
