addHook("PlayerSpawn", ZE2.init_player)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		ZE2.sprint_thinker(player)
	end
end)

addHook("PlayerThink", ZE2.giveplayerflags)

addHook("MobjThinker", ZE2.LimitMobjHealth)

addHook("MapLoad", function(map)
	if gametype == GT_ZE2 then
		ZE2.init_gamevars(map)
	end
end)
