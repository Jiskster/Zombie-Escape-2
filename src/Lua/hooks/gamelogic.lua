
addHook("PlayerSpawn", SRBZ.init_player)

addHook("TouchSpecial", SRBZ.HitMegaHP, MT_MEGAHP)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		SRBZ.sprint_thinker(player)
	end
end)

addHook("PlayerThink", SRBZ.giveplayerflags)

addHook("MobjThinker", SRBZ.LimitMobjHealth)

addHook("MapLoad", function(map)
	if gametype == GT_SRBZ then
		SRBZ.init_gamevars(map)
	end
end)
