freeslot("S_XS_GRENADERING")
freeslot("S_XS_GRENADERING_DROP")

states[S_XS_GRENADERING] = {
	sprite = SPR_TGRE,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 17,
	var2 = 1,
	nextstate = S_XS_GRENADERING_DROP,
}

states[S_XS_GRENADERING_DROP] = {
	sprite = SPR_RNGG,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_GRENADERING_DROP,
}

local missile_grenade_ring =
xSlinger.registerMissile("GRENADE_RING", {
	speed = 40*FRACUNIT,
	displayname = "Grenade Ring",
	state = S_XS_GRENADERING,
	deathstate = S_ZE2_RINGEXPLODE,
	deathsound = sfx_pop,
	delflags = MF_NOGRAVITY,
	safeground = true,
	tick = function(self, pmo, mo)
		local prevmomz = mo.grenade_prevmomz or 0
		local floorhit = (mo.eflags & MFE_JUSTHITFLOOR) > 0
		local ceilinghit = (mo.z + mo.height == P_CeilingzAtPos(mo.x, mo.y, mo.z, mo.height))

		if floorhit or ceilinghit then
			local flip = P_MobjFlip(mo)

			if ceilinghit then flip = -$ end

			local newprevmomz = FixedDiv(abs(prevmomz), 6*FU/4)

			S_StartSound(mo, sfx_s3k5d)
			P_SetObjectMomZ(mo, newprevmomz*flip, true)

			mo.momx = FixedDiv($, 6*FU/4)
			mo.momy = FixedDiv($, 6*FU/4)

			if abs(mo.momz) < FRACUNIT then
				mo.momx = 0; mo.momy = 0; mo.momz = 0
			end
		end

		local faststart = 15

		if mo.fuse > faststart then
			if (mo.fuse % 12) == 0 then
				S_StartSound(mo, sfx_gbeep)

				local ghost = P_SpawnGhostMobj(mo)
				ghost.fuse = 8
				ghost.color = SKINCOLOR_GREEN
				ghost.colorized = true
			end
		else
			if (mo.fuse % 3) == 0 then
				S_StartSound(mo, sfx_gbeep)
				S_StartSoundAtVolume(mo, sfx_deton, min(10 + (faststart - mo.fuse)*27, 255))

				local ghost = P_SpawnGhostMobj(mo)
				ghost.fuse = 3
				ghost.color = SKINCOLOR_RED
				ghost.colorized = true
			end
		end

		mo.grenade_prevmomz = mo.momz
	end,
	blocked = function(self, pmo, mo, line)
		if not line then
			return end;

		local side = P_PointOnLineSide(mo.x, mo.y, line)
		local angle = R_PointToAngle2(line.v1.x, line.v1.y, line.v2.x, line.v2.y)
					  + (ANGLE_90 * (side and 1 or -1))
		local speed = FixedHypot(mo.momx, mo.momy)

		P_InstaThrust(mo, angle, speed)
		S_StartSound(mo, sfx_s3k5d)

		return true
	end
})

xSlinger.registerItem("grenade_ring",  {
	displayname = "Grenade";

	missile = "GRENADE_RING";

	dropstate = S_XS_GRENADERING_DROP;

	icon = "GRENIND";

	sounds = {
		use = sfx_s3k5d;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	firerate = 15;

	color = SKINCOLOR_GREEN;

	knockback = 75*FRACUNIT;

	damage = 70;

	count = 1;
	maxcount = 10;

	fuse = 2*TICRATE;

	hold_object = {
		state = S_XS_GRENADERING;
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