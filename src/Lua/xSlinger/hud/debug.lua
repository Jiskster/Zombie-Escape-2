local cv_debugeffect = CV_RegisterVar({
	name = "debugeffect",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
})

addHook("HUD", function(v, player)
	if not (player.mo and player.mo.valid) then
		return end;
	
	if not (cv_debugeffect.value) then
		return end;
	
	local mo = player.mo
	local x = 200
	local y = 10 
	for i,effect in pairs(mo.effects) do
		v.drawString(x, y, "\x82" .. i .. " : ", V_SNAPTORIGHT, "small-thin-right")
		
		for index, value in pairs(effect) do
			y = $ + 4
			v.drawString(x, y, index .. " : " .. tostring(value), V_SNAPTORIGHT, "small-thin-right")
		end
		
		y = $ + 16
	end
end)