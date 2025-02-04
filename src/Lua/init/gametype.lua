rawset(_G, "ZE2", {});
/* Was meant for the ringslinger-esk system. Might use this name for separating 
what ZE2 has.

rawset(_G, "XSLINGER", {});
*/

freeslot("sfx_zdi1","sfx_zdi2","sfx_zish1","sfx_zpa1","sfx_zpa2", "sfx_bstdn", "sfx_bstup")
freeslot("sfx_rstart", "sfx_secret", "sfx_cleva1")
freeslot("sfx_eatapl", "sfx_oyahx", "sfx_mnu1a")
freeslot("sfx_inf1", "sfx_inf2", "sfx_inf3", "sfx_inf4", "sfx_pipe")

freeslot("sfx_z_rel1", "sfx_z_rel2")
freeslot("sfx_z20s", "sfx_cone", "sfx_ctwo", "sfx_cthr", "sfx_cfou", "sfx_cfiv", "sfx_csix", "sfx_csev", "sfx_ceig", "sfx_cnin", "sfx_cten")

freeslot("sfx_zmrel")

freeslot("sfx_oldrad")

local zombiesfxinfo = {
        singular = false,
        priority = 128,
        flags = SF_X4AWAYSOUND|SF_X8AWAYSOUND|SF_NOMULTIPLESOUND
}

sfxinfo[sfx_inf1] = zombiesfxinfo
sfxinfo[sfx_inf2] = zombiesfxinfo
sfxinfo[sfx_inf3] = zombiesfxinfo
sfxinfo[sfx_inf4] = zombiesfxinfo

rawset(_G, "ze2_modname", "ze2"); -- For customhud.

freeslot("TOL_ZE2");

ZE2.wait_time = 15*TICRATE;
ZE2.MapVoteStartFrame = 10*TICRATE
ZE2.VoteTimeLimit = 12*TICRATE
ZE2.queuing_round = false
ZE2.rounds_left = 3

ZE2.HUD = {}

ZE2.init_gamevars = function(map) -- Variables vary per game.
	ZE2.round_active = false;
	ZE2.game_ended = false;
	ZE2.win_tics = 0; -- How many tics after a win screen. Resets on mapload.
	ZE2.game_time = 0;
	ZE2.time_limit = 0;
	ZE2.team_won = 0;
	
	ZE2.mapladdertag = nil;
	
	ZE2.pregame_timeleft = ZE2.wait_time; 
	ZE2.zombie_releasetime = 0;
	
	ZE2.MapVoteList = {};
	ZE2.MapVotes = {0,0,0};
	ZE2.MapsOnVote = {
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1}
	}; -- votes, mapnumber
	
	ZE2.NextMapVoted = 0;
	
	if map then
		if ZE2.queuing_round then
			ZE2.rounds_left = $ - 1
			ZE2.queuing_round = false
			
			-- force reload everyone's weapon
			for player in players.iterate do
				if player["ze2_info"] then
					-- TODO: Make a function for this process.
					for i,v in pairs(player["ze2_info"].survivor_inventory) do
						v.ammo = v.max_ammo
						
						if v.skin_overwrite then
							for a,b in pairs(v.skin_overwrite) do
								if b.ammo ~= nil then
									if b.max_ammo ~= nil then
										b.ammo = b.max_ammo
									elseif v.max_ammo ~= nil then
										b.ammo = v.max_ammo
									end
								end
							end
						end
					end
				else
					continue
				end
			end
		else
			ZE2.rounds_left = tonumber(mapheaderinfo[map].ze2_rounds) or 3
			
			-- reset everyone's inventory
			for player in players.iterate do
				if player["ze2_info"] then
					-- TODO: Reference the default table and copy that, instead of making a new one
					player["ze2_info"].survivor_inventory = {
						ZE2:CopyItemFromID(ITEM_RED_RING)
					}
				else
					continue
				end
			end
			
			ZE2.queuing_round = false
		end
		
		if mapheaderinfo[map].ze2_timelimit then
			local input = tonumber(mapheaderinfo[map].ze2_timelimit)
			ZE2.time_limit = input*60*TICRATE
		end
		
		if mapheaderinfo[map].ze2_laddertag then
			local input = tonumber(mapheaderinfo[map].ze2_laddertag)
			ZE2.mapladdertag = input
		end
	end
	
	for player in players.iterate do
		player["ze2_info"].team = 1;
		if player["ze2_info"] then
			player["ze2_info"].ghostmode = false
			player["ze2_info"].vote_selection = 1
			player["ze2_info"].voted = false
			player["ze2_info"].checkpoint_number = 0
			player["ze2_info"].blood_currency = 0 -- happiness is temporary 
			player["ze2_info"].zombie_healthbonus = 0
			player["ze2_info"].zombie_healthdeduction = 0
			player["ze2_info"].zombie_speedbonus = 0
		end
	end
end; ZE2.init_gamevars();

-- http://lua-users.org/wiki/CopyTable
function ZE2:Copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ZE2:Copy(orig_key)] = ZE2:Copy(orig_value)
        end
        setmetatable(copy, ZE2:Copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ZE2.getMaxRoundsFromMap(map)
	local output = 3
	
	if mapheaderinfo[map or gamemap].ze2_rounds then
		output = tonumber(mapheaderinfo[map or gamemap].ze2_rounds)
	end
	
	return output
end

function ZE2.getCurrentRound()
	return (ZE2.getMaxRoundsFromMap() - ZE2.rounds_left) + 1
end

function ZE2.ZCollide(mo1,mo2)
	if mo1.z > FixedMul(mo2.height,mo2.scale)+mo2.z then return false end
	if mo2.z > FixedMul(mo1.height,mo2.scale)+mo1.z then return false end
	return true
end

ZE2.teams = {"Survivors", "Zombies"}

G_AddGametype({
	name = "ZE2 Survival",
	identifier = "ze2",
	typeoflevel = TOL_ZE2,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_NOSPECTATORSPAWN,
	intermissiontype = int_none, -- No intermission screen for possible inbuilt screen.
	--headerleftcolor = 152,
	--headerrightcolor = 40,
	description = "Escape from the Zombies! Don't get caught and eaten by them! They can catch up with you anytime..."
})

sfxinfo[sfx_zdi1].caption="Zombie scream"
sfxinfo[sfx_zdi2].caption="Zombie scream"
sfxinfo[sfx_zpa1].caption="Zombie pain"
sfxinfo[sfx_zpa2].caption="Zombie pain"
sfxinfo[sfx_zish1].caption="Swoop"

sfxinfo[sfx_rstart].caption="Zombies escaped..."
sfxinfo[sfx_secret].caption="Secret revealed!"
sfxinfo[sfx_cleva1].caption="\"Calling for transport!\""

sfxinfo[sfx_eatapl].caption="Num num num!"
sfxinfo[sfx_oyahx].caption="OHHH YEAH"
sfxinfo[sfx_mnu1a].caption="Selecting"

sfxinfo[sfx_inf1].caption="\"The zombies will be back\""
sfxinfo[sfx_inf2].caption="\"We've been enslaved\""
sfxinfo[sfx_pipe].caption="Pipe"

sfxinfo[sfx_oldrad].caption="Typewriter"
