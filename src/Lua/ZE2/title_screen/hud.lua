local title_tics = 0

addHook("HUD", function(v)
	title_tics = $+1

	local ze2logo1 = v.cachePatch("ZE2_TTL00")
	local title_xoffset = 25*FU
	local title_yoffset = 15*FU
	local title_timetoappear = 1*TICRATE

	local drawtics_frame1 = 2
	local drawtics_frame2 = 4
	local drawtics_frame3 = 6
	local drawtics_frame4 = 8

	if title_tics >= title_timetoappear and title_tics <= (title_timetoappear+drawtics_frame1) then
		local ze2logo1 = v.cachePatch("ZE2_TTL00")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo1)
	elseif title_tics >= (title_timetoappear+drawtics_frame1) and title_tics <= (title_timetoappear+drawtics_frame2) then
		local ze2logo2 = v.cachePatch("ZE2_TTL01")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo2)
	elseif title_tics >= (title_timetoappear+drawtics_frame2) and title_tics <= (title_timetoappear+drawtics_frame3) then
		local ze2logo3 = v.cachePatch("ZE2_TTL02")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo3)
	elseif title_tics >= (title_timetoappear+drawtics_frame3) and title_tics <= (title_timetoappear+drawtics_frame4) then
		local ze2logo4 = v.cachePatch("ZE2_TTL03")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo4)
	elseif title_tics >= (title_timetoappear+drawtics_frame4) then
		local ze2logo5 = v.cachePatch("ZE2_TTL04")
		v.drawScaled(title_xoffset, title_yoffset, FU/4, ze2logo5)
	end
end, "title")

addHook("HUD", function(v)
	title_tics = 0 --reset timer when not on title screen
end, "game")