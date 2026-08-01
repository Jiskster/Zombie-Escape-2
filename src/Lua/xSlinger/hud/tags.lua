xSlinger.HUD_TAGS = function(v, player)
	if not player["xSlinger[]"] then
		return
	end
	
	local pmo = player.mo
	if not (pmo and pmo.valid) then
		return end;

	local found = {}

	local range = 768*FU
	searchBlockmap("objects", function(mobj, foundmobj)
		local dist = R_PointToDist2(mobj.x, mobj.y, foundmobj.x, foundmobj.y)

		if dist > range then
			return
		end

		found[#found + 1] = foundmobj
	end, pmo,
	pmo.x-range, pmo.x+range,
	pmo.y-range, pmo.y+range)

	if #found then
		for i=1,#found do
			local mobj = found[i]
			local result = K_GetScreenCoords(v,player,camera, mobj)

			if result and result.onscreen then
				if mobj.health and mobj.info.npc_spawnhealth then
					v.drawString(result.x, result.y+(4*FU), "\x83+\x80"..mobj.health, nil, "thin-fixed-center")
				end
			end
		end
	end
end

addHook("HUD", xSlinger.HUD_TAGS)