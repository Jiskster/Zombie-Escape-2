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

	local bulletheight = FixedMul(mobjinfo[MT_XS_MISSILE].height, source.scale)
	
	if missile_def and missile_def.height then
		bulletheight = FixedMul(missile_def.height, source.scale)
	end
	
	if source.eflags & MFE_VERTICALFLIP then
		local realheight = source.z - (41 * source.height / 48) + bulletheight -- TODO: Test this correctly
		z = realheight --source.z + 2*source.height/3 - FixedMul(mobjinfo[MT_XS_MISSILE].height, source.scale)
	else
		local h = source.height
		
		if source.player and source.player.valid then
			h = source.height
		end
	
		z = source.z + (41 * h / 48) - bulletheight
	end

	th = P_SpawnMobj(x, y, z, MT_XS_MISSILE)
	if not (th and th.valid) then
		return
	end

	th.state = missile_def.state

	speed = missile_def.speed
	
	if m_table.damage then th.forcedamage = m_table.damage end
	if m_table.forceknockback then th.forceknockback = m_table.forceknockback end
	if m_table.relativeknockback then th.relativeknockback = true end

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
	if (mobj.z <= mobj.floorz or mobj.z + mobj.height >= mobj.ceilingz) then
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

addHook("MobjThinker", function(mobj)
	if not (mobj and mobj.valid and mobj.health) then 
		return 
	end

	if mobj.iteminfo and mobj.iteminfo.missile_tick and mobj.target then
		mobj.iteminfo:missile_tick(mobj.target, mobj)
		if not mobj or not mobj.valid or (mobj.health <= 0) then return end
	end

	-- TODO: give mobj.missileinfo a metatable
	local missile_def = getMissileDef(mobj)
	if missile_def and missile_def.tick and mobj.target then
		missile_def.tick(mobj.target, mobj)
		if not mobj or not mobj.valid or (mobj.health <= 0) then return end
	end

	-- No reason to "raycast" this missile.
	if not mobj.velprec then
		checkMissile(mobj, mobj.missileinfo)
		return
	end

	for step = 1, mobj.velprec - 1, 1 do
		if not (mobj and mobj.valid) or not checkMissile(mobj, mobj.missileinfo) then break end

		--XY Movement should never remove a mobj...... except for when it does...
		P_XYMovement(mobj)
		if not mobj or not mobj.valid or not P_ZMovement(mobj) or not checkMissile(mobj, mobj.missileinfo) then
			break
		end

		if not P_TryMove(mobj, mobj.x, mobj.y, true) then
			if (mobj and mobj.valid) then
				xSlinger.KillMissile(mobj)
			end
			break
		else
			if mobj.iteminfo and mobj.iteminfo.missile_subtick and mobj.target then
				mobj.iteminfo:missile_subtick(mobj.target, mobj, step)
			end

			if missile_def and missile_def.subtick and mobj.target then
				missile_def.subtick(mobj.target, mobj)
			end
		end
	end
	if not mobj or not mobj.valid or (mobj.health <= 0) then return end
end, MT_XS_MISSILE)

-- dont let teammates and teamate's weapons collide with your weapon
addHook("MobjCollide", function(thing, tmthing)
	if tmthing and tmthing.valid and thing and thing.valid then
		if (tmthing.target and tmthing.isMissile and thing.team == tmthing.team) then
			return false
		end
	end
end, MT_PLAYER)

addHook("MobjMoveCollide", function(mov, mobj)
	if not mov or not mov.valid then return end
	if not mobj or not mobj.valid then return end
	if mov.z > mobj.height + mobj.z then return end
	if mobj.z > mov.height + mov.z then return end
	if not mov.isMissile then return end -- To make sure you've already rescaled.

	local alivemissile = (mov.health > 0)
	if ((mobj.flags & MF_SHOOTABLE) or (mobj.flags & MF_ENEMY)) and alivemissile and (mov.target and mov.target ~= mobj) then
		P_DamageMobj(mobj, mov, mov.target)
		xSlinger.KillMissile(mov)
	end
end, MT_XS_MISSILE)

addHook("MobjLineCollide", function(mov, line)
	if line then
		if (line.flags & ML_IMPASSIBLE) and (line.flags & ML_TWOSIDED) then
			return false
		end
	end
end, MT_XS_MISSILE)

addHook("MobjMoveBlocked", function(mov, mobj, line)
	if not mov or not mov.valid then return end
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

	if line then
		if (mov.missileinfo and mov.missileinfo.safewall) or (mov.flags & MF_SLIDEME) then
			return
		end
	end

	if override ~= nil then
		return override
	end

	if (mov and mov.valid) then
		xSlinger.KillMissile(mov)
	end
end, MT_XS_MISSILE)

addHook("MobjFuse", function(mobj)
	if not mobj or not mobj.valid then return end
	
	if (mobj.health <= 0) then
		P_RemoveMobj(mobj)
		return
	end

	xSlinger.KillMissile(mobj)
end, MT_XS_MISSILE)

addHook("MobjDeath", function(mobj)
	if (mobj.health <= 0) then return end

	xSlinger.KillMissile(mobj)
end, MT_XS_MISSILE)