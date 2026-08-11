addHook("PreThinkFrame", function(player)
	for player in players.iterate do
		xSlinger.initPlayer(player)
	end
end)

addHook("MobjSpawn", function(mobj)
	if mobj and mobj.valid then
		mobj.xSlinger = xSlinger.init()
	end
end, MT_PLAYER)

function xSlinger.initPlayer(player)
	if not player.xSlinger then
		player.xSlinger = xSlinger.init()	
		player["xSlinger[]"] = true
	end
	
	player.xSlinger.player = player
	
	if player.mo and player.mo.valid then
		player.xSlinger.mo = player.mo
	end
end