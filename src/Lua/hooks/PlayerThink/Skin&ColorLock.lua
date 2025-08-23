return function(player)
	if not player.mo return end

	local ztype = player.ze2.zombie_type
	local zc = ZE2.ZombieConfig

	if player.ze2.team == 2 then
		local zskin = "zzombie"
		if (ztype and zc[ztype]) then
			zskin = zc[ztype].skin
		end
		local notzombie = skins[player.skin].name ~= zskin
		if notzombie then
			R_SetPlayerSkin(player, zskin)
		end
	elseif player.ze2.team == 1 then
		local badskin = skins[player.skin].name == "zzombie"
		for name,_ in pairs(zc) do
			if skins[player.skin].name == name then
				badskin = true
				break
			end
		end
		if badskin then
			R_SetPlayerSkin(player, "sonic")
			player.mo.color = player.skincolor
		end
	end
		
	if (player.ze2.team == 2 and ztype and zc[ztype]) then 
		player.mo.color = zc[ztype].skincolor or SKINCOLOR_MOSS
	end
end
