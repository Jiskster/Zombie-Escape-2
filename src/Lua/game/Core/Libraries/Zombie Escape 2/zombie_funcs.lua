function ZE2.ZombifyPlayer(player, ztype)
	local xS = player.xSlinger
	local zc = ZE2.ZombieConfig

	if not ztype then
		player.ze2.zombie_type = "normal"
	elseif zc[ztype] then
		player.ze2.zombie_type = ztype
	else
		print("Attempted to switch to invalid ztype: "..ztype)
		player.ze2.zombie_type = "normal"
	end

	player.mo.infectionfx = TICRATE * 3 / 2 -- infection_fx.lua
	ZE2.ResetPlayer(player, 2, true)
end

function ZE2.PlayZombieSound(player, being_infected)
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