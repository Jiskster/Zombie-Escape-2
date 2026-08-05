-- super specialized cvars wont show here.

ZE2.instantinfection = CV_RegisterVar({
	name = "z_instantinfection",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.server_showteamchat = CV_RegisterVar({
	name = "server_showteamchat",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.repeatshopitems = CV_RegisterVar({
	name = "z_repeatshopitems",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.choosenotice = CV_RegisterVar({
	name = "z_choosenotice",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.killenemiesonwin = CV_RegisterVar({
	name = "z_killenemiessonwin",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.landingfatigue = CV_RegisterVar({
	name = "z_landingfatigue",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.sourcemovement = CV_RegisterVar({
	name = "z_sourcemovement",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

ZE2.cv_debug = CV_RegisterVar({
	name = "z_debug",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

COM_AddCommand("z_changeztype", function(player, new_ztype)
	if not (player.mo and player.mo.valid) then return end
	if player.xSlinger.team ~= 2 then
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
	local xS = player.xSlinger

	if not (player.mo and player.mo.valid) then
		return end;

	if (ZE2.pregame_timeleft) then
		return end;

	local droppeditem = xS:hand_drop()
	if droppeditem and droppeditem.valid then
		droppeditem.team = xS.team
		droppeditem.interaction.team_restrict = {enabled = true}
		droppeditem.interaction.team_restrict[xS.team] = true
	end
end)