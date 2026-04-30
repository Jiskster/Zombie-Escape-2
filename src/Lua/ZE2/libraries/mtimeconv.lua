rawset(_G, "G_TicsToMTIME", function(tics, hascents)
	if (tics == nil) then return "???" end

	if not hascents then
		return string.format("%02d:%02d", G_TicsToMinutes(tics), G_TicsToSeconds(tics))
	end
	return string.format("%02d:%02d.%02d", G_TicsToMinutes(tics), G_TicsToSeconds(tics), G_TicsToCentiseconds(tics))
end)