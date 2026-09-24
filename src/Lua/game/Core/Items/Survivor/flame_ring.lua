-- RS NEO port.

freeslot(
	"MT_ZE2_THROWNFLAME",
	"S_ZE2_THROWNFLAME1",
	"S_ZE2_THROWNFLAME2",
	"S_ZE2_THROWNFLAME3",
	"sfx_rs_fla"
	-- SPR_RNGF already freeslotted
)
sfxinfo[sfx_rs_fla].caption = "Flamethrower"

states[S_ZE2_THROWNFLAME1] = {
	nextstate = S_ZE2_THROWNFLAME2,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS50|1,
	tics = 10
}
states[S_ZE2_THROWNFLAME2] = {
	nextstate = S_ZE2_THROWNFLAME3,
	sprite = SPR_RNGF,
	frame = FF_FULLBRIGHT|FF_TRANS40|2,
	tics = 10
}
states[S_ZE2_THROWNFLAME3] = {
	frame = FF_FULLBRIGHT|FF_TRANS30|3,
	tics = 20
}

freeslot("S_ZE2_FLAMERING_DROP", "SPR_ZE2_FLAMERING")

states[S_ZE2_FLAMERING_DROP] = {
	sprite = SPR_ZE2_FLAMERING,
	frame = FF_FULLBRIGHT,
	tics = -1,
	nextstate = S_ZE2_FLAMERING_DROP,
}

sfxinfo[sfx_rs_fla] = {
	flags = SF_NOMULTIPLESOUND
}

local missile_flame_ring =
xSlinger.registerMissile("FLAME_RING", {
	speed = 100*FRACUNIT,
	displayname = "Flame Ring",
	state = S_ZE2_THROWNFLAME1,
	deathstate = S_SPRK1,
	deathsound = sfx_s3k7e,
	addflags = MF_SLIDEME,
	radius = 24*FRACUNIT,
	tick = function(self, pmo, mobj)
		mobj.momx = $ * 85/100
		mobj.momy = $ * 85/100
		mobj.momz = $ * 85/100
		P_SetObjectMomZ(mobj, FRACUNIT/5, true)
	end
})

xSlinger.registerItem("flame_ring", {
	displayname = "Flame Ring";

	icon = "FLAMIND";

	firerate = 2;

	color = SKINCOLOR_ORANGE;

	dropstate = S_ZE2_FLAMERING_DROP;
	dropscale = FU;

	autouse = true;

	damage = 2;

	knockback = 1*FRACUNIT;

	flags2 = MF2_AUTOMATIC;

	hold_object = {
		state = S_ZE2_FLAMERING_DROP;
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
			x = FU;
			y = FU;
		}
	};

	hold_icon = "SPR_THOK"; -- Can be a normal graphic instead of a sprite too.

    animation_time = TICRATE/10;

	ammo = 50;

	reload_time = TICRATE*4;

	usefunc = function(self, mo)
		local player = mo.player
		local pmo = player.mo

		local mt = "FLAME_RING"
		local wave = sin(leveltime*ANG10) * 600
		local shot = xSlinger.SpawnMissile({
			source = mo,
			type = mt,
			angle = mo.angle + wave,
			allow_aim = true,
			iteminfo = self,
		})

		-- Only play sound if missile is real.
		if shot and shot.valid then
			S_StartSound(shot, sfx_rs_fla)
		end

		if not P_IsObjectOnGround(mo) then
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(mo) * aim > 0 then
				aim = $ * 2/8
			end
			mo.momz = $ + FixedMul(mo.scale, aim)
			P_Thrust(mo, mo.angle, -FRACUNIT*2/3)
		end
	end;
	hitfunc = function(self, src, mo, inf)
		if not mo and not mo.valid then return end
		mo:give_effect("burning", {
			normalspeed_multiplier = FU/2,
			actionspd_multiplier = 3*FU/2,
			damage_multiplier = FU/2,
		}, 9, true)

		mo.flameringtarget = src
	end;
})