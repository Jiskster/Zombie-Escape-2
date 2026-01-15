ZE2.switchCharacter = function(player, skinname, animation)
	local pmo = player.mo
	
	if R_SkinUsable(player, skinname) then
		R_SetPlayerSkin(player, skinname)
	else
		R_SetPlayerSkin(player, "sonic")	
	end
	
	ZE2.ResetPlayer(player)
	--S_StartSound(nil, sfx_strpst, player)
	
	if animation then
		P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
	end

	pmo.flags2 = $ & ~MF2_DONTDRAW
	player.pflags = $ & ~PF_INVIS
end