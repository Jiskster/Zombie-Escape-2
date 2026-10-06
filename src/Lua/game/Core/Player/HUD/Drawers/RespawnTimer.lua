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
		
		local next_ztype = player.ze2.next_zombie_type
		local ztype = player.ze2.zombie_type
		-- TODO: Show real zombie type name instead.
		if next_ztype and next_ztype ~= ztype then
			local str = ztype .. " -> \x82" .. next_ztype 
			local str2 = "You will be upgraded!"
			
			v.drawString(160,100-16, str, V_50TRANS, "thin-center")
			v.drawString(160,100-24, str2, V_50TRANS, "thin-center")
		end
	end
end