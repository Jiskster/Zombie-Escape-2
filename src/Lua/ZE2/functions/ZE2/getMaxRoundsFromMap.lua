function ZE2.getMaxRoundsFromMap(map)
	local output = ZE2.DEFAULT_ROUNDS

	if mapheaderinfo[map or gamemap].ze2_rounds then
		output = tonumber(mapheaderinfo[map or gamemap].ze2_rounds)
	end

	return output
end