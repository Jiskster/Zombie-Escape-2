local function itemSoundPlay(mobj, item_sound, player)
	if type(item_sound) == "number" then
		S_StartSound(mobj, item_sound, player)
	elseif type(item_sound) == "table" then
		local rng_range = P_RandomRange(1, #item_sound)
		
		S_StartSound(mobj, item_sound[rng_range], player)
	else
		error("Sound must be a table or string")
	end
end

local function itemReload(xS, mobj, soundtable, reload_time)
	if soundtable and soundtable[1] then
		S_StartSound(mobj, soundtable[1])
	end
	
	xS.reload = reload_time
end

-- Players aren't the only ones that use this, remember that!
function xSlinger.DoThinker(mobj)
	local player = mobj.player
	local validplayer = player and player.valid
	
	local xS = validplayer and player.xSlinger or mobj.xSlinger
	
	if not xS then
		return false, "Missing .xSlinger"
	end
	
	local cmd = validplayer and player.cmd or mobj.cmd
	local skin = mobj.skin
	
	local firing = false
	local wepnext = false
	local wepprev = false
	local wepnum = 0
	local reloadpressed = false
	
	local buttons
	local lastbuttons
	
	local hand = xS:hand()
	local inv = xS:inv_get()
	
	if not inv then
		return false, "Missing inventory"
	end
	
	local item_sound
	local reload_sound
	if hand.sounds then -- Set sounds
		if hand.sounds.use then
			item_sound = hand.sounds.use
		end
		
		if hand.sounds.reload then
			reload_sound = hand.sounds.reload
		end
	end
	
	local reload_time = hand:getIndex("reload_time", skin) or 1
	local firerate = hand:getIndex("firerate", skin)
	local firerate_left = hand:getIndex("firerate_left", skin)
	local ammo = hand:getIndex("ammo", skin)
	local maxammo = hand:getIndex("maxammo", skin)
	local count = hand:getIndex("count", skin)
	local maxcount = hand:getIndex("maxcount", skin)
	local itemdelay = hand:getIndex("delay", skin)
	
	if validplayer then
		buttons = cmd.buttons
		lastbuttons = player.lastbuttons
		firing = (buttons & BT_ATTACK) and not (lastbuttons & BT_ATTACK)
		wepnext = (buttons & BT_WEAPONNEXT) and not (lastbuttons & BT_WEAPONNEXT)
		wepprev = (buttons & BT_WEAPONPREV) and not (lastbuttons & BT_WEAPONPREV)
		wepnum = (buttons & BT_WEAPONMASK)
		reloadpressed = (buttons & BT_FIRENORMAL) and not (lastbuttons & BT_FIRENORMAL)
		
		if hand.autouse then
			firing = (buttons & BT_ATTACK)
		end
		
		player.weapondelay = 1
	end
	
	if xS.delay then
		xS.delay = max(0, $ - 1)
	end
	
	-- To make sure slot is in valid spot:
	xS.slot = (($-1) % inv.size) + 1
	
	if firing and not xS.delay and not xS.reload 
	and not itemdelay and not firerate_left and hand.id ~= "" then
		local missile
		
		local queue_reload = false
		
		if ammo == 0 then
			queue_reload = true
			firing = false
		end
		
		-- Check firing again, might've been updated by item ammo checks!
		-- Also check if it isn't empty
		if firing then
			if hand.usefunc and hand:usefunc(mobj) then
				firing = false
			end
			
			if firing then
				-- Decrement Ammo
				if ammo > 0 then
					ammo = hand:setIndex("ammo", max(0, ammo - 1), skin)
					
					if not ammo then
						queue_reload = true
					end
				elseif count > 0 then
					count = hand:setIndex("count", max(0, count - 1), skin)
					
					if not count then
						xS:hand_clear()
					end
				elseif maxammo > 0 then -- if not infinite ammo then queue reload
					queue_reload = true
				end
				
				-- If you don't need to reload, then cue the item stuffs.
				if (not (queue_reload and ammo and maxammo > 0)) or (maxcount > 0) then
					-- Fire Missile (If it's defined in iteminfo.missile)
					if hand.missile then
						local missile_info = {
							source = mobj;
							type = hand.missile;
							angle = mobj.angle;
							allow_aim = true;
							iteminfo = hand;
							flags2 = hand.flags2;
						}
						
						missile = xSlinger.SpawnMissile(missile_info)
					end
					
					if hand.missile_spawn and missile and missile.valid then
						hand:missile_spawn(mobj, missile)
					end
					
					-- Play Item Sound
					if item_sound then
						itemSoundPlay(mobj, item_sound)
					end
				end
			end
		end
		
		-- Reload start / Item Cooldown
		if queue_reload then
			itemReload(xS, mobj, reload_sound, reload_time)
		elseif firing then
			if itemdelay ~= nil then
				xS.delay = itemdelay
			end
			
			if firerate ~= nil then
				hand:setIndex("firerate_left", firerate, skin)
			end
		end
	end
	
	if xS.reload then
		xS.reload = max(0, $ - 1) -- Decrement value while reloading
		
		-- Reload Done.
		if not xS.reload then
			if reload_sound and reload_sound[2] then
				S_StartSound(mobj, reload_sound[2])
			end
			
			-- Reset ammo
			if maxammo and maxammo > 0 then
				ammo = hand:setIndex("ammo", maxammo, skin)
			end
		end
	else 
		-- Pressing Reload Button (1-7 or BT_WEAPONNEXT/BT_WEAPONPREV)
		if reloadpressed and (maxammo and ammo ~= maxammo) then
			itemReload(xS, mobj, reload_sound, reload_time)
		end
	end
	
	do -- Weapon Switching System
		local delta = 0
		
		if wepnext then
			delta = 1
		elseif wepprev then
			delta = -1
		end
		
		if wepnum and wepnum <= inv.size then
			delta = wepnum - xS.slot
		end
		
		-- If it's changing
		if delta ~= 0 then
			xS.slot = ((($-1) + delta) % inv.size) + 1 
			
			-- Hey, catch! (Goes to zero for some reason)
			if xS.slot == 0 then
				xS.slot = inv.size
			end
			
			xS.reload = 0 -- Cancel Reload
			
			S_StartSound(mobj, sfx_wepchg, player)
		end
	end
	
	for i=1,inv.size do
		local iteminfo = inv[i]
		
		-- Clean up nil slots.
		if iteminfo == nil then
			inv[i] = xSlinger.new("")
			iteminfo = inv[i]
		end
		
		local firerate_left = iteminfo:getIndex("firerate_left", skin)
		
		if firerate_left then
			firerate_left = iteminfo:changeIndex("firerate_left", -1, skin)
		end
	end
	
	return true
end