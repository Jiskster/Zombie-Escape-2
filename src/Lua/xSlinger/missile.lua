-- A P_SPMAngle clone to fit the needs of xSlinger
function xSlinger.SpawnMissile(m_table)
	local source = m_table.source
	local mobj_type = m_table.type
	local angle = m_table.angle
	local allow_aim = m_table.allow_aim
	local flags2 = m_table.flags2
	local iteminfo = m_table.iteminfo
	local firesound
	local slope = 0
	local x = source.x
	local y = source.y
	local z -- Initialize later to calculate for MFE_VERTICALFLIP
	local th -- Object that is shot.
	local speed
	
	local missile_velocity_precision
	
	if allow_aim then
		slope = sin(source.player.aiming)
	end
	
	if source.eflags & MFE_VERTICALFLIP then
		z = source.z + 2*source.height/3 - FixedMul(mobjinfo[mobj_type].height, source.scale)
	else
		z = source.z + source.height/3
	end
	
	th = P_SpawnMobj(x, y, z, mobj_type)
	if not (th and th.valid) then
		return
	end
	
	table.insert(xSlinger.BulletList, th)
	
	speed = th.info.speed
	
	if iteminfo then
		local skin = source.skin
		local temp_iteminfo = xSlinger.deepcopy(iteminfo)
		
		local missile_fuse = temp_iteminfo:getIndex("fuse", skin)
		local missile_color = temp_iteminfo:getIndex("color", skin)
		local missile_velocity_multiplier = temp_iteminfo:getIndex("velocity_multiplier", skin)
		missile_velocity_precision = temp_iteminfo:getIndex("velocity_precision", skin)

		-- destroy functions
		for i,v in pairs(temp_iteminfo) do
			if type(v) == "function" then
				temp_iteminfo[i] = nil
			end
		end
		
		th.iteminfo = temp_iteminfo
		
		th.velprec = missile_velocity_precision

		if missile_fuse then
			th.fuse = missile_fuse
		end
		
		if missile_color ~= nil then
			th.color = missile_color
		end
		
		if missile_velocity_multiplier then
			speed = FixedMul($, missile_velocity_multiplier)
		end
		
		local sounds = temp_iteminfo:getIndex("sounds", skin)
		
		if sounds.use ~= nil then
			firesound = sounds.use
		end
	end
	
	th.team = source.team

	if source.eflags & MFE_VERTICALFLIP then
		th.flags2 = $ | MF2_OBJECTFLIP
	end

	P_SetScale(th, source.scale)

	if flags2 then
		th.flags2 = $ | flags2
	end

	if not firesound then
		if (th.info.seesound and not (th.flags2 & MF2_RAILRING)) then
			S_StartSound(source, th.info.seesound)
		end
	end

	th.target = source
	
	th.angle = angle
	
	if missile_velocity_precision then
		speed = FixedDiv($, max(missile_velocity_precision-1, 1)*FU)
	end
	
	th.momx = FixedMul(speed, cos(angle))
	th.momy = FixedMul(speed, sin(angle))
	
	if allow_aim then
		if source.player then
			th.momx = FixedMul(th.momx, cos(source.player.aiming))
			th.momy = FixedMul(th.momy, cos(source.player.aiming))
		elseif source.aiming then
			th.momx = FixedMul(th.momx, cos(source.aiming))
			th.momy = FixedMul(th.momy, cos(source.aiming))
		end
	end

	th.momz = FixedMul(speed, slope)
	
	th.momx = FixedMul(th.momx, th.scale)
	th.momy = FixedMul(th.momy, th.scale)
	th.momz = FixedMul(th.momz, th.scale)
	
	slope = xSlinger.CheckMissileSpawn(th)
	
	if slope then
		return th
	else
		return
	end
end

function xSlinger.CheckMissileSpawn(th)
	if not (th.flags & MF_GRENADEBOUNCE) then -- From the Original: "hack: bad! should be a flag.""
		P_SetOrigin(th, th.x + th.momx/2, th.y, th.z)
		P_SetOrigin(th, th.x, th.y + th.momy/2, th.z)
		P_SetOrigin(th, th.x, th.y, th.z + th.momz/2)
	end

	if not P_TryMove(th, th.x, th.y, true) then
		if (th and th.valid) then
			P_ExplodeMissile(th)
		end
		return false
	end
	return true
end

addHook("ThinkFrame", function()
	/*
		This can be done 2 ways, use a numeric for loop and validate every entry there;
		```
		for k = 1, #feed
			local mo = feed[k]
			if not (mo and info.valid)
				table.remove(feed, k)
			end
		end
		```
		
		Or, insert everything we need to remove while iterating, and clean up after the
		generic for loop.
	*/
	local removedelayed = {}
	
	for i,mobj in ipairs(xSlinger.BulletList) do
		if not (mobj and mobj.valid) then
			table.insert(removedelayed, {key = i})
			continue
		end
		
		if mobj.iteminfo and mobj.iteminfo.missile_tick and mobj.target then
			mobj.iteminfo:missile_tick(mobj.target, mobj)
		end
		
		-- No reason to "raycast" this missile.
		if not (mobj.velprec) then continue; end
		
		for ii=1,mobj.velprec-1 do
			if not (mobj and mobj.valid) then
				table.insert(removedelayed, {key = i})
				break
			end
			
			--XY Movement should never remove a mobj...
			P_XYMovement(mobj)
			--...except for when it does...
			if not (mobj and mobj.valid)
				table.insert(removedelayed, {key = i})
				break
			end
			
			if not P_ZMovement(mobj) then
				table.insert(removedelayed, {key = i})
				break
			end
			
			if not P_TryMove(mobj, mobj.x, mobj.y, true) then
				if (mobj and mobj.valid) then
					P_ExplodeMissile(mobj)
				end
				table.insert(removedelayed, {key = i})
			else
				if mobj.iteminfo and mobj.iteminfo.missile_subtick and mobj.target then
					mobj.iteminfo:missile_subtick(mobj.target, mobj, ii)
				end
			end
		end
		if not (mobj and mobj.valid) then
			table.insert(removedelayed, {key = i})
			continue
		end
	end
	
	for k, todo in ipairs(removedelayed)
		table.remove(xSlinger.BulletList, todo.key)
	end
end)

-- dont let teammates and teamate's weapons collide with your weapon 
addHook("MobjCollide", function(thing, tmthing)
	if tmthing and tmthing.valid and thing and thing.valid then
		if (tmthing.target and tmthing.flags & MF_MISSILE and thing.team == tmthing.team) then
			return false
		end
	end
end, MT_PLAYER)

addHook("NetVars", function(net)
	xSlinger.BulletList = net($)
end)