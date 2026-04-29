local lastgt = GT_COOP

return "ToggleHud", function(v, player)
	if gametype == GT_ZE2 and lastgt ~= GT_ZE2 and netgame then
		hud.disable("rankings")
		hud.disable("score")
		hud.disable("time")
		hud.disable("lives")
		hud.disable("teamscores")
		hud.disable("rings")
		hud.disable("stagetitle")
		hud.disable("textspectator")
	elseif gametype ~= GT_ZE2 and lastgt == GT_ZE2 then
		hud.enable("rankings")
		hud.enable("score")
		hud.enable("time")
		hud.enable("lives")
		hud.enable("teamscores")
		hud.enable("rings")
		hud.enable("stagetitle")
		hud.enable("textspectator")
	end
	lastgt = gametype
end