-- If its an isolated system, DONT PUT IT HERE.

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
	ZE2.PreviousMaps = net($);
	ZE2.MaxKarma = net($);
	ZE2.NextMapVoted = net($);
	ZE2.vote = net($);
end