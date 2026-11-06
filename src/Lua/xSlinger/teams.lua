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

local function ValidateTeam(player)
	if not player.realmo or not player.realmo.valid then return end
	if (player.realmo.team ~= nil) then return end
	player.realmo.team = 1
end

addHook("MobjSpawn", function(mobj)
	if (mobj.type == MT_PLAYER) then return end
	if not (mobj.flags & MF_SHOOTABLE) and not (mobj.flags & MF_ENEMY) and not (mobj.flags & MF_BOSS) then return end
	mobj.team = 0
end)

addHook("PreThinkFrame", function(player)
	for player in players.iterate do
		ValidateTeam(player)
	end
end)