addHook("MobjMoveBlocked", function(mobj, thing, line)
	if not ZE2.mapladdertag then return end

    if mobj and mobj.valid and line and line.valid and not thing then
		if line.tag and line.tag == ZE2.mapladdertag then
			P_SetObjectMomZ(mobj, 8*FRACUNIT)

			if mobj.player and mobj.player.valid then
				mobj.state = S_PLAY_SPRING
			end
		end
    end
end, MT_PLAYER)

addHook("NetVars", function(net)
	ZE2.mapladdertag = net($)
end)

addHook("MapLoad", function(map)
	ZE2.mapladdertag = nil
	
	if mapheaderinfo[map].ze2_laddertag then
		local input = tonumber(mapheaderinfo[map].ze2_laddertag)
		ZE2.mapladdertag = input
	end
end)