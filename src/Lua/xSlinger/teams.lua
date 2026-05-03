-- Synced, because it can change midgame
xSlinger.teams = {}

-- Dont sync
xSlinger.default_teams = {
	{
		name = "Red";
		color = SKINCOLOR_RED;
	},
	{
		name = "Blue";
		color = SKINCOLOR_BLUE;
	};
}

addHook("NetVars", function(net)
	xSlinger.teams = net($)
end)

addHook("MapLoad", function()
	xSlinger.teams = {}

	local gtinfo = xSlinger.registeredGametypes[gametype]
	if gtinfo and gtinfo.teams then
		xSlinger.teams = xSlinger.deepcopy(gtinfo.teams)
	end
end)