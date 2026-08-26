local function skinHudAlive()
	customhud.disable("rankings")
	customhud.disable("score")
	customhud.disable("time")
	customhud.disable("lives")
	customhud.disable("teamscores")
	customhud.disable("rings")
	customhud.disable("stagetitle")
	customhud.disable("textspectator")
	customhud.disable("tabemblems")
end

skinHudAlive()

return "ToggleHud", (skinHudAlive)


