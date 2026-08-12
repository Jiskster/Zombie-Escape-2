xSlinger.HUD_TAGS = function(v, player)
	if not player["xSlinger[]"] then return end

	local pmo = player.mo
	if not pmo or not pmo.valid then return end

	local found = {}
	local range = 768 * FU
	searchBlockmap("objects", function(mobj, foundmobj)
		local dist = R_PointToDist2(mobj.x, mobj.y, foundmobj.x, foundmobj.y)
		if (dist > range) then return end

		found[#found + 1] = foundmobj
	end, pmo,
	pmo.x - range, pmo.x + range,
	pmo.y - range, pmo.y + range)

	if (#found <= 0) then return end

	for i = 1 ,#found , 1 do
		local mobj = found[i]
		local result = xS_GetScreenCoords(v,player,camera, mobj)
		if not result or not result.onscreen then continue end

		local visible = false
		if mobj.npc_visiblehealth and mobj.health then
			visible = true
		elseif mobj.info.npc_spawnhealth and mobj.health then
			visible = true
		end

		if not visible then continue end
		v.drawString(result.x, result.y + (4 * FU), "\x83" .. "+" .. "\x80" .. mobj.health, nil, "thin-fixed-center")

		if mobj.npc_displayname then
			v.drawString(result.x, result.y - (4 * FU), mobj.npc_displayname, nil, "thin-fixed-center")
		end
	end
end

addHook("HUD", xSlinger.HUD_TAGS)