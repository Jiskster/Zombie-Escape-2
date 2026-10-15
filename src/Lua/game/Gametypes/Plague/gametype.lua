local gt = ZE2.AddGametype("Plague", -- Name
	-- Description
	"A supervirus outbreak has occurred! Keep distance from your teammates, or you may be next... "
)

gt.default_rounds = 1
gt.default_pregame_time = 30*TICRATE
gt.respawn_time[2] = 5*TICRATE
gt.default_winner = 1
gt.zombie_after_death = true
gt.default_zombie_release_time = 0
gt.move_during_pregame = true
gt.force_loadout[1] = {"red_ring"}