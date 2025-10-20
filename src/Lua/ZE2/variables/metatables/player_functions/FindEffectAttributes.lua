return function(self, attribute)
	local player = self.player
	
	local tb = {}

	if player.ze2.effects then
		for i,v in pairs(player.ze2.effects) do
			if v[attribute] then
				table.insert(tb, v[attribute])
			end
		end
	end
	
	return tb
end
