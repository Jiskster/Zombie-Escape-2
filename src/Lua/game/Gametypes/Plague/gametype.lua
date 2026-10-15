local gt = ZE2.AddGametype("Plague", -- Name
	-- Description
	"TODO"
)

gt.default_pregame_time = 30*TICRATE
gt.respawn_time[2] = 5*TICRATE
gt.default_winner = 1
gt.zombie_after_death = true
gt.default_zombie_release_time = 0
gt.move_during_pregame = true