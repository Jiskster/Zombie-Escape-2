addHook("PreThinkFrame", function()
	for player in players.iterate do
		ZE2.applyPlayerConfig(player)
	end
end)