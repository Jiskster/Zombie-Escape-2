--Original script by wired-aunt
--Heavily edited version by Jisk.

--Nearly every division operation is replaced with bit shifting where it is possible

local sorted_mobjs = {}


local string_linebreak = function(view, message, flags)
	--print("string_linebreak( "..message..", "..flags..")")
	local linelist = {}
	local width = 130
	local maxwidth = 170
	local maxlines = 2
	local i = 1
	local line = ""
	while i <= string.len(message) and #linelist < maxlines
		local nextletter = string.sub(message, i, i)
		--print("nextletter: "..nextletter)
		if not (line == "" and nextletter == " ")
			if view.stringWidth(line, flags, "thin") > maxwidth
				if (#linelist == maxlines - 1)
					linelist[#linelist + 1] = line
				else
					linelist[#linelist + 1] = line.."-"
				end
				line = ""
				--print("NEW LINE")
				continue
			elseif view.stringWidth(line, flags, thin) > width and nextletter == " "
				linelist[#linelist + 1] = line
				line = ""
				--print("NEW LINE")
				continue
			else
				line = $ + string.sub(message, i, i)
				--print("	added")
			end
		else
			--print("	invalid space, skipping")
		end
		i = $ + 1
		if i > string.len(message)
			linelist[#linelist + 1] = line
			line = ""
			--print("FINISH, NEW LINE")
		end
	end
	if (#linelist == maxlines)
		linelist[maxlines] = $ .. "..."
	end
	return linelist
end

CV_RegisterVar({
	name = "z_nametags",
	defaultvalue = 1,
	PossibleValue = CV_OnOff
})

hud.add( function(v, player, camera)
	if not CV_FindVar("z_nametags").value
		return
	end
	if (gametype ~= GT_ZE2) return end
	if ZE2.game_ended then return end
	local width = 320
	local height = 200
	local realwidth = v.width()/v.dupx()
	local realheight = v.height()/v.dupy()

	local first_person = not camera.chase
	local cam = first_person and player.realmo or camera
	local spectator = player.spectator
	local hudwidth = 320*FU
	local hudheight =(300*v.height()/v.width())*FU

	local fov = (CV_FindVar("fov").value/FRACUNIT)*ANG1 --Can this be fetched live instead of assumed?
	
	--the "distance" the HUD plane is projected from the player
	local hud_distance = FixedDiv(hudwidth>>1, tan(fov>>1))

	for _, tmo in pairs(sorted_mobjs) do
		if not tmo or not tmo.valid then continue end
		
		if tmo.player and player == tmo.player then continue end

		if not tmo.player and not mobjinfo[tmo.type].npc_name then continue end

		--how far away is the other mobj?
		local distance = R_PointToDist(tmo.x, tmo.y) 

		local distlimit = 1000
		if distance > distlimit*FRACUNIT then continue end

		--Angle between camera vector and target
		local hangdiff = R_PointToAngle2(cam.x, cam.y, tmo.x, tmo.y)
		local hangle = hangdiff - cam.angle

		--check if object is outside of our field of view
		--converting to fixed just to normalise things
		--e.g. this will convert 365° to 5° for us
		local fhanlge = AngleFixed(hangle)
		local fhfov = AngleFixed(fov>>1)
		local f360 = AngleFixed(ANGLE_MAX)
		if fhanlge < f360 - fhfov and fhanlge > fhfov then
			continue
		end
		
		--flipcam adjustment
		local flip = 1
		if displayplayer.mo and displayplayer.mo.valid
			flip = P_MobjFlip(displayplayer.mo)
		end

		--figure out vertical angle
		local h = FixedHypot(cam.x-tmo.x, cam.y-tmo.y)
		local tmoz = tmo.z
		if (flip == -1)
			tmoz = tmo.z + tmo.height
		end
		if spectator
			tmoz = $ - 48*tmo.scale
		end
		local vangdiff = R_PointToAngle2(0, 0, tmoz-cam.z-48*FRACUNIT*flip, h) - ANGLE_90
		local vcangle = first_person and player.aiming or cam.aiming or 0
		
		local vangle = (vcangle + vangdiff) * flip

		--again just check if we're outside the FOV
		local fvangle = AngleFixed(vangle)
		local fvfov = FixedMul(AngleFixed(fov), FRACUNIT*v.height()/v.width())
		if fvangle < f360 - fvfov and fvangle > fvfov then
			continue
		end
		if (tmo.flags2 & MF2_DONTDRAW) then
			continue
		end
		local hpos = hudwidth>>1 - FixedMul(hud_distance, tan(hangle) * realwidth/width)
		local vpos = hudheight>>1 + FixedMul(hud_distance, tan(vangle) * realheight/height)

		hpos = $ - 25*FU
		local name
		if tmo.player then
			name = tmo.player.name
		end
		
		if not tmo.player and mobjinfo[tmo.type].npc_name then
			name = mobjinfo[tmo.type].npc_name
		end

		local textcolor = SKINCOLOR_GREEN
		local namecolor = SKINCOLOR_FOREST

		if mobjinfo[tmo.type].npc_name_color then
			namecolor = mobjinfo[tmo.type].npc_name_color
		end

		if tmo.alias then
			name = tostring(tmo.alias)
		end

		local health = ("["+tostring(tmo.health)+"/"+tostring(tmo.maxhealth)+"]")

		local namefont = "fixed-center"
		local ringfont = "fixed-center"
		local charwidth = 5
		local lineheight = 8
		--if distance > 500*FRACUNIT then
			--namefont = "small-thin-fixed-center"
			--ringfont = "small-thin-fixed-center"
			--charwidth = 4
			--lineheight = 4
		--end
		

		local flash = (leveltime/(TICRATE/6))%2 == 0
		if flash and tmo.health == 0 then
			textcolor = SKINCOLOR_RED
		end
	
		--local nameflags = skincolors[tmo.skincolor].chatcolor
		local distedit = max(0, distance - ((distlimit*FU)>>1)) * 2
		local trans = min(9, (((distedit * 10) >> 16) / distlimit)) * V_10TRANS
		
		if name then
			customhud.CustomFontString(v,hpos,vpos,name, "TNYFC", trans, namefont , FRACUNIT, namecolor)
			if not tmo.dontshowhealth then
				customhud.CustomFontString(v,hpos,vpos+(lineheight*FU),health, "TNYFC",trans, ringfont , FRACUNIT, textcolor)
			end
			
			if tmo.player and tmo.player.valid then
				if ZE2:FetchInventorySlot(tmo.player) then
					local icon = v.cachePatch(ZE2:FetchInventorySlot(tmo.player).icon)
					local iconscale = ZE2:FetchInventorySlot(tmo.player).iconscale or FRACUNIT
					
					v.drawScaled(hpos, vpos + 16*FU, iconscale/2, icon, trans) -- draw weaponicon
				end
			end
		end
		--v.drawString(hpos, vpos, name, nameflags|trans|V_ALLOWLOWERCASE, namefont)
		--v.drawString(hpos, vpos+(lineheight*FRACUNIT), health, rflags|trans|V_ALLOWLOWERCASE, ringfont)

		if tmo.player and not tmo.player.lastmessagetimer then continue end

		if tmo.player and tmo.player.valid then
			local chat_lifespan = 2*TICRATE
			chat_lifespan = $1 + #tmo.player.lastmessage * TICRATE / 18 or 0

			if tmo.player and tmo.player.lastmessage 
			and leveltime < tmo.player.lastmessagetimer+chat_lifespan then
				local flags = V_GRAYMAP
				local thelines = string_linebreak(v, tmo.player.lastmessage, flags)
				for i = 1, #thelines
					v.drawString(hpos, vpos+(lineheight*(i+1)*FRACUNIT), thelines[i], flags|trans|V_ALLOWLOWERCASE, namefont)
				end
			end
		end
	end
end, "game")

addHook("PlayerMsg", function(player, typenum, target, message)
	if typenum ~= 0 then
		return false --only for normal global messages
	end
	if ignorelist != nil and #ignorelist
		for i = 1, #ignorelist
			if ignorelist[i] == player
				return false
			end
		end
	end

	player.lastmessage = message
	player.lastmessagetimer = leveltime
	return false
end)

local consoleplayer_camera = nil
hud.add(function(v, player, camera)
	consoleplayer_camera = camera
end, "game")

addHook("PostThinkFrame", function()
	sorted_mobjs = {}
	local range = 1024*FRACUNIT
	local dplay
	if (displayplayer and displayplayer.valid and 
	displayplayer.mo and displayplayer.mo.valid) then
		dplay = displayplayer
	end
	
	local function drawThink()
		searchBlockmap("objects", function(refmobj,foundmobj)
			if dplay and foundmobj.health then
				
				if foundmobj.player then
					--print(foundmobj.player.name)
				end
				
				local cam = dplay.realmo
				if consoleplayer_camera and consoleplayer_camera.chase
					cam = consoleplayer_camera
				end
				local thok = P_SpawnMobj(cam.x, cam.y, cam.z, MT_NULL)
				local sight = P_CheckSight(thok, foundmobj)
				P_RemoveMobj(thok)
				if not sight -- if not sight
					return
				end
				
				table.insert(sorted_mobjs, foundmobj)
			end
		end,dplay.mo,dplay.mo.x-range,dplay.mo.x+range,dplay.mo.y-range,dplay.mo.y+range)
		
		table.sort(sorted_mobjs, function(a, b)
			return R_PointToDist(a.mo.x, a.mo.y) > R_PointToDist(b.mo.x, b.mo.y)
		end)
	end
	
	pcall(drawThink)
end)

addHook("MapLoad", function()
	for player in players.iterate() do
		player.lastmessage = nil
		player.lastmessagetimer = nil
	end
end)