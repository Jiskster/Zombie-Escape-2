-- partial and edited sglib

-- returns viewx, viewy, viewz, viewangle, aimingangle, viewroll
local cv_tilting
rawset(_G, "SG_GetViewVars", function(v, p, c, allowspectator)
	local roll = p.viewrollangle
	
	if (p.spectator) and not allowspectator then
		return
	end
	
	if p.awayviewtics then
		local mo = p.awayviewmobj
		return mo.x, mo.y, mo.z, mo.angle, mo.pitch, roll
	elseif c.chase then
		return c.x, c.y, c.z + c.height/2, c.angle, c.aiming, roll
	/*
	elseif p.mo then
		return p.mo.x, p.mo.y, p.viewz, p.mo.angle, p.aiming, roll
	*/
	else
		return p.realmo.x, p.realmo.y, p.viewz, p.realmo.angle, p.aiming, roll
	end
end)

local fovvars
rawset(_G, "R_FOV", function(num)
	if not fovvars then
		fovvars = CV_FindVar("fov")
	end
	
	return fovvars.value
end)

// This version of the function was prototyped in Lua by Nev3r ... a HUGE thank you goes out to them!
-- if only it was exposed
local baseFov = 90*FRACUNIT
local BASEVIDWIDTH = 320
local BASEVIDHEIGHT = 200
rawset(_G, "SG_ObjectTracking", function(v, p, c, point, reverse, allowspectator)
	//local cameraNum = c.pnum - 1
	local viewx, viewy, viewz, viewangle, aimingangle, viewroll = SG_GetViewVars(v, p, c, allowspectator)

	// Initialize defaults
	local result = {
		x = 0,
		y = 0,
		scale = FRACUNIT,
		onScreen = false
	}

	// Take the view's properties as necessary.
	local viewpointAngle, viewpointAiming, viewpointRoll
	if reverse then
		viewpointAngle = viewangle + ANGLE_180
		viewpointAiming = InvAngle(aimingangle)
		if viewroll then
			viewpointRoll = viewroll
		end
	else
		viewpointAngle = viewangle
		viewpointAiming = aimingangle
		if viewroll then
			viewpointRoll = InvAngle(viewroll)
		end
	end

	// Calculate screen size adjustments.
	local screenWidth = v.width()/v.dupx()
	local screenHeight = v.height()/v.dupy()

	-- what's the difference between this and r_splitscreen?
	-- future G: seems to alternate between view count and view number depending on where you are in the codebase
	-- may i interest the Krew in stplyrnum? :^)
	if splitscreen then
		// Half-height screens (this isn't kart's splitscreen!)
		screenHeight = $ >> 1
	end

	local screenHalfW = (screenWidth >> 1) << FRACBITS
	local screenHalfH = (screenHeight >> 1) << FRACBITS

	// Calculate FOV adjustments.
	local fovDiff = R_FOV() - baseFov
	local fov = ((baseFov - fovDiff) / 2) - (p.fovadd / 2)
	local fovTangent = tan(FixedAngle(fov))

	if splitscreen == 1 then
		// Splitscreen FOV is adjusted to maintain expected vertical view
		fovTangent = 10*fovTangent/17
	end

	local fg = (screenWidth >> 1) * fovTangent

	// Determine viewpoint factors.
	
	local h = R_PointToDist2(point.x, point.y, viewx, viewy)
	local da = viewpointAngle - R_PointToAngle2(viewx, viewy, point.x, point.y)
	local dp = viewpointAiming - R_PointToAngle2(0, 0, h, viewz)

	if reverse then da = -da end

	// Set results relative to top left!
	result.x = FixedMul(tan(da), fg)
	result.y = FixedMul((tan(viewpointAiming) - FixedDiv((point.z - viewz), 1 + FixedMul(cos(da), h))), fg)

	result.angle = da
	result.pitch = dp
	result.fov = fg

	// Rotate for screen roll...
	if viewpointRoll then
		local tempx = result.x
		result.x = FixedMul(cos(viewpointRoll), tempx) - FixedMul(sin(viewpointRoll), result.y)
		result.y = FixedMul(sin(viewpointRoll), tempx) + FixedMul(cos(viewpointRoll), result.y)
	end

	// Flipped screen?
	if encoremode then result.x = -result.x end

	// Center results.
	result.x = $ + screenHalfW
	result.y = $ + screenHalfH

	result.scale = FixedDiv(screenHalfW, h+1)

	result.onScreen = not ((abs(da) > ANG60) or (abs(viewpointAiming - R_PointToAngle2(0, 0, h, (viewz - point.z))) > ANGLE_45))

	// Cheap dirty hacks for some split-screen related cases
	if result.x < 0 or result.x > (screenWidth << FRACBITS) then
		result.onScreen = false
	end

	if result.y < 0 or result.y > (screenHeight << FRACBITS) then
		result.onScreen = false
	end

	// adjust to non-green-resolution screen coordinates
	result.x = $ - ((v.width()/v.dupx()) - BASEVIDWIDTH)<<(FRACBITS-(splitscreen and 2 or 1))
	result.y = $ - ((v.height()/v.dupy()) - BASEVIDHEIGHT)<<(FRACBITS-(splitscreen and 2 or 1))
	return result
end)