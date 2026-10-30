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

---- Functions
local function P_Lerp(frac, from, to)
	return from + FixedMul(to - from, frac)
end

local function R_PointTo3DDist(x1,y1,z1, x2,y2,z2)
	return FixedHypot(FixedHypot(x2 - x1, y2 - y1), z2 - z1)
end

local function P_RandomFixedRange(a,b)
	return a + FixedMul((b - a), P_RandomFixed())
end
local function clamp(minimum,value,maximum)
	return max(minimum,min(maximum,value))
end

local function TraceRay(lstart,lend)
	for i = 0,256 do
		local frac = FixedDiv(i*FU, 256*FU)
		local t = P_SpawnMobj(
			P_Lerp(frac, lstart.x, lend.x),
			P_Lerp(frac, lstart.y, lend.y),
			P_Lerp(frac, lstart.z, lend.z),
			MT_THOK
		)
		t.scale = $ / 3
		t.fuse = 2
		t.tics = t.fuse
		t.blendmode = AST_ADD
		t.flags = $|MF_NOBLOCKMAP
	end
end

local function P_ClosestPointOnLine3D(p, lstart, lend)
	local t,d
	local V = Vec3.Sub(lend, lstart)
	local c = Vec3.Sub(p, lstart)
	
	-- d = R_PointToDist2(0, lend.z, R_PointToDist2(lend.x, lend.y, lstart.x, lstart.y), lstart.z)
	d = R_PointTo3DDist(lstart.x,lstart.y,lstart.z, lend.x,lend.y,lend.z)
	local n = Vec3.Div(Vec3.New(V.x, V.y, V.z), d)
	t = Vec3.Dot(n, c)
	
	if t <= 0 then
		return lstart
	elseif t >= d then
		return lend
	end
	
	n = $ * t
	return Vec3.Add(lstart, n)
end
local function MobjIntersectsRay(start,dest, radius,height, mo)
	local intersect = P_ClosestPointOnLine3D(Vec3.MobjPosToVec(mo), start, dest)
	intersect = Vec3.New(intersect.x, intersect.y, intersect.z - height/2)
	
	if abs(intersect.x - mo.x) <= mo.radius + radius
	and abs(intersect.y - mo.y) <= mo.radius + radius
	and (
		mo.z <= intersect.z + height -- check overhead
		and mo.z+mo.height >= intersect.z -- check underhead
	) then
		return true, intersect
	end
	return false, nil
end
----

sfxinfo[freeslot("sfx_zlmp")].caption = "Laser mine primes"
sfxinfo[freeslot("sfx_zlmf")] = {
	flags = SF_X2AWAYSOUND,
	caption = "Laser mine fires"
}

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
addHook("TouchSpecial", do return true; end, MT_ZE2_LASERMINE)

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

---- Raycast definition
local function Raycast_SetDest() end -- prototype

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
	local newx, newy, newz = x,y,z
	local hit = false
	while (target and target.valid and target.health > 0) do
		P_XYMovement(target)
		if not (target.valid) then break end
		P_ZMovement(target)
		if not (target.valid) then break end
		newx = target.x
		newy = target.y
		newz = target.z
		
		if (target.z <= target.floorz or target.z + target.height >= target.ceilingz)
		or (target.eflags & MFE_JUSTSTEPPEDDOWN) then
			break
		end
		
		if (x == target.x and y == target.y and z == target.z) then
			break
		end
	end
	
	Raycast_SetDest(source, newx,newy,newz)
	if (target and target.valid)
		P_KillMobj(target)
	end
end

local function Raycast_SendRay(mine)
	mine.zmine.startpoint = {
		x = mine.x, y = mine.y, z = mine.z
	}
	mine.zmine.endpoint = nil
	
	local sec = mine.subsector.sector
	local slope = sec.f_slope
	local slopeaim = 0
	if false --(bomb.ceilingmode) then
		slope = sec.c_slope
	end
	if slope then
		slopeaim = FixedMul(slope.zangle, cos(mine.angle))
		if false --bomb.ceilingmode
			slopeaim = -$
		end
	end
	
	local aimangle = 0
	if (mine.lasermode == LMODE_VERTICAL) then
		aimangle = ANGLE_90
	--elseif (mine.lasermode == LMODE_HORIZONTAL) then
	end
	
	local marker = xSlinger.SpawnMissile({
		source = mine,
		type = "LMINE_CAST",
		angle = mine.angle,
		aiming = aimangle,
		allow_aim = true,
		flags2 = MF2_DONTDRAW,
	})
	
	if (marker and marker.valid) then
		marker.flags = $|MF_NOCLIPTHING|MF_NOTHINK
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
		if (marker and marker.valid) then P_RemoveMobj(marker); end
	end
	
	-- convert to vectors
	local start = mine.zmine.startpoint
	local dest = mine.zmine.endpoint
	-- Uh oh!!!!!!
	if not dest then
		P_KillMobj(mine)
		return false
	end
	
	mine.zmine.startVector = Vec3.New(start.x, start.y, start.z + (41*mine.height/48))
	mine.zmine.endVector = Vec3.New(dest.x, dest.y, dest.z)
	mine.zmine.rayangle = mine.angle
	mine.zmine.rayaiming = aimangle
	return true
end

Raycast_SetDest = function(source, x,y,z)
	source.zmine.endpoint = {
		x = x, y = y, z = z
	}
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
	local zm = mine.zmine
	local start = zm.startVector
	local dest = zm.endVector
	local timefrac = ease_inquint(FU - FixedDiv(zm.setup*FU, L_SETUPTIME*FU), 0, FU)
	local dist = R_PointTo3DDist(start.x,start.y,start.z, dest.x,dest.y,dest.z)
	local nummobjs = 30 + (dist / 60)/FU
	local randoffset = 8 * mine.scale
	local flashtime = 1 << (zm.setup * 3/5)
	flashtime = $ * 3/5
	flashtime = min(8, max($ >> 4, 2))
	for i = 0,nummobjs do
		local frac = FixedMul(FixedDiv(i*FU, nummobjs*FU), timefrac)
		local t = P_SpawnMobj(
			P_Lerp(frac, start.x, dest.x) + P_RandomFixedRange(-randoffset, randoffset),
			P_Lerp(frac, start.y, dest.y) + P_RandomFixedRange(-randoffset, randoffset),
			P_Lerp(frac, start.z, dest.z) + P_RandomFixedRange(-randoffset, randoffset),
			MT_PARTICLE
		)
		t.sprite = SPR_THOK
		t.scale = $ / 6
		t.fuse = 2
		t.tics = t.fuse
		t.renderflags = $|RF_FULLBRIGHT
		t.blendmode = AST_ADD
		t.flags = $|MF_NOBLOCKMAP
		t.color = mine.teamcolor
		t.alpha = P_Lerp(timefrac, FU/10, FU)
		if (zm.setup % flashtime == 0)
			t.scale = $ * 2
		end
	end
end

-- width of the sprite, not the actual ray
local LASER_WIDTH = 128*FU
local function SetupVFX(mine)
	local zm = mine.zmine
	local start = zm.startVector
	local dest = zm.endVector
	local dist = R_PointTo3DDist(start.x,start.y,start.z, dest.x,dest.y,dest.z)
	local dirvector = Vec3.SphereToCartesian(zm.rayangle, zm.rayaiming)
	
	if (mine.lasermode == LMODE_HORIZONTAL) then
		zm.bounds = {
			minx = min(start.x, dest.x),
			maxx = max(start.x, dest.x),
			miny = min(start.y, dest.y),
			maxy = max(start.y, dest.y)
		}
	else
		zm.bounds = {
			minx = start.x - mine.radius,
			maxx = start.x + mine.radius,
			miny = start.y - mine.radius,
			maxy = start.y + mine.radius,
		}
	end
	
	local count = 0
	local offset = LASER_WIDTH / 2
	zm.vfxmobjs = {}
	zm.raydist = dist
	
	while (dist > 0) do
		count = $ + 1
		local v = P_SpawnMobjFromMobj(mine, 0,0,0, MT_PARTICLE)
		v.sprite = SPR_SHCK
		v.frame = C|FF_ADD|FF_PAPERSPRITE|FF_FULLBRIGHT
		v.tics = -1
		v.fuse = -1
		v.angle = mine.angle
		v.spritexscale = $ * 6/5
		v.rollangle = zm.rayaiming
		v.radius = 11*mine.scale
		v.height = v.radius*2
		
		P_SetOrigin(v,
			mine.x + FixedMul(dirvector.x, offset),
			mine.y + FixedMul(dirvector.y, offset),
			mine.z + FixedMul(dirvector.z, offset) + 7*mine.scale
		)
		v.originalpos = {
			x = v.x, y = v.y, z = v.z, angle = v.angle
		}
		
		v.color = mine.teamcolor
		v.colorized = true
		
		zm.vfxmobjs[count] = v
		offset = $ + LASER_WIDTH
		dist = $ - LASER_WIDTH
	end
	zm.totalvfx = count
end
local function DestroyVFX(mine)
	local zm = mine.zmine
	if not zm then return end
	if not zm.totalvfx then return end
	for i = 1, zm.totalvfx do
		local mo = zm.vfxmobjs[i]
		if (mo and mo.valid) then P_RemoveMobj(mo); end
	end
	
	if (zm.clientsfx and zm.clientsfx.valid) then
		P_RemoveMobj(zm.clientsfx)
	end
end
local function UpdateVFX(mine)
	local zm = mine.zmine
	if not zm then return end
	if not zm.totalvfx then return end
	
	local lgrow = (FU/20) * zm.shootvfx
	local lastlaser
	for i = 1, zm.totalvfx do
		local v = zm.vfxmobjs[i]
		if not (v and v.valid) then continue end -- !?
		v.frame = ($ &~FF_FRAMEMASK)|P_RandomRange(A, H)
		v.spritexscale = FU + lgrow
		v.spriteyscale = P_RandomRange(FU*9/10, FU*11/10) + lgrow
		v.alpha = P_RandomRange(FU/2, FU)
		v.angle = v.originalpos.angle
		
		if (mine.lasermode == LMODE_VERTICAL) then
			v.angle = R_PointToAngle(mine.x, mine.y) + ANGLE_90
		end
		v.mirrored = P_RandomChance(FU/2)
		
		local extra = lgrow * 50
		local offset = P_RandomFixedRange(-8*mine.scale - extra, 8*mine.scale + extra)
		local zoffset = 0
		if (extra > 0) then
			zoffset = P_RandomFixedRange(-extra, extra)
		end
		
		local opos = v.originalpos
		P_SetOrigin(v,
			opos.x + P_ReturnThrustX(nil, opos.angle + ANGLE_90, offset),
			opos.y + P_ReturnThrustY(nil, opos.angle + ANGLE_90, offset),
			opos.z + zoffset
		)
		if (lastlaser and lastlaser.valid)
		and (mine.lasermode == LMODE_HORIZONTAL) then
			lastlaser.angle = R_PointToAngle2(lastlaser.x,lastlaser.y, v.x,v.y)
		end
		
		lastlaser = v
	end
	
	local randoffset = 11*mine.scale
	local angle = zm.rayangle
	local dist = FixedDiv(zm.raydist, zm.totalvfx*FU) / 2
	local work = max(1, zm.totalvfx / 10)
	local anglevector = Vec3.SphereToCartesian(zm.rayangle, zm.rayaiming)
	while (work) do
		local progress = P_RandomFixed()
		local newposition = {
			x = P_Lerp(progress, zm.startVector.x, zm.endVector.x),
			y = P_Lerp(progress, zm.startVector.y, zm.endVector.y),
			z = P_Lerp(progress, zm.startVector.z, zm.endVector.z) - 2*randoffset
		}
		newposition.x = $ + P_RandomFixedRange(-randoffset, randoffset)
		newposition.y = $ + P_RandomFixedRange(-randoffset, randoffset)
		newposition.z = $ + P_RandomFixedRange(0, 3*randoffset)
		
		local v = P_SpawnMobj(newposition.x,newposition.y,newposition.z, MT_SUPERSPARK)
		v.scale = FixedMul(mine.scale / 2, P_RandomRange(FU*8/10, FU))
		v.blendmode = AST_SUBTRACT
		v.colorized = true
		v.color = SKINCOLOR_COBALT
		
		local speed = FixedMul(dist, P_RandomRange(FU/2,FU*3/4))
		v.momx = $ + FixedMul(anglevector.x, speed)
		v.momy = $ + FixedMul(anglevector.y, speed)
		v.momz = $ + FixedMul(anglevector.z, speed)
		work = $ - 1
	end
	if zm.shootvfx then zm.shootvfx = $ - 1; end
	
	-- impacts at the destination point
	local lineoffset = 4*mine.scale
	local angle = FixedAngle(360 * P_RandomFixed())
	local p = P_SpawnMobj(
		zm.endVector.x - FixedMul(anglevector.x, lineoffset),
		zm.endVector.y - FixedMul(anglevector.y, lineoffset),
		zm.endVector.z - FixedMul(anglevector.z, lineoffset),
		MT_SUPERSPARK
	)
	p.spritexscale = $ * 3/4
	p.spriteyscale = p.spritexscale
	p.destscale = 0
	p.flags = $ &~MF_NOGRAVITY
	
	randoffset = $ / 2
	if (mine.lasermode == LMODE_HORIZONTAL) then
		P_InstaThrustEvenIn2D(p, zm.rayangle + ANGLE_90, FixedMul(cos(angle), randoffset))
		p.momz = FixedMul(sin(angle), randoffset)
	else
		P_InstaThrustEvenIn2D(p, angle, randoffset)
	end
end
-- Clientside!!!!!!
local function UpdateSFXTelegraph(mine)
	local play = displayplayer
	if not (play and play.valid) then return end
	local mo = play.realmo
	if not (mo and mo.valid) then return end
	local zm = mine.zmine
	
	local sfx = zm.clientsfx
	if not (sfx and sfx.valid) then
		local new = P_SpawnMobjFromMobj(mine, 0,0,0, MT_THOK)
		new.flags2 = $|MF2_DONTDRAW
		new.tics = -1
		new.fuse = -1
		new.flags = $|MF_NOTHINK
		new.radius = 11*mine.scale
		new.height = new.radius * 2
		zm.clientsfx = new
		sfx = new
	end
	
	local linepoint = P_ClosestPointOnLine3D(Vec3.MobjPosToVec(mo), zm.startVector, zm.endVector)
	P_MoveOrigin(sfx, linepoint.x,linepoint.y,linepoint.z - sfx.radius)
	
	if not S_SoundPlaying(sfx, sfx_laser) then
		S_StartSound(sfx, sfx_laser)
	end
end

addHook("MobjThinker", function(mine)
	if (mine.health <= 0) then DestroyVFX(mine); return end
	
	-- shoot out the ray!
	if not mine.zmine then
		mine.zmine = {}
		mine.zmine.setup = L_SETUPTIME
		S_StartSound(mine, sfx_zlmp)
		if not Raycast_SendRay(mine) then return end
	end
	local zm = mine.zmine
	local teamcolor = mine.teamcolor
	local aimvector = Vec3.SphereToCartesian(zm.rayangle, zm.rayaiming)
	
	-- the ray is technically already fired at this point,
	-- but we wait to actually do anything with it first
	if zm.setup then
		TelegraphFirstFire(mine)
		zm.setup = $ - 1
		if (zm.setup == 0) then
			local start = zm.startVector
			local dest = zm.endVector
			
			local dist = mine.radius
			local vfx = P_SpawnMobj(
				start.x + FixedMul(aimvector.x, dist),
				start.y + FixedMul(aimvector.y, dist),
				start.z + FixedMul(aimvector.z, dist),
				MT_PARTICLE
			)
			vfx.state = S_ZE2_LMINEHIT
			vfx.scale = $ * 2
			vfx.color = teamcolor
			vfx.blendmode = AST_SUBTRACT
			
			-- again for the end...
			vfx = P_SpawnMobj(
				dest.x - FixedMul(aimvector.x, dist),
				dest.y - FixedMul(aimvector.y, dist),
				dest.z - FixedMul(aimvector.z, dist),
				MT_PARTICLE
			)
			vfx.state = S_ZE2_LMINEHIT
			vfx.scale = $ * 2
			vfx.color = teamcolor
			vfx.blendmode = AST_SUBTRACT	
			
			SetupVFX(mine)
			zm.shootvfx = 16
			S_StartSound(mine, sfx_zlmf)
		end
		return
	end
	
	-- in case the mine moved, reshoot the ray...
	if (mine.x ~= zm.startpoint.x)
	or (mine.y ~= zm.startpoint.y)
	or (mine.z ~= zm.startpoint.z) then
		DestroyVFX(mine)
		if not Raycast_SendRay(mine) then return end
		SetupVFX(mine)
	end
	-- ...then wait for the ray to hit something
	if (zm.endpoint ~= nil and zm.endVector == nil) then
		local dest = zm.endpoint
		zm.endVector = Vec3.New(dest.x, dest.y, dest.z)
		SetupVFX(mine)
	elseif (zm.endpoint == nil) then
		DestroyVFX(mine)
		if not Raycast_SendRay(mine) then return end
		SetupVFX(mine)
		return
	end
	
	UpdateVFX(mine)
	UpdateSFXTelegraph(mine)
	--TraceRay(zm.startVector, zm.endVector)
	
	-- using searchBlockmap would allow us to hit nonplayers
	-- with the ray, but if the ray isnt orthongonal, we'd be
	-- searching a huge area... in the interest of performance,
	-- we're better off using a player iterator instead
	local rayRad = 11*mine.scale
	local rayHei = rayRad * 2
	local bounds = zm.bounds
	if mine.team == 2 then teamcolor = SKINCOLOR_KETCHUP; end
	for play in players.iterate do
		if play.spectator then continue end
		local mo = play.mo
		if not (mo and mo.valid and mo.health) then continue end
		if (mo.team == mine.team and not cv_friendlyfire.value) then continue end
		
		-- bounding box check
		if (mo.x + mo.radius < bounds.minx) then continue end
		if (mo.x - mo.radius > bounds.maxx) then continue end
		if (mo.y + mo.radius < bounds.miny) then continue end
		if (mo.y - mo.radius > bounds.maxy) then continue end
		
		local hits, inter = MobjIntersectsRay(zm.startVector, zm.endVector, rayRad,rayHei, mo)
		if not hits then continue end
		
		local vfxoffset = -mo.radius * 3/2
		local temp = P_SpawnMobj(
			FixedMul(aimvector.x, vfxoffset) + P_RandomRange(-20,20)*FU + inter.x,
			FixedMul(aimvector.y, vfxoffset) + P_RandomRange(-20,20)*FU + inter.y,
			FixedMul(aimvector.z, vfxoffset) + P_RandomRange(-20,20)*FU + inter.z, MT_PARTICLE
		)
		
		local damage = 3
		if (mo.team == 2) then
			damage = $ * 30
		end
		
		P_DamageMobj(mo, temp, mine.target, damage)
		
		if (leveltime % 4 == 0) then
			temp.state = S_ZE2_LMINEHIT
			temp.scale = FixedMul($, P_RandomRange(FU*7/10, FU))
			temp.color = teamcolor
			temp.blendmode = AST_SUBTRACT
		else
			P_RemoveMobj(temp)
		end
		
		xSlinger.give_effect(mo, "volt_electric", {
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
	
	for i = 0,6
		if not P_CheckPosition(check, x, y) then return false, check end
		P_XYMovement(check)
	end
	--if (check.floorz < (mobj.z - check.height)) then return false, check end
	--if (check.floorz > (mobj.z + mobj.height)) then return false, check end
	--if (check.ceilingz < (check.z + check.height)) then return false, check end
	if not P_IsObjectOnGround(mobj) and not check.blockingline then return false, check end
	return true, check
end

local function StickToWall(self,mo,cmobj, x,y,z)
	-- im going to cry
	local line_ang = mo.angle
	local moveoffset = FixedMul(mobjinfo[self.placetype].radius + 2*FU, mo.scale)
	local bline = cmobj.blockingline
	if (bline and bline.valid)
		local cx,cy = P_ClosestPointOnLine(x, y, bline)
		local minx = min(bline.v1.x, bline.v2.x)
		local maxx = max(bline.v1.x, bline.v2.x)
		local miny = min(bline.v1.y, bline.v2.y)
		local maxy = max(bline.v1.y, bline.v2.y)
		local lineside = P_PointOnLineSide(
			cx - P_ReturnThrustX(nil, mo.angle, 2*FU),
			cy - P_ReturnThrustY(nil, mo.angle, 2*FU),
			bline
		)
		line_ang = R_PointToAngle2(
			bline.v1.x, bline.v1.y, bline.v2.x, bline.v2.y
		) + ANGLE_90*(lineside and 1 or -1)
		
		x = clamp(minx, cx, maxx) + P_ReturnThrustX(nil, line_ang, moveoffset)
		y = clamp(miny, cy, maxy) + P_ReturnThrustY(nil, line_ang, moveoffset)
		z = $ + 6*mo.scale
	end
	return x,y,z,line_ang, (bline and bline.valid)
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
	
	x,y,z,angle = StickToWall(self,mobj,cmobj, x,y,z)
	
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
		if (stuck) then
			lmode = LMODE_HORIZONTAL
		end
		
		local turret = P_SpawnMobj(x, y, z, self.placetype)
		turret.team = mo.team
		turret.angle = line_ang
		turret.target = mo
		if (lmode == LMODE_HORIZONTAL) then
			turret.flags = $|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT
			turret.antiknockback = true
		end
		local teamcolor = SKINCOLOR_COBALT
		if turret.team == 2 then teamcolor = SKINCOLOR_KETCHUP; end
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
