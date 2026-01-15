hud.disable("rings")

addHook("HUD", function(v, player)
	if not xSlinger.visible_huds.health then
		return end;

	local hp_patch = v.cachePatch("XSG_HEALTH")
	local hp_x = hudinfo[HUD_RINGS].x
	local hp_y = hudinfo[HUD_RINGS].y
	local hp_flags = (hudinfo[HUD_RINGS].f)|V_HUDTRANS
	local hpnum_x = hp_x + 92
	
	v.draw(hp_x, hp_y, hp_patch, hp_flags)
	
	if player.mo and player.mo.valid then
		v.drawNum(hpnum_x, hp_y, player.mo.health + player.mo.shield_health, hp_flags)
	else
		v.drawNum(hpnum_x, hp_y, 0, hp_flags)
	end
end)
