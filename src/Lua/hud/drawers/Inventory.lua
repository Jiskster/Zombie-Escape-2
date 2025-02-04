return "Inventory", function(v, player)
	if player["ze2_info"].pregamemenu_active then return end
	if ZE2.game_ended then return end
	if player["ze2_info"].ghostmode then return end
	if player["ze2_info"].zombie_shop_open then return end
	
	if ZE2.pregame_timeleft then return end -- if in pregame, dont display
	if ZE2.zombie_releasetime and player["ze2_info"].team == 2 then return end -- if zombie and hasn't been released, dont display
	
	if player and not player.mo then return end
	
	v.drawString(160, 170, "WIP INVENTORY", V_SNAPTOBOTTOM, "center")
end