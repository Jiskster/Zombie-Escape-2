freeslot("S_ZE2_RINGEXPLODE")

-- Optimized version of actions.
-- TODO: Remake items that use this and remove this action override.
function A_RingExplode2(actor, var1, var2)
    local vfx = P_SpawnMobj(actor.x, actor.y, actor.z, MT_THOK)
    vfx._override_tnt_explode = true
    vfx.state = S_TNTBARREL_EXPL1
    vfx.fuse = TICRATE
    actor.state = S_INVISIBLE

    S_StartSound(actor, sfx_prloop)
	P_StartQuake(64 * FU, 10, {x = vfx.x, y = vfx.y, z = vfx.z})

    local real_range = 256 * FU
    local bm_range = real_range * 4
    searchBlockmap("objects", function(refmobj, foundmobj)
		if not (foundmobj.flags & MF_SHOOTABLE) then return end
		if (foundmobj.team == actor.team) then return end

        local dist = R_PointToDist2(0, 0, R_PointToDist2(foundmobj.x, foundmobj.y, actor.x, actor.y), foundmobj.z - actor.z)
        if (dist > FixedMul(real_range, actor.scale)) then return end

        actor.flags2 = actor.flags2 | MF2_DEBRIS
        P_DamageMobj(foundmobj, actor, actor.target, 1, 0)
    end, actor, actor.x - bm_range, actor.x + bm_range, actor.y - bm_range, actor.y + bm_range)
end

function A_TNTExplode(actor, var1, var2)
    if not actor._override_tnt_explode then
        super(actor, var1, var2)
    end
end

states[S_ZE2_RINGEXPLODE] = {SPR_NULL, A, 1, A_RingExplode2, 0, 0, S_XPLD1, 0}

freeslot("S_XS_EXPLOSIONRING")

states[S_XS_EXPLOSIONRING] = { -- for drop only
	sprite = SPR_RNGE,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_EXPLOSIONRING,
}

local missile_explosion_ring = 
xSlinger.registerMissile("EXPLOSION_RING", {
	speed = 60*FRACUNIT,
	displayname = "Explosion Ring",
	state = S_THROWNEXPLOSION1,
	deathstate = S_ZE2_RINGEXPLODE,
	deathsound = sfx_pop,
	delflags = MF_NOGRAVITY,
})

xSlinger.registerItem("explosion_ring", {
	displayname = "Explosion Ring";

	missile = "EXPLOSION_RING";

	dropstate = S_XS_EXPLOSIONRING;

	icon = "XSG_BOMB";

	sounds = {
		use = sfx_cannon;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};
	
	firerate = (TICRATE*3)/2;

	ammo = 3;

	color = SKINCOLOR_BLACK;

	damage = 120;

	reload_time = 4*TICRATE;

	knockback = 65*FRACUNIT;
	knockback_tics = TICRATE;

	hold_object = {
		state = S_XS_EXPLOSIONRING;
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