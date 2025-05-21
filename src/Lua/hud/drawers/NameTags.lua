local sorted_mobjs = {}

CV_RegisterVar({
	name = "z_nametags",
	defaultvalue = 1,
	PossibleValue = CV_OnOff
})

local consoleplayer_camera = nil
hud.add(function(v, player, camera)
	consoleplayer_camera = camera
end, "game")

addHook("PostThinkFrame", function()
	sorted_mobjs = {}
	local range = 1024*FRACUNIT
	local dplay
	if (displayplayer and displayplayer.valid and 
	displayplayer.realmo) then
		dplay = displayplayer
	end
	
	local function drawThink()
		searchBlockmap("objects", function(refmobj,foundmobj)
			if dplay and foundmobj.health then
				
				if foundmobj.player and foundmobj.player.spectator then
					return
					--print(foundmobj.player.name)
				end
				
				local cam = dplay.realmo
				if consoleplayer_camera and consoleplayer_camera.chase
					cam = consoleplayer_camera
				end
				local thok = P_SpawnMobj(cam.x, cam.y, cam.z, MT_RAY)
				local sight = P_CheckSight(thok, foundmobj)
				P_RemoveMobj(thok)
				if not sight -- if not sight
					return
				end
				
				table.insert(sorted_mobjs, foundmobj)
			end
		end,dplay.realmo,dplay.realmo.x-range,dplay.realmo.x+range,dplay.realmo.y-range,dplay.realmo.y+range)
		
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

return "NameTags", function(v, player)
	if not CV_FindVar("z_nametags").value
		return
	end
	if (gametype ~= GT_ZE2) return end
	if ZE2.game_ended then return end

	local first_person = not camera.chase
	local cam = first_person and player.realmo or camera
	local spectator = player.spectator

	for _, tmo in pairs(sorted_mobjs) do
		if not tmo or not tmo.valid then continue end
		
		if tmo.player and player == tmo.player then continue end

		if not tmo.player and not mobjinfo[tmo.type].npc_name then continue end
		
		local distance = R_PointToDist(tmo.x, tmo.y) 

		local distlimit = 1000
		if distance > distlimit*FRACUNIT then continue end
		
		local result = SG_ObjectTracking(v, player, camera, {
			x = tmo.x,
			y = tmo.y,
			z = tmo.z,
		}, false, true)

		--how far away is the other mobj?
		
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
		local shield = ("["+tostring(tmo.shield_health)+"]")
		
		local namefont = "center"
		local ringfont = "center"
		local y_offset = 0

		local flash = (leveltime/(TICRATE/6))%2 == 0
		if flash and tmo.health == 0 then
			textcolor = SKINCOLOR_RED
		end
	
		local distedit = max(0, distance - ((distlimit*FU)>>1)) * 2
		local trans = min(9, (((distedit * 10) >> 16) / distlimit)) * V_10TRANS
		
		if name and result and result.onScreen then
			customhud.CustomFontString(v, result.x, result.y, name, "TNYFC", trans, namefont, FRACUNIT, namecolor)
			y_offset = $ + 8*FU
			
			if not tmo.dontshowhealth then
				if tmo.shield_health and tmo.shield_def then
					local shield_color = SKINCOLOR_WHITE
					
					if tmo.shield_def.color then
						shield_color = tmo.shield_def.color
					end
				
					customhud.CustomFontString(v,result.x, result.y+y_offset, shield, "TNYFC", trans, ringfont, FRACUNIT, shield_color)
					y_offset = $ + 8*FU
				end
				
				customhud.CustomFontString(v, result.x, result.y+y_offset, health, "TNYFC", trans, ringfont, FRACUNIT, textcolor)
				y_offset = $ + 8*FU
			end
			
			if tmo.player and tmo.player.valid then
				if ZE2:FetchInventorySlot(tmo.player) then
					local icon = v.cachePatch(ZE2:FetchInventorySlot(tmo.player).icon)
					local iconscale = ZE2:FetchInventorySlot(tmo.player).iconscale or FRACUNIT
					
					v.drawScaled(result.x-(4*FU), result.y+y_offset, iconscale/2, icon, trans) -- draw weaponicon
				end
			end
		end
	end
end