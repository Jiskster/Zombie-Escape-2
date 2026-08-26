-- RS NEO port.

local raildmg = 950
local railkb = 350*FRACUNIT

freeslot("S_XS_RAILRING_DROP")

states[S_XS_RAILRING_DROP] = {
	sprite = SPR_RNGR,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_RAILRING_DROP,
}

local ring = function(x,y,z,scale,angle)
	local th = P_SpawnMobj(x, y, z, MT_THOK)
	if th and th.valid then
		th.angle = angle + ANGLE_90
		th.spriteyoffset = -20*FRACUNIT
		th.sprite = SPR_STAB
		th.frame = FF_PAPERSPRITE|TR_TRANS80
		th.color = SKINCOLOR_WHITE
		th.blendmode = AST_ADD
		th.colorized = true
		th.scale = scale
		th.destscale = th.scale*6
		th.scalespeed = $ * 2
		th.tics = 6
	end
end

local missile_rail_ring =
xSlinger.registerMissile("RAIL_RING", {
	speed = 128*FRACUNIT,
	displayname = "Rail Ring",
	state = S_INVISIBLE,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
})

local function trigger_func(self, mo)
	mo.momx = $ / 3
	mo.momy = $ / 3
	P_SetObjectMomZ(mo, 2*FRACUNIT, false)
	mo.state = S_PLAY_SPRING

	if mo.player and mo.player.valid then
		mo.player.pflags = $ & ~(PF_JUMPED | PF_SPINNING)
	end

	local rail = xSlinger.SpawnMissile({
		source = mo,
		type = "RAIL_RING",
		angle = mo.angle,
		allow_aim = true,
		iteminfo = self,
		flags2 = MF2_DONTDRAW,
	})

	if rail and rail.valid then
		local range = 16
		local x, y, z = rail.x, rail.y, rail.x
		for i = 0, range do
			if i % 2 == 0 then
				local spark = P_SpawnMobj(rail.x, rail.y, rail.z, MT_SPARK)

				if spark and spark.valid then
					if not (i % 3 == 0) then
						spark.scale = $ * 3/4
					end

					if (i - 2) % 10 == 0 then
						ring(rail.x,rail.y,rail.z,rail.scale/2,rail.angle)
					end
				end
			end

			if rail.momx or rail.momy then
				P_XYMovement(rail)
				if not rail.valid then
					break
				end
			end

			if rail.momz then
				P_ZMovement(rail)
				if not rail.valid then
					break
				end

				if (rail.z == rail.floorz or rail.z + rail.height == rail.ceilingz) then
					P_KillMobj(rail)
					break
				end
			end

			if (not rail.valid) or (x == rail.x and y == rail.y and z == rail.z) then
				break
			end
		end

		if rail and rail.valid then
			ring(rail.x,rail.y,rail.z,rail.scale,rail.angle)
			P_KillMobj(rail)
		end
	end
end

xSlinger.registerItem("rail_ring", {
	displayname = "Rail Ring";

	shake = 20;

	icon = "XSG_RAIL";

	dropstate = S_XS_RAILRING_DROP;

	sounds = {
		use = sfx_rail1;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	firerate = 5;

	knockback = 350*FRACUNIT;

	damage = 500;

	ammo = 1;

	color = SKINCOLOR_AZURE;

	reload_time = 7*TICRATE;

	usefunc = trigger_func;

	skin_override = {
		["fang"] = {
			reload_time = 3*TICRATE,
		}
	};

	hold_object = {
		state = S_XS_RAILRING_DROP;
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