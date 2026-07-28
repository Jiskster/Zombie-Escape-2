freeslot("S_XS_BOUNCERING")

states[S_XS_BOUNCERING] = {
	sprite = SPR_RNGB,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 6,
	var2 = 2,
	nextstate = S_XS_BOUNCERING,
}

local bounce_tick = function(pmo, mo)
	local prevmomz = mo.bouncering_prevmomz or 0
	local floorhit = (mo.z <= mo.floorz)
	local ceilinghit = (mo.z + mo.height == mo.ceilingz)
	
	if floorhit or ceilinghit then
		local flip = P_MobjFlip(mo)
		
		if ceilinghit then flip = -$ end
		
		local newprevmomz = FixedDiv(abs(max(6*FU,prevmomz)), 5*FU/4)
		
		S_StartSound(mo, sfx_bnce1)
		P_SetObjectMomZ(mo, newprevmomz*flip, true)
		
		mo.momx = FixedDiv($, 5*FU/4)
		mo.momy = FixedDiv($, 5*FU/4)
		
		mo.flags = $ & (~MF_NOGRAVITY)
		mo.relativeknockback = true
		
		if abs(mo.momz) < 3*FRACUNIT and mo.fuse < 3*TICRATE then
			P_KillMobj(mo)
			return -- nuh uh
		end
	end
	
	mo.bouncering_prevmomz = mo.momz
end

local missile_bounce_ring = 
xSlinger.registerMissile("BOUNCE_RING", {
	speed = 50*FRACUNIT,
	displayname = "Bounce Ring",
	state = S_THROWNBOUNCE1,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
	nogravitydeath = true,
	safeground = true,
	radius = 32*FRACUNIT,
	height = 32*FRACUNIT,
	tick = bounce_tick,
	subtick = bounce_tick,
	blocked = function(pmo, mo, line)
		if not line then
			return end;
		
		local side = P_PointOnLineSide(mo.x, mo.y, line)
		local angle = R_PointToAngle2(line.v1.x, line.v1.y, line.v2.x, line.v2.y)
					  + (ANGLE_90 * (side and 1 or -1))
		local speed = FixedHypot(mo.momx, mo.momy)
		
		P_InstaThrust(mo, angle, speed)
		S_StartSound(mo, sfx_bnce1)
		
		mo.fuse = max(0, $ - 5)
		
		if not mo.fuse then
			P_KillMobj(mo)
			return
		end
		
		mo.flags = $ & (~MF_NOGRAVITY)
		mo.relativeknockback = true
		
		P_SetObjectMomZ(mo, 4*FU, true)
		
		return true
	end
})

xSlinger.registerItem("bounce_ring", {
	displayname = "Bounce Ring";

	icon = "XSG_BNCE";

	missile = "BOUNCE_RING";

	dropstate = S_XS_BOUNCERING;

	sounds = {
		use = sfx_bnce1;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	color = SKINCOLOR_YELLOW;

	damage = 13;

	knockback = 25*FRACUNIT; -- fixed_t
	knockback_time = 2*TICRATE;

	autouse = true;

	ammo = 24;

	reload_time = 3*TICRATE;
	firerate = 4;

	flags2 = 0; -- MF2_...
	
	fuse = 5*TICRATE,

	hold_object = {
		state = S_XS_BOUNCERING;
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
	};

    hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE;
})