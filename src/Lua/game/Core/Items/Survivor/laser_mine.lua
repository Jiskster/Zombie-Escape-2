/*
	TODO:
	- lasermine needs unique sprites for both horizontal and veritcal
	  orientations
	- finish xslinger weapon definitions
	- CLEAN UP CODE!!!
	  this also includes keeping in style with ze2's code
*/

local LMODE_VERTICAL = 1
local LMODE_HORIZONTAL = 2
local L_SETUPTIME = 2 * TICRATE

---@param frac fixed_t
---@param from fixed_t
---@param to fixed_t
local function P_Lerp(frac, from, to)
	return from + FixedMul(to - from, frac)
end

---@param x1 fixed_t
---@param y1 fixed_t
---@param z1 fixed_t
---@param x2 fixed_t
---@param y2 fixed_t
---@param z2 fixed_t
---@return fixed_t
local function R_PointTo3DDist(x1, y1, z1, x2, y2, z2)
	return FixedHypot(FixedHypot(x2 - x1, y2 - y1), z2 - z1)
end

---@param a fixed_t
---@param b fixed_t
---@return fixed_t
local function P_RandomFixedRange(a,b)
	return a + FixedMul((b - a), P_RandomFixed())
end

---@param minimum number
---@param value number
---@param maximum number
local function clamp(minimum, value, maximum)
	return max(minimum, min(maximum, value))
end

local function P_ClosestPointOnLine3D(p, length_start, length_end)
	local dot, distance
	local vector_length = Vec3.Sub(length_end, length_start)
	local vector_length2 = Vec3.Sub(p, length_start)
	distance = R_PointTo3DDist(length_start.x, length_start.y, length_start.z, length_end.x, length_end.y, length_end.z)

	local vector3 = Vec3.Div(Vec3.New(vector_length.x, vector_length.y, vector_length.z), distance)
	dot = Vec3.Dot(vector3, vector_length2)

	if (dot <= 0) then
		return length_start
	elseif (dot >= distance) then
		return length_end
	end

	vector3 = vector3 * dot
	return Vec3.Add(length_start, vector3)
end
local function MobjIntersectsRay(start, destination, radius, height, mobj)
	local intersect = P_ClosestPointOnLine3D(Vec3.MobjPosToVec(mobj), start, destination)
	intersect = Vec3.New(intersect.x, intersect.y, intersect.z - height / 2)
	if (abs(intersect.x - mobj.x) <= (mobj.radius + radius))
	and (abs(intersect.y - mobj.y) <= (mobj.radius + radius))
	and (
		(mobj.z <= (intersect.z + height)) -- check overhead
		and ((mobj.z + mobj.height) >= intersect.z) -- check underhead
	) then
		return true, intersect
	end
	return false, nil
end

freeslot("sfx_zlmp", "sfx_zlmf", "sfx_zlmh0", "sfx_zlmh1", "sfx_zlmh2", "sfx_zlmh3")
sfxinfo[sfx_zlmp].caption = "Laser mine primes"
sfxinfo[sfx_zlmf] = {flags = SF_X2AWAYSOUND, caption = "Laser mine fires"}
sfxinfo[sfx_zlmh0].caption = "Electrocution"
sfxinfo[sfx_zlmh1].caption = "Electrocution"
sfxinfo[sfx_zlmh2].caption = "Electrocution"
sfxinfo[sfx_zlmh3].caption = "Electrocution"

freeslot("S_ZE2_LASERMINE", "MT_ZE2_LASERMINE")
states[S_ZE2_LASERMINE] = {
	sprite = SPR_TURR,
	frame = I|FF_SEMIBRIGHT,
	tics = -1,
	nextstate = S_ZE2_LASERMINE
}
mobjinfo[MT_ZE2_LASERMINE] = {
	spawnhealth = 25,
	spawnstate = S_ZE2_LASERMINE,
	painsound = sfx_dmpain,
	painchance = 192*FRACUNIT,
	deathstate = S_RINGEXPLODE,
	deathsound = sfx_pop,
	radius = 24*FU,
	height = 40*FU,
	flags = MF_SHOOTABLE|MF_SPECIAL,
}
mobjinfo[MT_ZE2_LASERMINE].npc_name = "Laser Mine"

freeslot("SPR_ZE2_LMINEHIT", "S_ZE2_LMINEHIT")
states[S_ZE2_LMINEHIT] = {
	sprite = SPR_ZE2_LMINEHIT,
	frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	var1 = (6 - 1),
	var2 = 2,
	tics = 6 * 2
}
addHook("TouchSpecial", function(mobj) return true end, MT_ZE2_LASERMINE)

freeslot("MT_LMINE_CHECK")

addHook("MobjMoveBlocked", function(check, _, line)
	check.blockingline = line
end, MT_LMINE_CHECK)

addHook("MobjMoveCollide", function(check, mobj)
	if not check or not check.valid then return end
	if (mobj.type == MT_ZE2CHECKPOINT) then return true end
	if (mobj.flags & MF_SPRING) and ZE2.ZCollide(check, mobj) then return true end
	if not (mobj.flags & MF_SOLID) then return false end
	if not ZE2.ZCollide(check, mobj) then return false end
	if mobj.player and mobj.player.valid then
		if (mobj.team == check.target.team) then return false end
	end
	return true
end, MT_LMINE_CHECK)

---@param source mobj_t
---@param x fixed_t
---@param y fixed_t
---@param z fixed_t
local function Raycast_SetDest(source, x, y, z)
	source.zmine.endpoint = {x = x, y = y, z = z}
end

local function BlockedCollision(self, source, target, line, mobj)
	if not (target and target.valid) then return end
	if not (source and source.valid and source.type == MT_ZE2_LASERMINE) then return end
	if not (source.zmine) then return end

	Raycast_SetDest(source, target.x,target.y,target.z)
	P_KillMobj(target)
end

local function Tick(self, source, target)
	if not target or not target.valid then return end
	if not (source and source.valid and source.type == MT_ZE2_LASERMINE) then
		P_KillMobj(target)
		return
	end

	local x, y, z = target.x, target.y, target.x
	local newx, newy, newz = x, y, z
	while (target and target.valid and target.health > 0) do
		P_XYMovement(target)

		if not target.valid then break end
		P_ZMovement(target)

		if not target.valid then break end
		newx = target.x
		newy = target.y
		newz = target.z

		if (target.z <= target.floorz) or ((target.z + target.height) >= target.ceilingz) or (target.eflags & MFE_JUSTSTEPPEDDOWN) then
			break
		end

		if (x == target.x) and (y == target.y) and (z == target.z) then
			break
		end
	end

	Raycast_SetDest(source, newx, newy, newz)
	if (target and target.valid) then
		P_KillMobj(target)
	end
end

local function Raycast_SendRay(mine)
	mine.zmine.startpoint = {x = mine.x, y = mine.y, z = mine.z}
	mine.zmine.endpoint = nil

	local sector = mine.subsector.sector
	local slope = sector.f_slope
	local slope_aim = 0
	if false then --(bomb.ceilingmode) then
		slope = sector.c_slope
	end
	if slope then
		slope_aim = FixedMul(slope.zangle, cos(mine.angle))
		if false then --bomb.ceilingmode
			slope_aim = -slope_aim
		end
	end

	local aim_angle = 0
	if (mine.lasermode == LMODE_VERTICAL) then
		aim_angle = ANGLE_90
	--elseif (mine.lasermode == LMODE_HORIZONTAL) then
	end

	local marker = xSlinger.SpawnMissile({
		source = mine,
		type = "LMINE_CAST",
		angle = mine.angle,
		aiming = aim_angle,
		allow_aim = true,
		flags2 = MF2_DONTDRAW,
	})

	if marker and marker.valid then
		marker.flags = marker.flags | (MF_NOCLIPTHING|MF_NOTHINK)
		marker.isMissile = true

		local missileinfo
		if marker.missileinfo then
			local missile_id = marker.missileinfo.id
			if missile_id then
				missileinfo = xSlinger.registered_missiles[missile_id]
			end
		end

		while (marker and marker.valid and marker.health > 0) do
			Tick(missileinfo, mine, marker)
		end
		if (marker and marker.valid) then P_RemoveMobj(marker) end
	end

	-- convert to vectors
	local start = mine.zmine.startpoint
	local destination = mine.zmine.endpoint
	-- Uh oh!!!!!!
	if not destination then
		P_KillMobj(mine)
		return false
	end

	mine.zmine.startVector = Vec3.New(start.x, start.y, start.z + (41*mine.height/48))
	mine.zmine.endVector = Vec3.New(destination.x, destination.y, destination.z)
	mine.zmine.rayangle = mine.angle
	mine.zmine.rayaiming = aim_angle
	return true
end

local raycast_missile = xSlinger.registerMissile("LMINE_CAST", {
	speed = 16*FRACUNIT,
	displayname = "Rail Ring",
	state = S_INVISIBLE,
	deathstate = S_NULL,
	deathsound = sfx_none,
	radius = 1*FRACUNIT,
	height = 1*FRACUNIT,
	addflags = MF_NOCLIPTHING|MF_NOGRAVITY,
	blocked = BlockedCollision,
	tick = Tick
})
----

local cv_friendlyfire = CV_FindVar("friendlyfire")
local ease_inquint = ease.inquint
local function TelegraphFirstFire(mine)
	local zmine = mine.zmine
	local start = zmine.startVector
	local destination = zmine.endVector
	local time_fraction = ease_inquint(FU - FixedDiv(zmine.setup*FU, L_SETUPTIME*FU), 0, FU)
	local distance = R_PointTo3DDist(start.x,start.y,start.z, destination.x,destination.y,destination.z)
	local num_mobjs = 30 + (distance / 60)/FU
	local random_offset = 8 * mine.scale
	local flash_time = 1 << (zmine.setup * 3/5)
	flash_time = flash_time * 3/5
	flash_time = min(8, max(flash_time >> 4, 2))
	for i = 0, num_mobjs, 1 do
		local fraction = FixedMul(FixedDiv(i*FU, num_mobjs*FU), time_fraction)
		local visual = P_SpawnMobj(
			P_Lerp(fraction, start.x, destination.x) + P_RandomFixedRange(-random_offset, random_offset),
			P_Lerp(fraction, start.y, destination.y) + P_RandomFixedRange(-random_offset, random_offset),
			P_Lerp(fraction, start.z, destination.z) + P_RandomFixedRange(-random_offset, random_offset),
			MT_PARTICLE
		)
		visual.sprite = SPR_THOK
		visual.scale = visual.scale / 6
		visual.fuse = 2
		visual.tics = visual.fuse
		visual.renderflags = visual.renderflags | RF_FULLBRIGHT
		visual.blendmode = AST_ADD
		visual.flags = visual.flags | MF_NOBLOCKMAP
		visual.color = mine.teamcolor
		visual.alpha = P_Lerp(time_fraction, FU / 10, FU)
		if (zmine.setup % flash_time == 0) then
			visual.scale = visual.scale * 2
		end
	end
end

-- width of the sprite, not the actual ray
local LASER_WIDTH = 128*FU
local function SetupVFX(mine)
	local zmine = mine.zmine
	local start = zmine.startVector
	local destination = zmine.endVector
	local distance = R_PointTo3DDist(start.x,start.y,start.z, destination.x,destination.y,destination.z)
	local direction_vector = Vec3.SphereToCartesian(zmine.rayangle, zmine.rayaiming)

	if (mine.lasermode == LMODE_HORIZONTAL) then
		zmine.bounds = {
			minx = min(start.x, destination.x),
			maxx = max(start.x, destination.x),
			miny = min(start.y, destination.y),
			maxy = max(start.y, destination.y)
		}
	else
		zmine.bounds = {
			minx = start.x - mine.radius,
			maxx = start.x + mine.radius,
			miny = start.y - mine.radius,
			maxy = start.y + mine.radius,
		}
	end

	local count = 0
	local offset = LASER_WIDTH / 2
	zmine.vfxmobjs = {}
	zmine.raydist = distance

	while (distance > 0) do
		count = count + 1
		local particle = P_SpawnMobjFromMobj(mine, 0,0,0, MT_PARTICLE)
		particle.sprite = SPR_SHCK
		particle.frame = C|FF_ADD|FF_PAPERSPRITE|FF_FULLBRIGHT
		particle.tics = -1
		particle.fuse = -1
		particle.angle = mine.angle
		particle.spritexscale = particle.spritexscale * 6/5
		particle.rollangle = zmine.rayaiming
		particle.radius = 11*mine.scale
		particle.height = particle.radius*2

		P_SetOrigin(particle,
			mine.x + FixedMul(direction_vector.x, offset),
			mine.y + FixedMul(direction_vector.y, offset),
			mine.z + FixedMul(direction_vector.z, offset) + 7*mine.scale
		)
		particle.originalpos = {x = particle.x, y = particle.y, z = particle.z, angle = particle.angle}

		particle.color = mine.teamcolor
		particle.colorized = true

		zmine.vfxmobjs[count] = particle
		offset = offset + LASER_WIDTH
		distance = distance - LASER_WIDTH
	end
	zmine.totalvfx = count
end

local function DestroyVFX(mine)
	local zmine = mine.zmine
	if not zmine then return end
	if not zmine.totalvfx then return end
	for index = 1, zmine.totalvfx, 1 do
		local visual = zmine.vfxmobjs[index]
		if visual and visual.valid then
			P_RemoveMobj(visual)
		end
	end

	if zmine.clientsfx and zmine.clientsfx.valid then
		P_RemoveMobj(zmine.clientsfx)
	end
end

local function UpdateVFX(mine)
	local zmine = mine.zmine
	if not zmine then return end
	if not zmine.totalvfx then return end

	local length_grow = (FU/20) * zmine.shootvfx
	local last_laser
	for index = 1, zmine.totalvfx, 1 do
		local visual = zmine.vfxmobjs[index]
		if not visual or not visual.valid then continue end -- !?

		visual.frame = (visual.frame & ~FF_FRAMEMASK)|P_RandomRange(A, H)
		visual.spritexscale = FU + length_grow
		visual.spriteyscale = P_RandomRange(FU*9/10, FU*11/10) + length_grow
		visual.alpha = P_RandomRange(FU/2, FU)
		visual.angle = visual.originalpos.angle

		if (mine.lasermode == LMODE_VERTICAL) then
			visual.angle = R_PointToAngle(mine.x, mine.y) + ANGLE_90
		end
		visual.mirrored = P_RandomChance(FU/2)

		local extra = length_grow * 50
		local offset = P_RandomFixedRange(-8*mine.scale - extra, 8*mine.scale + extra)
		local zoffset = 0
		if (extra > 0) then
			zoffset = P_RandomFixedRange(-extra, extra)
		end

		local original_position = visual.originalpos
		P_SetOrigin(visual,
			original_position.x + P_ReturnThrustX(nil, original_position.angle + ANGLE_90, offset),
			original_position.y + P_ReturnThrustY(nil, original_position.angle + ANGLE_90, offset),
			original_position.z + zoffset
		)
		if (last_laser and last_laser.valid)
		and (mine.lasermode == LMODE_HORIZONTAL) then
			last_laser.angle = R_PointToAngle2(last_laser.x,last_laser.y, visual.x,visual.y)
		end

		last_laser = visual
	end

	local random_offset = 11*mine.scale
	local angle = zmine.rayangle
	local distance = FixedDiv(zmine.raydist, zmine.totalvfx*FU) / 2
	local work = max(1, zmine.totalvfx / 10)
	local angle_vector = Vec3.SphereToCartesian(zmine.rayangle, zmine.rayaiming)
	while work do
		local progress = P_RandomFixed()
		local new_position = {
			x = P_Lerp(progress, zmine.startVector.x, zmine.endVector.x),
			y = P_Lerp(progress, zmine.startVector.y, zmine.endVector.y),
			z = P_Lerp(progress, zmine.startVector.z, zmine.endVector.z) - 2*random_offset
		}
		new_position.x = new_position.x + P_RandomFixedRange(-random_offset, random_offset)
		new_position.y = new_position.y + P_RandomFixedRange(-random_offset, random_offset)
		new_position.z = new_position.z + P_RandomFixedRange(0, 3*random_offset)

		local spark = P_SpawnMobj(new_position.x,new_position.y,new_position.z, MT_SUPERSPARK)
		spark.scale = FixedMul(mine.scale / 2, P_RandomRange(FU*8/10, FU))
		spark.blendmode = AST_SUBTRACT
		spark.colorized = true
		spark.color = SKINCOLOR_COBALT

		local speed = FixedMul(distance, P_RandomRange(FU/2,FU*3/4))
		spark.momx = spark.momx + FixedMul(angle_vector.x, speed)
		spark.momy = spark.momy + FixedMul(angle_vector.y, speed)
		spark.momz = spark.momz + FixedMul(angle_vector.z, speed)
		work = work - 1
	end

	if zmine.shootvfx then
		zmine.shootvfx = zmine.shootvfx - 1
	end

	-- impacts at the destination point
	local line_offset = 4*mine.scale
	local angle = FixedAngle(360 * P_RandomFixed())
	local spark = P_SpawnMobj(
		zmine.endVector.x - FixedMul(angle_vector.x, line_offset),
		zmine.endVector.y - FixedMul(angle_vector.y, line_offset),
		zmine.endVector.z - FixedMul(angle_vector.z, line_offset),
		MT_SUPERSPARK
	)

	spark.spritexscale = spark.spritexscale * 3/4
	spark.spriteyscale = spark.spritexscale
	spark.destscale = 0
	spark.flags = spark.flags & ~(MF_NOGRAVITY)

	random_offset = random_offset / 2
	if (mine.lasermode == LMODE_HORIZONTAL) then
		P_InstaThrustEvenIn2D(spark, zmine.rayangle + ANGLE_90, FixedMul(cos(angle), random_offset))
		spark.momz = FixedMul(sin(angle), random_offset)
	else
		P_InstaThrustEvenIn2D(spark, angle, random_offset)
	end
end

local function UpdateSFXTelegraph(mine) -- Clientside!!!!!!
	local player = displayplayer
	if not (player and player.valid) then return end

	local mo = player.realmo
	if not (mo and mo.valid) then return end

	local zmine = mine.zmine

	local sfx = zmine.clientsfx
	if not (sfx and sfx.valid) then
		local visual = P_SpawnMobjFromMobj(mine, 0,0,0, MT_THOK)
		visual.flags2 = visual.flags2 | MF2_DONTDRAW
		visual.tics = -1
		visual.fuse = -1
		visual.flags = visual.flags | MF_NOTHINK
		visual.radius = 11*mine.scale
		visual.height = visual.radius * 2
		zmine.clientsfx = visual
		sfx = visual
	end

	local line_point = P_ClosestPointOnLine3D(Vec3.MobjPosToVec(mo), zmine.startVector, zmine.endVector)
	P_MoveOrigin(sfx, line_point.x,line_point.y,line_point.z - sfx.radius)

	if not S_SoundPlaying(sfx, sfx_laser) then
		S_StartSound(sfx, sfx_laser)
	end
end

addHook("MobjThinker", function(mine)
	if (mine.health <= 0) then DestroyVFX(mine) return end

	-- shoot out the ray!
	if not mine.zmine then
		mine.zmine = {}
		mine.zmine.setup = L_SETUPTIME
		S_StartSound(mine, sfx_zlmp)
		if not Raycast_SendRay(mine) then return end
	end

	local zmine = mine.zmine
	local team_color = mine.teamcolor
	local aim_vector = Vec3.SphereToCartesian(zmine.rayangle, zmine.rayaiming)

	-- the ray is technically already fired at this point,
	-- but we wait to actually do anything with it first
	if zmine.setup then
		TelegraphFirstFire(mine)
		zmine.setup = zmine.setup - 1
		if (zmine.setup == 0) then
			local start = zmine.startVector
			local destination = zmine.endVector

			local dist = mine.radius
			local particle = P_SpawnMobj(
				start.x + FixedMul(aim_vector.x, dist),
				start.y + FixedMul(aim_vector.y, dist),
				start.z + FixedMul(aim_vector.z, dist),
				MT_PARTICLE
			)
			particle.state = S_ZE2_LMINEHIT
			particle.scale = particle.scale * 2
			particle.color = team_color
			particle.blendmode = AST_SUBTRACT

			-- again for the end...
			particle = P_SpawnMobj(
				destination.x - FixedMul(aim_vector.x, dist),
				destination.y - FixedMul(aim_vector.y, dist),
				destination.z - FixedMul(aim_vector.z, dist),
				MT_PARTICLE
			)

			particle.state = S_ZE2_LMINEHIT
			particle.scale = particle.scale * 2
			particle.color = team_color
			particle.blendmode = AST_SUBTRACT

			SetupVFX(mine)
			zmine.shootvfx = 16
			S_StartSound(mine, sfx_zlmf)
		end
		return
	end

	-- in case the mine moved, reshoot the ray...
	if (mine.x ~= zmine.startpoint.x)
	or (mine.y ~= zmine.startpoint.y)
	or (mine.z ~= zmine.startpoint.z) then
		DestroyVFX(mine)
		if not Raycast_SendRay(mine) then return end
		SetupVFX(mine)
	end

	-- ...then wait for the ray to hit something
	if (zmine.endpoint ~= nil) and (zmine.endVector == nil) then
		local dest = zmine.endpoint
		zmine.endVector = Vec3.New(dest.x, dest.y, dest.z)
		SetupVFX(mine)
	elseif (zmine.endpoint == nil) then
		DestroyVFX(mine)
		if not Raycast_SendRay(mine) then return end
		SetupVFX(mine)
		return
	end

	UpdateVFX(mine)
	UpdateSFXTelegraph(mine)

	-- using searchBlockmap would allow us to hit nonplayers
	-- with the ray, but if the ray isnt orthongonal, we'd be
	-- searching a huge area... in the interest of performance,
	-- we're better off using a player iterator instead
	local ray_radius = 11*mine.scale
	local ray_height = ray_radius * 2
	local bounds = zmine.bounds
	if (mine.team == 2) then
		team_color = SKINCOLOR_KETCHUP
	end

	for player in players.iterate do
		if player.spectator then continue end

		local mobj = player.mo
		if not (mobj and mobj.valid and mobj.health) then continue end
		if (mobj.team == mine.team and not cv_friendlyfire.value) then continue end

		-- bounding box check
		if (mobj.x + mobj.radius < bounds.minx) then continue end
		if (mobj.x - mobj.radius > bounds.maxx) then continue end
		if (mobj.y + mobj.radius < bounds.miny) then continue end
		if (mobj.y - mobj.radius > bounds.maxy) then continue end

		local hits, intersect = MobjIntersectsRay(zmine.startVector, zmine.endVector, ray_radius,ray_height, mobj)
		if not hits then continue end

		local visual_offset = -mobj.radius * 3/2
		local particle = P_SpawnMobj(
			FixedMul(aim_vector.x, visual_offset) + P_RandomRange(-20,20)*FU + intersect.x,
			FixedMul(aim_vector.y, visual_offset) + P_RandomRange(-20,20)*FU + intersect.y,
			FixedMul(aim_vector.z, visual_offset) + P_RandomRange(-20,20)*FU + intersect.z, MT_PARTICLE
		)

		local damage = 3
		if (mobj.team == 2) then
			damage = damage * 30
		end

		P_DamageMobj(mobj, particle, mine.target, damage)

		if ((leveltime % 4) == 0) then
			local sfx = P_RandomRange(sfx_zlmh0, sfx_zlmh3)
			S_StartSound(nil, sfx, player)
			S_StartSoundAtVolume(nil, sfx, 255 * 3/4, player)
			particle.state = S_ZE2_LMINEHIT
			particle.scale = FixedMul(particle.scale, P_RandomRange(FU*7/10, FU))
			particle.color = team_color
			particle.blendmode = AST_SUBTRACT
		else
			P_RemoveMobj(particle)
		end

		xSlinger.give_effect(mobj, "volt_electric", {
			normalspeed_multiplier = FU/8,
			in_knockback_multiplier = 3*FU,
			actionspd_multiplier = FU/2,
			out_damage_multiplier = 2*FU,
		}, 4*TICRATE, true)
	end
end, MT_ZE2_LASERMINE)

local function FenceCheck(self, mobj)
	local distance = (128 * FU) / 6
	local x = mobj.x
	local y = mobj.y
	local z = mobj.z
	local check = P_SpawnMobj(x, y, z, MT_LMINE_CHECK)
	check.target = mobj
	check.height = mobjinfo[self.placetype].height
	check.radius = mobjinfo[self.placetype].radius
	check.scale = FU
	check.flags2 = MF2_DONTDRAW
	check.alpha = 0
	check.fuse = 2
	check.momx = FixedMul(distance, cos(mobj.angle))
	check.momy = FixedMul(distance, sin(mobj.angle))

	for times = 0, 6, 1 do
		if not P_CheckPosition(check, x, y) then return false, check end
		P_XYMovement(check)
	end

	if not P_IsObjectOnGround(mobj) and not check.blockingline then return false, check end
	return true, check
end

local function StickToWall(self,mo,cmobj, x,y,z)
	-- im going to cry
	-- mee too :'<
	local line_angle = mo.angle
	local move_offset = FixedMul(mobjinfo[self.placetype].radius + 2*FU, mo.scale)
	local blocking_line = cmobj.blockingline
	if (blocking_line and blocking_line.valid) then
		local cx, cy = P_ClosestPointOnLine(x, y, blocking_line)
		local minx = min(blocking_line.v1.x, blocking_line.v2.x)
		local maxx = max(blocking_line.v1.x, blocking_line.v2.x)
		local miny = min(blocking_line.v1.y, blocking_line.v2.y)
		local maxy = max(blocking_line.v1.y, blocking_line.v2.y)
		local lineside = P_PointOnLineSide(
			cx - P_ReturnThrustX(nil, mo.angle, 2 * FU),
			cy - P_ReturnThrustY(nil, mo.angle, 2 * FU),
			blocking_line
		)

		line_angle = R_PointToAngle2(
			blocking_line.v1.x, blocking_line.v1.y, blocking_line.v2.x, blocking_line.v2.y
		) + ANGLE_90 * (lineside and 1 or -1)

		x = clamp(minx, cx, maxx) + P_ReturnThrustX(nil, line_angle, move_offset)
		y = clamp(miny, cy, maxy) + P_ReturnThrustY(nil, line_angle, move_offset)
		z = z + 6 * mo.scale
	end
	return x, y, z, line_angle, (blocking_line and blocking_line.valid)
end

local function FenceVisual(self, mobj)
	local distance = 128 * FU
	local x = mobj.x + FixedMul(distance, cos(mobj.angle))
	local y = mobj.y + FixedMul(distance, sin(mobj.angle))
	local z = mobj.z
	local angle = mobj.angle

	local visual = mobj.visual_fence
	if not visual or not visual.valid then
		visual = P_SpawnMobj(x, y, z, MT_ZVISUAL)
		mobj.visual_fence = visual
	end

	local spawnstate = states[mobjinfo[self.placetype].spawnstate]
	local valid, cmobj = FenceCheck(self, mobj)
	visual.height = mobjinfo[self.placetype].height
	visual.radius = mobjinfo[self.placetype].radius
	visual.momx = mobj.momx
	visual.momy = mobj.momy
	visual.momz = mobj.momz
	visual.sprite = spawnstate.sprite
	visual.frame = (spawnstate.frame & FF_FRAMEMASK)|FF_ADD

	local color = valid and SKINCOLOR_TURQUOISE or SKINCOLOR_RED
	visual.color = color
	visual.colorized = true
	visual.drawonlyforplayer = mobj.player
	visual.alpha = FU / 2
	visual.fuse = 3

	x, y, z, angle = StickToWall(self,mobj,cmobj, x,y,z)

	visual.angle = angle
	P_MoveOrigin(visual, x, y, z)
	return cmobj
end

xSlinger.registerItem("laser_mine", {
	displayname = "Laser Mine";

	icon = "FENCEIND";

	dropstate = S_ZE2_WOODFENCE_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	firerate = 1;

	count = 1;
	maxcount = 10;

	placetype = MT_ZE2_LASERMINE;
	color = SKINCOLOR_BROWN;
	holdfunc = FenceVisual;

	usefunc = function(self, mo)
		local valid, cmobj = FenceCheck(self, mo)
		if not valid then return true end

		local lmode = LMODE_VERTICAL
		local line_ang = mo.angle
		local x = mo.x + cos(mo.angle)*128
		local y = mo.y + sin(mo.angle)*128
		local z = mo.z
		local stuck = false
		x,y,z,line_ang,stuck = StickToWall(self,mo,cmobj, x,y,z)
		if stuck then
			lmode = LMODE_HORIZONTAL
		end

		local turret = P_SpawnMobj(x, y, z, self.placetype)
		turret.team = mo.team
		turret.angle = line_ang
		turret.target = mo
		if (lmode == LMODE_HORIZONTAL) then
			turret.flags = turret.flags | (MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT)
			turret.antiknockback = true
		end

		local teamcolor = SKINCOLOR_COBALT
		if (turret.team == 2) then
			teamcolor = SKINCOLOR_KETCHUP
		end
		turret.teamcolor = teamcolor
		turret.lasermode = lmode
		S_StartSound(turret, sfx_s3k76)
	end;

	hold_object = {
		state = S_ZE2_WOODFENCE_DROP;
		pos = {  -- at this pos, the object is at the right of your body
			x = FU;
			y = FU/2;
			z = 0;
		};
		pos_anim = {
			x = -FU;
			y = (FU*3)/2;
			z = -FU/3;
		};
		spritescale = {
			x = 2*FU;
			y = 2*FU;
		}
	};

	hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
})
