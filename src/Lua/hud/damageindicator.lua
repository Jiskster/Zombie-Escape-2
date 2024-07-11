ZE2.damageindicatorhud = function(v, player, camera)
	if gametype ~= GT_ZE2 then return end
	if not player.mo then return end
	
	for imo,tbl in pairs(player["ze2_info"].damage_indicator_table)
		local result = SG_ObjectTracking(v, player, camera, {
			x = tbl.draw_x,
			y = tbl.draw_y,
			z = tbl.draw_z,
		}, false, true)
		
		if result.onScreen then
			v.drawString(result.x, result.y, tbl.number, 0, "fixed")
		end
	end
end