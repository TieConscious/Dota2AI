
quickMode = true;
----------------------------------------------------------------------------------------------------

--function Think()
--
--
--	if ( GetTeam() == TEAM_RADIANT )
--	then
--		print( "selecting radiant" );
--		SelectHero( 2, "npc_dota_hero_pudge" );
--		SelectHero( 3, "npc_dota_hero_axe" );
--		SelectHero( 4, "npc_dota_hero_bane" );
--		SelectHero( 5, "npc_dota_hero_bloodseeker" );
--		SelectHero( 6, "npc_dota_hero_crystal_maiden" );
--	elseif ( GetTeam() == TEAM_DIRE )
--	then
--		print( "selecting dire" );
--		SelectHero( 7, "npc_dota_hero_sniper" );
--		SelectHero( 8, "npc_dota_hero_juggernaut" );
--		SelectHero( 9, "npc_dota_hero_furion" );
--		SelectHero( 10, "npc_dota_hero_phoenix" );
--		SelectHero( 11, "npc_dota_hero_phantom_assassin" );
--	end

--end

----------------------------------------------------------------------------------------------------

-------------------- Captain's Mode --------------------

local requiredHeroes = {
	npc_dota_hero_pudge
	npc_dota_hero_axe
	npc_dota_hero_bane
	npc_dota_hero_juggernaut
	npc_dota_hero_furion
	npc_dota_hero_bloodseeker
	npc_dota_hero_crystal_maiden
	npc_dota_hero_sniper
	npc_dota_hero_phoenix
	npc_dota_hero_phantom_assassin
}

-------------------- Game Mode Selection --------------------
function Think()
	print("in Think")
	if GetGameMode() == GAMEMODE_CM then
		print("in cap mode")
		CaptainsMode();
	end
end

-------------------- Captain's Mode Main --------------------
function CaptainsMode()
	print("in cap mode function")
	if GetGameState() ~= GAME_STATE_HERO_SELECTION then
		return
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		print("gonna pick cap")
		PickCaptain();
	--elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 then
	--	BansHero();
	--	NeededTime = 0
	--elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 then
		--PicksHero();
		--NeededTime = 0
	--elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		--SelectsHero();
	end
end

-------------------- Assign Captain --------------------
function PickCaptain()
	print("try to pick cap")
	if GetCMCaptain() == -1 then
		local CaptBot = GetFirstBot();
		if CaptBot ~= nil then
			print("CAPTAIN PID : "..CaptBot)
			SetCMCaptain(CaptBot)
		end
	end
end

-------------------- Find First Bot on Team --------------------
function GetFirstBot()
	print("first bottie bot")
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

-------------------- Ban Heroes --------------------
--function BansHero()
--	local BannedHero = RandomHero();
--	print(BannedHero.." is complete poopyshit")
--	CMBanHero(BannedHero);
--	BanCycle = BanCycle + 1;
--end
--
---------------------- Test Random Hero function --------------------
--function RandomHero()
--	local hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
--	return hero;
--end