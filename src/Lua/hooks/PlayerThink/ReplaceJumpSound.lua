local pmo = player.mo

if pmo and pmo.valid then
	if S_SoundPlaying(pmo, sfx_jump) then
		S_StopSoundByID(pmo, sfx_jump)
		S_StartSound(pmo, sfx_zjump)
	end
end