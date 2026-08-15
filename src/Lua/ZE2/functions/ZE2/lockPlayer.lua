function ZE2.lockPlayer(player)
    if not player.mo then return end
	if player.spectator then return end

	local mo = player.mo
	local ztype = player.ze2.zombie_type
	local zc = ZE2.ZombieConfig

	if mo.team == 2 then
		local zskin = "zsonic"
		if (ztype and zc[ztype]) then
			zskin = zc[ztype].skin
		end
		local notzombie = skins[player.skin].name ~= zskin
		if notzombie then
			R_SetPlayerSkin(player, zskin)
		end
	elseif mo.team == 1 then
		local currentskin = skins[player.skin].name
		local badskin = (currentskin == "zsonic")
		local selectedskin = player.ze2.selected_character
		for name,_ in pairs(zc) do
			if currentskin == name then -- if current skin is a blacklisted skin
				badskin = true -- es illegal
				break
			end
		end

		if selectedskin and selectedskin ~= currentskin then
			badskin = true -- bad skin if selected skin is not being worn
		end

		if badskin then
			local newskin = "sonic"

			if selectedskin then
				newskin = selectedskin
			end

			R_SetPlayerSkin(player, newskin)
			player.mo.color = player.skincolor
		end
	end

	if (mo.team == 2 and ztype and zc[ztype]) then
		player.mo.color = zc[ztype].skincolor or SKINCOLOR_ZOMBIE
	end
end