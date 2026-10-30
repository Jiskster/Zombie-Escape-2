-- p_larp
local function P_Lerp(frac, from, to)
	return from + FixedMul(to - from, frac)
end
local function R_PointTo3DDist(x1,y1,z1, x2,y2,z2)
	return FixedHypot(FixedHypot(x2 - x1, y2 - y1), z2 - z1)
end
local function P_RandomFixedRange(a,b)
	return a + FixedMul((b - a), P_RandomFixed())
end
local function TraceRay(lstart,lend)
	for i = 0,256
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
	local n = Vec3.New(V.x, V.y, V.z) / d
	t = Vec3.Dot(n, c)
	
	if t <= 0
		return lstart
	elseif t >= d
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
	)
		return true, intersect
	end
	return false, nil
end

freeslot("MT_ZE2_LASERMINE")
mobjinfo[MT_ZE2_LASERMINE] = {
	spawnhealth = 100,
	spawnstate = S_ZE2_AUTOTURRET,
	painsound = sfx_dmpain,
	painchance = 192*FRACUNIT,
	deathstate = S_RINGEXPLODE,
	deathsound = sfx_pop,
	radius = 24*FU,
	height = 48*FU,
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

local function Raycast_SetDest(source, x,y,z)
	source.zmine.endpoint = {
		x = x, y = y, z = z
	}
end

local function BlockedCollision(self, source, target, line, mobj)
	if not (target and target.valid) then return end
	if not (source and source.valid and source.type == MT_ZE2_LASERMINE) then return end
	if not (source.zmine) then return end
	
	Raycast_SetDest(source, target.x,target.y,target.z)
	P_RemoveMobj(target)
end

local function Tick(self, source, target)
	if not target or not target.valid then return end
	if not (source and source.valid and source.type == MT_ZE2_LASERMINE) then
		P_KillMobj(target)
		return
	end

	local range = 256
	local x, y, z = target.x, target.y, target.x
	local newx, newy, newz = x,y,z
	local hit = false
	while (target and target.valid) do
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
		
		P_SpawnMobjFromMobj(target, 0,0,0, MT_THOK)
	end
	
	Raycast_SetDest(source, newx,newy,newz)
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

addHook("TouchSpecial", do
	return true
end, MT_ZE2_LASERMINE)

local cv_friendlyfire = CV_FindVar("friendlyfire")
local function Raycast_SendRay(mine)
	mine.zmine.startpoint = {
		x = mine.x, y = mine.y, z = mine.z
	}
	mine.zmine.endpoint = nil
	
	local marker = xSlinger.SpawnMissile({
		source = mine,
		type = "LMINE_CAST",
		angle = mine.angle,
		allow_aim = false,
		flags2 = MF2_DONTDRAW,
	})
	
	if (marker and marker.valid) then
		marker.flags = $|MF_NOCLIPTHING
		marker.momz = 0
	end
	
	-- convert to vectors
	local start = mine.zmine.startpoint
	mine.zmine.startVector = Vec3.New(start.x, start.y, start.z + (41*mine.height/48))
	mine.zmine.endVector = nil
end

-- width of the sprite, not the actual ray
local LASER_WIDTH = 128*FU
local function SetupVFX(mine)
	local zm = mine.zmine
	local start = zm.startVector
	local dest = zm.endVector
	local dist = R_PointToDist2(start.x,start.y, dest.x,dest.y)
	
	zm.bounds = {
		minx = min(start.x, dest.x),
		maxx = max(start.x, dest.x),
		miny = min(start.y, dest.y),
		maxy = max(start.y, dest.y)
	}
	
	local count = 0
	local offset = LASER_WIDTH / 2
	zm.vfxmobjs = {}
	zm.raydist = dist
	zm.rayangle = R_PointToAngle2(start.x,start.y, dest.x,dest.y)
	
	while (dist > 0) do
		count = $ + 1
		local v = P_SpawnMobjFromMobj(mine, 0,0,0, MT_PARTICLE)
		v.sprite = SPR_SHCK
		v.frame = C|FF_ADD|FF_PAPERSPRITE|FF_FULLBRIGHT
		v.tics = -1
		v.fuse = -1
		v.angle = mine.angle
		v.spritexscale = $ * 6/5
		
		P_SetOrigin(v,
			mine.x + P_ReturnThrustX(nil, mine.angle, offset),
			mine.y + P_ReturnThrustY(nil, mine.angle, offset),
			mine.z + mine.height/2
		)
		v.originalpos = {
			x = v.x, y = v.y, z = v.z, angle = v.angle
		}
		
		if (mine.team == 1) then
			v.color = SKINCOLOR_COBALT
		elseif (mine.team == 2) then
			v.color = SKINCOLOR_KETCHUP
		end
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
	
	if zm.clientsfx and zm.clientsfx.valid
		P_RemoveMobj(zm.clientsfx)
	end
end
local function UpdateVFX(mine)
	local zm = mine.zmine
	if not zm then return end
	if not zm.totalvfx then return end
	
	local lastlaser
	for i = 1, zm.totalvfx do
		local v = zm.vfxmobjs[i]
		v.frame = ($ &~FF_FRAMEMASK)|P_RandomRange(A, H)
		v.spriteyscale = P_RandomRange(FU*9/10, FU*11/10)
		v.alpha = P_RandomRange(FU/2, FU)
		
		local offset = P_RandomFixedRange(-8*mine.scale, 8*mine.scale)
		local opos = v.originalpos
		P_SetOrigin(v,
			opos.x + P_ReturnThrustX(nil, opos.angle + ANGLE_90, offset),
			opos.y + P_ReturnThrustY(nil, opos.angle + ANGLE_90, offset),
			opos.z --+ offset /
		)
		if (lastlaser and lastlaser.valid)
			lastlaser.angle = R_PointToAngle2(lastlaser.x,lastlaser.y, v.x,v.y)
		end
		
		lastlaser = v
	end
	
	local randoffset = 8*mine.scale
	local angle = zm.rayangle
	local dist = FixedDiv(zm.raydist, zm.totalvfx*FU) / 2
	local work = max(1, zm.totalvfx / 10)
	while (work) do
		local progress = P_RandomFixed()
		local newposition = {
			x = P_Lerp(progress, zm.startVector.x, zm.endVector.x),
			y = P_Lerp(progress, zm.startVector.y, zm.endVector.y),
			z = P_Lerp(progress, zm.startVector.z, zm.endVector.z) - 16*mine.scale
		}
		newposition.x = $ + P_RandomFixedRange(-randoffset, randoffset)
		newposition.y = $ + P_RandomFixedRange(-randoffset, randoffset)
		newposition.z = $ + P_RandomFixedRange(-randoffset, randoffset*3)
		
		local v = P_SpawnMobj(newposition.x,newposition.y,newposition.z, MT_SUPERSPARK)
		v.scale = FixedMul(mine.scale / 2, P_RandomRange(FU*8/10, FU))
		v.blendmode = AST_SUBTRACT
		v.colorized = true
		v.color = SKINCOLOR_COBALT
		
		P_Thrust(v, angle, FixedMul(dist, P_RandomRange(FU/2,FU*3/4)))
		work = $ - 1
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
	if not (sfx and sfx.valid)
		local new = P_SpawnMobjFromMobj(mine, 0,0,0, MT_RAY)
		new.flags2 = $|MF2_DONTDRAW
		new.tics = -1
		new.fuse = -1
		zm.clientsfx = new
		sfx = new
	end
	
	local linepoint = P_ClosestPointOnLine3D(Vec3.MobjPosToVec(mo), zm.startVector, zm.endVector)
	P_MoveOrigin(sfx, linepoint.x,linepoint.y,linepoint.z)
	
	if not S_SoundPlaying(sfx, sfx_laser)
		S_StartSound(sfx, sfx_laser)
	end
end

addHook("MobjThinker", function(mine)
	if (mine.health <= 0) then return end
	
	-- shoot out the ray!
	if not mine.zmine then
		mine.zmine = {}
		Raycast_SendRay(mine)
	end
	local zm = mine.zmine
	
	-- in case the mine moved, reshoot the ray...
	if (mine.x ~= zm.startpoint.x)
	or (mine.y ~= zm.startpoint.y)
	or (mine.z ~= zm.startpoint.z) then
		DestroyVFX(mine)
		Raycast_SendRay(mine)
	end
	-- ...then wait for the ray to hit something
	if (zm.endpoint ~= nil and zm.endVector == nil) then
		print("ray hit")
		local dest = zm.endpoint
		zm.endVector = Vec3.New(dest.x, dest.y, dest.z)
		SetupVFX(mine)
	elseif (zm.endpoint == nil) then
		print("refire")
		DestroyVFX(mine)
		Raycast_SendRay(mine)
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
	local teamcolor = SKINCOLOR_COBALT
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
		
		local temp = P_SpawnMobj(
			P_RandomRange(-20,20)*FU + inter.x - P_ReturnThrustX(nil, zm.rayangle, mo.radius*2),
			P_RandomRange(-20,20)*FU + inter.y - P_ReturnThrustY(nil, zm.rayangle, mo.radius*2),
			P_RandomRange(-20,20)*FU + inter.z, MT_THOK
		)
		temp.state = S_ZE2_LMINEHIT
		temp.scale = FixedMul($, P_RandomRange(FU*7/10, FU))
		temp.color = teamcolor
		temp.blendmode = AST_SUBTRACT
		
		local damage = 3
		if (mo.team == 2) then
			damage = $ * 30
		end
		
		P_DamageMobj(mo, temp, mine.target, damage)
		
		xSlinger.give_effect(mo, "volt_electric", {
			normalspeed_multiplier = FU/8,
			in_knockback_multiplier = 3*FU,
			actionspd_multiplier = FU/2,
			out_damage_multiplier = 2*FU,
		}, 4*TICRATE, true)
	end
end, MT_ZE2_LASERMINE)

xSlinger.registerItem("laser_mine", {
	displayname = "Laser Mine";

	icon = "FENCEIND";

	dropstate = S_ZE2_WOODFENCE_DROP;
	dropscale = 2*FU;
	dropyoffset = 8*FU;

	firerate = 1;

	count = 1;
	maxcount = 10;

	color = SKINCOLOR_BROWN;
	holdfunc = FenceVisual;

	usefunc = function(self, mo)
		local x = mo.x + cos(mo.angle)*50
		local y = mo.y + sin(mo.angle)*50
		local z = mo.z
		
		local turret = P_SpawnMobj(x, y, z, MT_ZE2_LASERMINE)
		turret.team = mo.team
		turret.angle = mo.angle
		turret.target = mo
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
