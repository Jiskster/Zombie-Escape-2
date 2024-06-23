local lastgt = GT_COOP

ZE2.togglehud = function(v, player)
	if gametype == GT_ZE2 and lastgt ~= GT_ZE2 and netgame
		hud.disable("rankings")
		hud.disable("score")
		hud.disable("time")
		hud.disable("lives")
		hud.disable("teamscores")
		hud.disable("rings")
		hud.disable("stagetitle")
	elseif gametype ~= GT_ZE2 and lastgt == GT_ZE2 
		hud.enable("rankings")
		hud.enable("score")
		hud.enable("time")
		hud.enable("lives")
		hud.enable("teamscores")
		hud.enable("rings")
		hud.enable("stagetitle")
	end
	lastgt = gametype
end