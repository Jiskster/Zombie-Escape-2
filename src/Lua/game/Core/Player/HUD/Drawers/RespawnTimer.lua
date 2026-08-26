-- Also a timer for survivors to turn into spectators after they die.

return "RespawnTimer", function(v, player)
	local game = ZE2.Game
	
	if game.ended then
		return
	end

	if player.playerstate == PST_DEAD and not player.spectator then
		local respawntics = player.ze2.respawntics
		local respawntics2 = G_TicsToSeconds(respawntics) .. "." .. G_TicsToCentiseconds(respawntics)
		local text = "Respawning in:"

		if player.ze2.outofgame then
			text = "Spectator in:"
		end

		v.drawString(160,100, text, V_50TRANS, "thin-center")
		v.drawString(160,100+8, respawntics2.." seconds", V_50TRANS, "thin-center")
	end
end