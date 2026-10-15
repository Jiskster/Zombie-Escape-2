local PATH = "game/Gametypes"

local DEFAULT_RULES = (GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS|GTR_RINGSLINGER)

local gametypelist = {}
local settingslist = {}

local function getDefaultSettings()
	return { -- These settings are Escape's settings to build from.
		default_pregame_time = ZE2.DEFAULT_PREGAME_TIME, -- number (tics)
		default_rounds = ZE2.DEFAULT_ROUNDS, -- number (rounds)
		default_round_time = ZE2.DEFAULT_ROUND_TIME, -- number (tics)
		default_zombie_release_time = 10*TICRATE, -- number (tics)
		default_winner = 2, -- number (team)
		shop = true, -- if disabled, then cash is disabled.
		fall_damage = false, -- does this gametype have fall damage?
		force_loadout = { -- table with items
			[1] = nil,
			[2] = nil,
		}, 
		midgame_join = false, -- can players join midgame?
		zombie_after_death = false, -- decides if survivors respawn as zombies after dying (not infecting)
		move_during_pregame = false, -- can you move after you pressed done in pregame?
		respawn_time = {
			[1] = 10*TICRATE, -- survivors
			[2] = 15*TICRATE, -- zombies
		},
	}
end

xSlinger.skin_properties["zsonic"] = {
	hurtsound = {sfx_zpa1, sfx_zpa2};
}

function ZE2.AddGametype(name, description, rules)
	local newTOL_str = ("TOL_"..name:upper())
	local newTOL = freeslot(newTOL_str)
	G_AddGametype({
		name = name.." (ZE2)",
		identifier = name:lower(),
		typeoflevel = newTOL,
		rules = rules or DEFAULT_RULES,
		intermissiontype = int_none, -- We have ingame intermission, so we dont need an intermission type
		headerleftcolor = 152,
		headerrightcolor = 40,
		description = description,
	})

	local gt = constants["GT_"..name:upper()]
	gametypelist[gt] = true
	
	settingslist[gt] = getDefaultSettings()
	
	xSlinger.registerGametype(gt, {
		teams = {
			{
				name = "Survivors";
			},
			{
				name = "Zombies";
				iframes = 0;
			}
		}
	})
	
	return settingslist[gt]
end

function ZE2.isGametype()
	return gametypelist[gametype]
end

function ZE2.getGametypeSettings(_gt)
	if (multiplayer or netgame) then
		return settingslist[_gt or gametype] or getDefaultSettings()
	else
		return getDefaultSettings()
	end
end

local function LoadGametype(name)
	dofile(PATH .. "/" ..name .. "/gametype.lua")
end

LoadGametype "Escape"
LoadGametype "Plague"
LoadGametype "Swarm"

-- Stuff to happen in all ZE2 gametypes...

addHook("ViewpointSwitch", function(player, nextplayer, forced)
	if not ZE2.isGametype() then
		return
	end

	if player.spectator or nextplayer.spectator then
		return
	end

	if not (player.mo and player.mo.valid) 
	or not (nextplayer.mo and nextplayer.mo.valid) then
		return false
	end

	if nextplayer.mo.team ~= player.mo.team then
		return false
	end
	
	return true
end)

addHook("SeenPlayer", function()
	if (ZE2.isGametype()) then
		return false
	end
end)

function ZE2.GameReset(map)
	local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
	game.state_list = {"pregame", "game", "finish"}
	game.state = 1
	game.state_tics = 0
	if not game.queueround then 
		game.round = 1
	end
	game.maxrounds = tonumber(mapheaderinfo[map or gamemap].ze2_rounds) or settings.default_rounds
	game.ended = false
	game.active = false
	if game.queueround == nil then
		game.queueround = false
	end
	game.win_tics = 0
	game.team_won = 0
	game.zombie_release_time = 0
end; ZE2.GameReset()

function ZE2.VoteReset()
	local vote = ZE2.Vote
	vote.time_left = -1
	vote.warp_time = -1
	vote.maps = {
		{num = -1, health = 9999, onscreen = true, fuse = 0},
		{num = -1, health = 9999, onscreen = true, fuse = 0},
		{num = -1, health = 9999, onscreen = true, fuse = 0},
	}
	vote.active = true
	vote.nextmapvoted = nil
end; ZE2.VoteReset()