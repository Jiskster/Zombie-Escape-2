rawset(_G, "G_TicsToMTIME", function(tics, hascents)
	if tics == nil then return "???" end
	local minutes = tostring(G_TicsToMinutes(tics))
	local seconds = tostring(G_TicsToSeconds(tics))
	local cents = tostring(G_TicsToCentiseconds(tics))		

    if minutes:len() < 2 then
        minutes = $
    end

    if seconds:len() < 2 then
		seconds = "0"..$
    end
	
	if cents:len() < 2 then
        cents = $
    end
	
	if not hascents then
		return minutes..":"..seconds
	else
		return minutes..":"..seconds.."."..cents
	end
end)