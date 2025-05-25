if fromspectators then
	player.ze2.was_spectating = true -- Disable special zombie types when unspectating

	if ZE2.round_active and not ZE2_game_ended then
		player.ze2.pregamemenu_active = false
	end
end

-- NEVER have pregamemenu_active on as spectator
if team == 0 then
	player.ze2.pregamemenu_active = false
end