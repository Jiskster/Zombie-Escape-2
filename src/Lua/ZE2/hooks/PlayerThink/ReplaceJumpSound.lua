return function(player)
	local pmo = player.mo

	if pmo and pmo.valid then
		local sound = skins[pmo.skin].soundsid[SKSJUMP] or sfx_jump
		if S_SoundPlaying(pmo, sound) then
			S_StopSoundByID(pmo, sound)
			S_StartSound(pmo, sfx_zjump)
		end
	end
end