COM_AddCommand("z_forcewin", function(player, arg1)
	local teamtowin = 1
 	if not arg1 or not tonumber(arg1) then return end
 	arg1 = tonumber(arg1)

	if (arg1 > 0 and arg1 < 3) then
		ZE2:StartWin(arg1)
	end
end, COM_ADMIN)

COM_AddCommand("z_changeztype", function(player, new_ztype)
	if not (player.mo and player.mo.valid) then return end
	if player.mo.team ~= 2 then
		CONS_Printf(player,"You must be a zombie to run this command.")
		return
	end

	if not new_ztype then
		CONS_Printf(player,"z_changeztype <ztype>: changes your zombie type.")
		return
	end

	local zc = ZE2.ZombieConfig

	if zc[new_ztype] then
		player.ze2.zombie_type = new_ztype
		ZE2.ResetPlayer(player, 2, true)
	else
		CONS_Printf(player,"Invalid ztype. "..'"'..new_ztype..'"')
	end
end, COM_ADMIN)

COM_AddCommand("z_listkarma", function(player)
	for p in players.iterate do
		CONS_Printf(player, p.name.." ["..#p.."]: "..p.ze2.karma)
	end
end, COM_LOCAL)

COM_AddCommand("drophand", function(player)
	local game = ZE2.Game
	local xS = player.xSlinger

	if not (player.mo and player.mo.valid) then
		return end;

	if (game.state == ZE2.GS_PREGAME) then
		return end;

	local mo = player.mo

	local droppeditem, i_obj = xS:hand_drop()
	if i_obj and i_obj.valid then
		i_obj.team = mo.team
		i_obj.interaction.team_restrict = {enabled = true}
		i_obj.interaction.team_restrict[mo.team] = true
	end
end)