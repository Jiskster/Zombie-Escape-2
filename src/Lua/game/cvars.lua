local function addCvar(name, regtable)
	name = string.format("cv_%s", name)
	if ZE2[name] ~= nil then
		error("ZE2 variable already exists; cannot add Cvar")
		return false
	end

	ZE2[name] = CV_RegisterVar(regtable)
end

addCvar("instantinfection", {
	name = "z_instantinfection",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addCvar("server_showteamchat", {
	name = "server_showteamchat",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addCvar("choosenotice", {
	name = "z_choosenotice",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addCvar("landingfatigue", {
	name = "z_landingfatigue",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addCvar("sourcemovement", {
	name = "z_sourcemovement",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

addCvar("currencydelay", {
	name = "z_currencydelay",
	defaultvalue = "1",
	PossibleValue = {MIN = 0, MAX = 12},
	flags = CV_NETVAR,
})

addCvar("debug", {
	name = "z_debug",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})
