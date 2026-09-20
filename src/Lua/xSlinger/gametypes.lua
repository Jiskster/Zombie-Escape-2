xSlinger.registeredGametypes = {}

function xSlinger.registerGametype(gt, data)
	if (type(gt) ~= "number") then
		error("Arg 2 must be a table. Got: "..type(gt))
		return
	end

	if (type(data) ~= "table") then
		error("Arg 2 must be a table. Got: "..type(data))
		return
	end

	local registered = xSlinger.registeredGametypes
	registered[gt] = data
end

function xSlinger.getGametypeSettings(gtype)
	local registered = xSlinger.registeredGametypes
	return registered[gtype or gametype]
end

xSlinger.registerGametype(GT_COOP, {})

xSlinger.registerGametype(GT_RACE, {})

xSlinger.registerGametype(GT_MATCH, {
	friendlyfire = true;
})

xSlinger.registerGametype(GT_TEAMMATCH, {
	mirror_vanilla_teams = true;
	teams = xSlinger.default_teams;
})

xSlinger.registerGametype(GT_TAG, {})

xSlinger.registerGametype(GT_HIDEANDSEEK, {})

xSlinger.registerGametype(GT_CTF, {
	mirror_vanilla_teams = true;
	teams = xSlinger.default_teams;
})