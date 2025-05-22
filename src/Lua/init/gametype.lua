/* Was meant for the ringslinger-esk system. Might use this name for separating 
what ZE2 has.

rawset(_G, "XSLINGER", {});
*/

rawset(_G, "ze2_modname", "ze2"); -- For customhud.

freeslot("TOL_ZE2");

ZE2.wait_time = 15*TICRATE;
ZE2.MapVoteStartFrame = 10*TICRATE
ZE2.VoteTimeLimit = 12*TICRATE
ZE2.queuing_round = false
ZE2.rounds_left = 3

ZE2.HUD = {}

ZE2.Effects = {
	["alphazombie.rage"] = {
		thinker = function(player)
			if player.mo and player.mo.valid then
				P_SpawnGhostMobj(player.mo)
			end
		end,
		on_end = function(player)
			if player.mo and player.mo.valid then
				S_StartSound(player.mo, sfx_bstdn)
			end
		end
	}
}

ZE2.teams = {"Survivors", "Zombies"}

G_AddGametype({
	name = "ZE2 Survival",
	identifier = "ze2",
	typeoflevel = TOL_ZE2,
	rules = GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_NOSPECTATORSPAWN|GTR_DEATHMATCHSTARTS,
	intermissiontype = int_none, -- No intermission screen for possible inbuilt screen.
	--headerleftcolor = 152,
	--headerrightcolor = 40,
	description = "Escape from the Zombies! Don't get caught and eaten by them! They can catch up with you anytime..."
})
