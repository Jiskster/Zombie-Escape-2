ZE2.PlayZombieSound = function(player, being_infected)
	local infection_sounds
	
	if not being_infected then
		infection_sounds = {sfx_inf1, sfx_inf2}
	else
		infection_sounds = {sfx_inf3, sfx_inf4}
	end
	
	if player.mo and player.mo.valid then
		local soundrng = P_RandomRange(1,#infection_sounds)
		S_StartSound(player.mo,infection_sounds[soundrng])
	end
end