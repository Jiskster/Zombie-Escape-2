local P_XYMovement = P_XYMovement
local P_ZMovement = P_ZMovement
local P_TryMove = P_TryMove
local FixedMul = FixedMul
local FixedDiv = FixedDiv

freeslot("MT_XS_MISSILE")

mobjinfo[MT_XS_MISSILE] = {
	radius = 16*FRACUNIT,
	height = 24*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY,
	health = 1000,
}

function xSlinger.registerMissile(missile_id, r_table)
	xSlinger.registered_missiles[missile_id] = r_table
	r_table.id = missile_id
	
	table.insert(xSlinger.registered_missiles_ordered, r_table)
	
	return r_table
end

-- A P_SPMAngle clone to fit the needs of xSlinger
function xSlinger.SpawnMissile(m_table)
	local source = m_table.source
	local missile_id = m_table.type
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
	
	if not missile_id then
		return
	end
	
	local missile_def = xSlinger.registered_missiles[missile_id]

	if allow_aim then
		slope = sin(source.player.aiming)
	end

	if source.eflags & MFE_VERTICALFLIP then
		z = source.z + 2*source.height/3 - FixedMul(mobjinfo[MT_XS_MISSILE].height, source.scale)
	else
		z = source.z + source.height/3
	end

	th = P_SpawnMobj(x, y, z, MT_XS_MISSILE)
	if not (th and th.valid) then
		return
	end
	
	th.state = missile_def.state
	
	table.insert(xSlinger.BulletList, th)

	speed = missile_def.speed

	if missile_def then
		local temp_missile_def = xSlinger.deepcopy(missile_def)
		
		-- destroy functions
		for i,v in pairs(temp_missile_def) do
			if type(v) == "function" then
				temp_missile_def[i] = nil
			end
		end
		
		if missile_def.radius then
			th.radius = missile_def.radius
		end
		
		if missile_def.height then
			th.height = missile_def.height
		end
		
		if missile_def.addflags then
			th.flags = $ | missile_def.addflags
		end
		
		if missile_def.delflags then
			th.flags = $ & (~missile_def.delflags)
		end
		
		th.missileinfo = temp_missile_def -- give missileinfo
	end

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

	P_SetScale(th, source.scale, true)
	
	th.isMissile = true -- placed after scale change so height/radius changes can be fine

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
			xSlinger.KillMissile(th)
		end
		return false
	end
	return true
end

function xSlinger.KillMissile(mobj)
	local info = mobj.missileinfo
	
	if info and mobj.health then
		mobj.alpha = FRACUNIT
		mobj.fuse = -1
		
		if info.deathsound then
			S_StartSound(mobj, info.deathsound)
		end
		
		if info.deathstate then
			if mobj.state ~= info.deathstate then
				mobj.state = info.deathstate
			end
		else
			mobj.state = S_NULL
		end
		
		if info.nogravitydeath then
			mobj.flags = $ | MF_NOGRAVITY
		end
	end
	
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
	mobj.health = 0
end

local function checkMissile(mobj, missileinfo)
	if (mobj.eflags & MFE_JUSTHITFLOOR or mobj.z + mobj.height >= mobj.ceilingz) then
		if (missileinfo and not missileinfo.safeground) then
			xSlinger.KillMissile(mobj)
		end
		
		return false
	end
	
	return true
end

local function getMissileDef(mobj)
	if mobj.missileinfo then
		local missile_id = mobj.missileinfo.id
		
		if missile_id then
			return xSlinger.registered_missiles[missile_id]
		end
	end
end

addHook("ThinkFrame", function()
	/*
		Insert everything we need to remove while iterating, and clean up after the
		generic for loop.
	*/
	
	local removedelayed = {}

	for i = 1, #xSlinger.BulletList do
		local mobj = xSlinger.BulletList[i]
		
		if not (mobj and mobj.valid and mobj.health) then
			removedelayed[#removedelayed + 1] = {key = i}
			continue
		end
		
		if mobj.iteminfo and mobj.iteminfo.missile_tick and mobj.target then
			mobj.iteminfo:missile_tick(mobj.target, mobj)
			
			if not (mobj and mobj.valid and mobj.health) then
				removedelayed[#removedelayed + 1] = {key = i}
				continue
			end
		end
		
		-- TODO: give mobj.missileinfo a metatable
		local missile_def = getMissileDef(mobj)

		if missile_def and missile_def.tick and mobj.target then
			missile_def.tick(mobj.target, mobj)
			
			if not (mobj and mobj.valid and mobj.health) then
				removedelayed[#removedelayed + 1] = {key = i}
				continue
			end
		end
		
		-- No reason to "raycast" this missile.
		if not (mobj.velprec) then
			checkMissile(mobj, mobj.missileinfo)
			continue
		end

		for ii=1,mobj.velprec-1 do
			if not (mobj and mobj.valid) or not checkMissile(mobj, mobj.missileinfo) then
				removedelayed[#removedelayed + 1] = {key = i}
				break
			end
			
			--XY Movement should never remove a mobj...
			P_XYMovement(mobj)
			--...except for when it does...
			if not (mobj and mobj.valid) 
			or not P_ZMovement(mobj) 
			or not checkMissile(mobj, mobj.missileinfo) then
				removedelayed[#removedelayed + 1] = {key = i}
				break
			end

			if not P_TryMove(mobj, mobj.x, mobj.y, true) then
				if (mobj and mobj.valid) then
					xSlinger.KillMissile(mobj)
				end
				
				removedelayed[#removedelayed + 1] = {key = i}
				break
			else
				if mobj.iteminfo and mobj.iteminfo.missile_subtick and mobj.target then
					mobj.iteminfo:missile_subtick(mobj.target, mobj, ii)
				end
				
				if missile_def and missile_def.subtick and mobj.target then
					missile_def.subtick(mobj.target, mobj)
				end
			end
		end
		
		if not (mobj and mobj.valid) then
			removedelayed[#removedelayed + 1] = {key = i}
			continue
		end
	end

	if #removedelayed then
		for i = #removedelayed, 1, -1 do
			local todo = removedelayed[i]
			table.remove(xSlinger.BulletList, todo.key)
		end
	end
end)

-- dont let teammates and teamate's weapons collide with your weapon
addHook("MobjCollide", function(thing, tmthing)
	if tmthing and tmthing.valid and thing and thing.valid then
		if (tmthing.target and tmthing.isMissile and thing.team == tmthing.team) then
			return false
		end
	end
end, MT_PLAYER)

addHook("MobjMoveCollide", function(mov, mobj)
	if mov.z > mobj.height + mobj.z then return end
	if mobj.z > mov.height + mov.z then return end
	if not mov.isMissile then return end -- To make sure you've already rescaled.

	local alivemissile = (mov.health > 0)

	if (mobj.flags & MF_SHOOTABLE) and alivemissile and (mov.target and mov.target ~= mobj) then
		P_DamageMobj(mobj, mov, mov.target)
		xSlinger.KillMissile(mov)
	end
end, MT_XS_MISSILE)

addHook("MobjMoveBlocked", function(mov, mobj, line)
	if not mov.isMissile then return end
	
	local missile_def = getMissileDef(mov)
	
	local override
	
	if missile_def then
		if missile_def.blocked then
			override = missile_def.blocked(mov.target, mov, line)
		end
	end
	
	if not (mov and mov.valid and mov.health) then -- just in case missile dies in blocked callback
		return 
	end 
	
	if line and (mov.missileinfo and mov.missileinfo.safewall) or (mov.flags & MF_SLIDEME) then
		return
	end
	
	if override ~= nil then
		return override
	end
	
	if (mov and mov.valid) then
		xSlinger.KillMissile(mov)
	end
end, MT_XS_MISSILE)

addHook("MobjFuse", function(mobj)
	if (mobj and mobj.valid and mobj.health) then
		mobj.fuse = -1
		
		xSlinger.KillMissile(mobj)
		return true
	end
end, MT_XS_MISSILE)

addHook("MobjDeath", function(mobj)
	if mobj.health then
		xSlinger.KillMissile(mobj)
		return
	end
end, MT_XS_MISSILE)

addHook("NetVars", function(net)
	xSlinger.BulletList = net($)
end)