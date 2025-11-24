local function ZombieConfigToSkin(ConfigName)
	local zc = ZE2.ZombieConfig
	if not zc[ConfigName] then return end
	return zc[ConfigName].skin.name
end

return "DebugTools", function(v,p)
	if not (ZE2.cv_debug.value and p and p.mo and p.mo.valid) then return end
	local spacing=10

	local bx, by, bflags = 320, 15, V_SNAPTORIGHT|V_SNAPTOTOP|V_ADD|V_ALLOWLOWERCASE|V_PERPLAYER
	-- Draw the tool information
	v.drawString(bx, by, "\130Debug Enabled", bflags, "thin-right")

	-- Teleport buttons
	local bx = 6
	local by = 105
	local bflags = V_PERPLAYER|V_SNAPTOLEFT|V_SNAPTOBOTTOM

	if (IsPlayerAdmin(p) or p == server)
	and not #ZE2.Checkpoints then
		v.drawString(bx,by,"No checkpoints available",bflags|V_REDMAP,"thin")
	end

	-- Checkpoint info
	local cx = 185
	local cy = 70
	local cflags = V_SNAPTOBOTTOM|V_SNAPTORIGHT|V_PERPLAYER|V_ALLOWLOWERCASE
	local index = p.checkpointfound
	local cp = index and ZE2.Checkpoints[index]
	local distance = 200*p.mo.scale
	
	if (ZE2.debug.checkpoints_show and ZE2.Checkpoints)
	and cp and cp.mobj and R_PointToDist2(p.mo.x, p.mo.y, cp.mobj.x, cp.mobj.y) < distance then
		local th = cp.thing
		local number = th.args[0]
		local f = th.args[1]
		local flag_strings = {
			[1]="\132Survivors",
			[2]="\139Zombies",
			[3]="\132Survivors\128/\139Zombies"
		}
		local catchup = th.args[2]
		local extraflags = th.args[3]
		local tag = cp.tag

		v.drawString(cx, cy, "\130Checkpoint Information", cflags, "thin")
		v.drawString(cx, cy+spacing*2, "Number: "..number, cflags, "thin")
		v.drawString(cx, cy+spacing*3, "Flags: "..(flag_strings[f] or tostring(f)), cflags, "thin")
		v.drawString(cx, cy+spacing*4, "Catch up Seconds: "..catchup, cflags, "thin")
		v.drawString(cx, cy+spacing*5, "Tag: "..tag, cflags, "thin")
		v.drawString(cx, cy+spacing*7, "Extra Flags", cflags, "thin")

		if extraflags == 0 then
			v.drawString(cx, cy+spacing*8, "None", cflags|V_REDMAP, "thin")
		else
			local y0 = cy+spacing*8
			local n = 0
			if (extraflags & 1) ~= 0 then v.drawString(cx, y0+n*spacing, "Indiscriminate Checkpoints", cflags|V_GREENMAP, "thin"); n=n+1 end
			if (extraflags & 2) ~= 0 then v.drawString(cx, y0+n*spacing, "Disabled Catch Up", cflags|V_GREENMAP, "thin"); n=n+1 end
			if (extraflags & 4) ~= 0 then v.drawString(cx, y0+n*spacing, "Disabled Auto Trigger", cflags|V_GREENMAP, "thin"); n=n+1 end
		end
	end
	
	--current CharacterConfig
	if (IsPlayerAdmin(p) or p == server) 
	and p.ze2skinname then
		local cc = ZE2.CharacterConfig
		local zc = ZE2.ZombieConfig
		local skinname = p.ze2skinname
		local skincfg = cc[skinname]
		local zombiecfg = zc[skinname]
		local info_x = bx+18
		local info_y = by-17
		local info_flags = bflags|V_ALLOWLOWERCASE
		local skinicon = v.getSprite2Patch((zombiecfg and zombiecfg.skin) or skinname, SPR2_XTRA, false, A, 0)
		local color = v.getColormap((zombiecfg and zombiecfg.skin) or skinname, (zombiecfg and zombiecfg.skincolor) or skins[skinname].prefcolor)

		v.drawScaled((info_x-2)*FU, (info_y-1)*FU, FixedMul(FU/2, skins[(zombiecfg and zombiecfg.skin) or skinname].highresscale), skinicon, info_flags, color)
		v.drawString(info_x, info_y, "\131HP: \128"..p.mo.maxhealth, info_flags, "thin")
		v.drawString(info_x, info_y+spacing-3, "\130Speed: \128"..((zombiecfg and zombiecfg.normalspeed/FU.." FU/T") or skincfg.speed or "unknown"), info_flags, "thin")
	end
end