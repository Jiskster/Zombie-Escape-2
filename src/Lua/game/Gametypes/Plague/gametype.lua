local gt = ZE2.AddGametype("Plague", -- Name
	-- Description
	"A supervirus outbreak has occurred! Keep distance from your teammates, or you may be next... "
)

gt.shop = false
gt.default_pregame_time = 30*TICRATE
gt.default_round_time = 4*60*TICRATE
gt.respawn_time[2] = 5*TICRATE
gt.default_winner = 1
gt.zombie_after_death = true
gt.zombie_chosen_always_alpha = true
gt.zombie_health_multi = FU/2
gt.default_zombie_release_time = 0
gt.survivor_drop_inventory = true
gt.move_during_pregame = true
gt.fall_damage = true
gt.allow_pregame_drop = true
gt.force_loadout[1] = {}