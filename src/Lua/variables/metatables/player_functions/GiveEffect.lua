return function(self, effect_name, effect_table, effect_time)
	local player = self.player

	if player.ze2.effects and effect_name and effect_table and effect_time then
		local tbl = effect_table
		tbl.time_left = effect_time or 1-- tics
		
		player.ze2.effects[effect_name] = tbl
	end
end
