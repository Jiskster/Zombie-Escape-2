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

local wtics2 = 0 -- for triangle animation

return "Intermission", function(v, player)
	if not ZE2.game_ended then
		wtics2 = 0
		return
	end
	
	local wtics = ZE2.win_tics
	local team_won = ZE2.team_won

	local team_patch = v.cachePatch("Z_SURVIVORS")
	local win_patch = v.cachePatch("Z_WIN")
	local lower_patch = v.cachePatch("Z_BANG_LOWER_BLUE")
	local upper_patch = v.cachePatch("Z_BANG_UPPER_BLUE")
	local bg_patch = v.cachePatch("Z_BG_BLUE")
	
	if team_won == 2 then
		team_patch = v.cachePatch("Z_ZOMBIES")
		lower_patch = v.cachePatch("Z_BANG_LOWER_RED")
		upper_patch = v.cachePatch("Z_BANG_UPPER_RED")
		bg_patch = v.cachePatch("Z_BG_RED")
	end
	
	local end_goals = { -- fixed x values
		team = 20*FU; -- come from the left
		win = 220*FU; -- come from the right
	}
	
	local anim_time = TICRATE + TICRATE/2
	local diff = anim_time - max(0, anim_time - wtics)
	local div = FixedDiv(diff*FU, anim_time*FU)
	
	local team_x = ease.outquint(div, end_goals.team - 200*FU, end_goals.team)
	local win_x = ease.outquint(div, end_goals.win + 200*FU, end_goals.win)
	
	-- Animations for when the triangles appear
	local anim_time2 = 2*TICRATE
	local div2 = FixedDiv(min(wtics2*FU,anim_time2*FU), anim_time2*FU)
	local triangle_y = ease.inoutsine(div2, upper_patch.height*FU, 0)
	local bg_ease = ease.inoutsine(div2, 9, 5)
	
	-- Colored Background
	if wtics >= 100 then
		wtics2 = $ + 1
		v.drawScaled(-500*FU,-500*FU, FU*1000, bg_patch, bg_ease<<V_ALPHASHIFT)
	end
	
	-- Triangle Thingies
	for i=-2,2 do
		local x_movement = ((leveltime*FU)%(lower_patch.width*FU))
		local bottom_x = i*(lower_patch.width*FU) + x_movement
		local bottom_y = ((200*FU)-lower_patch.height*FU) + triangle_y
		local top_x = i*(upper_patch.width*FU) - x_movement
		local top_y = 0 - triangle_y -- could do -triangle_y but this is visually better
		
		v.drawScaled(top_x, top_y, FU, upper_patch, V_SNAPTOTOP)
		v.drawScaled(bottom_x, bottom_y, FU, lower_patch, V_SNAPTOBOTTOM)
	end

	-- "Survivors Win" | "Zombies Win"
	v.drawScaled(team_x, 100*FU, FU, team_patch)
	v.drawScaled(win_x, 100*FU, FU, win_patch)
end