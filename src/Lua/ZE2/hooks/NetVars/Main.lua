return function(net)
	ZE2.time_limit = net($);
	ZE2.wait_time = net($);
	ZE2.round_active = net($); -- stays on even if the end screen is on
	ZE2.game_ended = net($);
	ZE2.win_tics = net($); -- Increases if ZE2.game_ended is true
	ZE2.game_time = net($);
	ZE2.team_won = net($);
	ZE2.pregame_timeleft = net($);
	ZE2.zombie_releasetime = net($);
	ZE2.queuing_round = net($);
	ZE2.rounds_left = net($);
	ZE2.tools = net($) --ZE2 Tools

	ZE2.VoteTimeLimit = net($);
	ZE2.MapsOnVote = net($);
	ZE2.NextMapVoted = net($);

	ZE2.Checkpoints = net($);
	ZE2.LatestSurvivorCheckpoint = net($);
	ZE2.LatestZombieCheckpoint = net($);

	ZE2.Survivor_ShopList = net($);

	ZE2.CachedShieldMobjs = net($);

	ZE2.TWRITE_COUNT = net($);
	ZE2.TWRITE_MAPNAME_COUNT = net($);

	ZE2.mapladdertag = net($);

	ZE2.QueueSpectate = net($);

	ZE2.PreviousMaps = net($);

	ZE2.MaxKarma = net($);

	ZE2.CharacterSlots = net($)
end