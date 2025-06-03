local tx = CV_RegisterVar({
	name = "tx",
	defaultvalue = "0",
	PossibleValue = CV_Unsigned,
})
local ty = CV_RegisterVar({
	name = "ty",
	defaultvalue = "0",
	PossibleValue = CV_Unsigned,
})

return "Intermission", function(v, player)
	if not ZE2.game_ended then return end
	local wtics = ZE2.win_tics
	local team_won = ZE2.team_won

	local team_patch = v.cachePatch("Z_SURVIVORS")
	
	if team_won == 2 then
		team_patch = v.cachePatch("Z_ZOMBIES")
	end
	
	local win_patch = v.cachePatch("Z_WIN")
	
	local end_goals = { -- fixed x values
		team = 20*FU; -- come from the left
		win = 220*FU; -- come from the right
	}
	
	local anim_time = TICRATE + TICRATE/2
	local diff = anim_time - max(0, anim_time - wtics)
	local div = FixedDiv(diff*FU, anim_time*FU)
	
	local team_x = ease.outquint(div, end_goals.team - 200*FU, end_goals.team)
	local win_x = ease.outquint(div, end_goals.win + 200*FU, end_goals.win)
	
	v.drawScaled(team_x, 100*FU, FU, team_patch)
	v.drawScaled(win_x, 100*FU, FU, win_patch)
end