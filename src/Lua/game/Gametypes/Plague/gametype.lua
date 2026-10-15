local gt = ZE2.AddGametype("Plague", -- Name
	-- Description
	"TODO"
)

gt.respawn_time[2] = 5*TICRATE
gt.zombie_after_death = true
gt.default_zombie_release_time = 0