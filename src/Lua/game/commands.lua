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

ZE2.MaxKarmaPLS = 999999
COM_AddCommand("z_zombiepls", function(player, accept)
	if player.ze2.zombiepls then
		CONS_Printf(player, "\x85\ZombiePls has been disabled. Karma reset to "..ZE2.MaxKarma)
		player.ze2.zombiepls = false
		player.ze2.karma = ZE2.MaxKarma
		return
	end	

	if (accept == "PLEASE") then
		player.ze2.zombiepls = true
		player.ze2.karma = ZE2.MaxKarmaPLS
		CONS_Printf(player, "\x84\ZombiePls has been enabled. Karma set to " .. ZE2.MaxKarmaPLS)
		CONS_Printf(player, "\x82\Run the command again to disable.")
	else
		CONS_Printf(player, "This command maxes out your karma beyond its limits, are you sure?")
		CONS_Printf(player, "\x82\If you are sure, then do 'z_zombiepls PLEASE' in console.")
	end
end)

-- Thinker for ZombiePls
addHook("PlayerThink", function(player)
	if player.ze2.zombiepls then
		player.ze2.karma = ZE2.MaxKarmaPLS
	end
end)

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