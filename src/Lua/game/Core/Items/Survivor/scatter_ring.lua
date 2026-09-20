freeslot("S_XS_SCATTERRING")

freeslot("sfx_shgn")

sfxinfo[sfx_shgn].caption = "Shotgun fires"

states[S_XS_SCATTERRING] = {
	sprite = SPR_RNGS,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_SCATTERRING,
}

freeslot("S_XS_SCATTERRING_DROP")

states[S_XS_SCATTERRING_DROP] = {
	sprite = SPR_RNGS,
	frame = FF_ANIMATE|FF_FULLBRIGHT,
	tics = -1,
	var1 = 34,
	var2 = 1,
	nextstate = S_XS_SCATTERRING_DROP,
}

local missile_scatter_ring = 
xSlinger.registerMissile("SCATTER_RING", {
	speed = 72*FRACUNIT,
	displayname = "Scatter Ring",
	state = S_XS_SCATTERRING,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
	height = 32*FRACUNIT,
}) -- height 32

xSlinger.registerItem("scatter_ring", {
	displayname = "Scatter Ring";

	icon = "XSG_SCAT";

	dropstate = S_XS_SCATTERRING_DROP;

	color = SKINCOLOR_PURPLE;

	damage = 20;

	velocity_multiplier = 2*FRACUNIT;

	spread = 4;

	knockback = 30*FRACUNIT;
	knockback_tics = 17;

	fuse = TICRATE/4;

	ammo = 5;
	reload_time = 4*TICRATE;

	autouse = false;

	firerate = 18;

	flags2 = 0; -- MF2_...
	
	push_multi = FU; -- scatter ring exclusive

	hold_object = {
		state = S_XS_SCATTERRING;
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

    animation_time = TICRATE*2;

	sounds = {
		use = sfx_shgn;
		reload = {sfx_xsrel1, sfx_xsrel2};
		pickup = sfx_None;
		drop = sfx_None;
	};

	skin_override = {
		["sonic"] = {
			firerate = 13;
			push_multi = (FU*3/4);
			reload_time = 3*TICRATE;
		}
	};
	
	usefunc = function(self, mo)
		local mt = "SCATTER_RING"
		local spread = self.spread
		local player = mo.player
		local push_multi = self:getIndex("push_multi", mo.skin)

		-- Horizontal
		for i = -1, 1 do
			local shot = xSlinger.SpawnMissile({
				source = mo,
				type = mt,
				angle = mo.angle + i * ANG1*spread,
				allow_aim = true,
				iteminfo = self,
			})

			if shot and shot.valid then
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end

		-- Vertical
		for i = -1, 1, 2 do
			local prevaim = player.aiming

			player.aiming = $ + i * ANG1*spread
			local shot = xSlinger.SpawnMissile({
				source = mo,
				type = mt,
				angle = mo.angle,
				allow_aim = true,
				iteminfo = self,
			})
			player.aiming = prevaim
			if shot and shot.valid then
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end

		local knockback_horizontal = 4 * FRACUNIT
		local knockback_vertical = max(-FRACUNIT, min(FRACUNIT, -player.aiming / 13000))
		if ((P_MobjFlip(mo) * knockback_vertical) > 0) then
			knockback_vertical = (knockback_vertical * 3)
		end

		if (mo.eflags & MFE_UNDERWATER) then -- underwater knockback penalty
			knockback_horizontal = knockback_horizontal / 3
			knockback_vertical = knockback_vertical / 3
		end
		
		if push_multi then
			knockback_horizontal = FixedMul($, push_multi)
			knockback_vertical = FixedMul($, push_multi)
		end

		mo.momz = mo.momz + FixedMul(mo.scale, knockback_vertical)
		P_Thrust(mo, mo.angle, -knockback_horizontal)

		if player and player.valid then
			P_MovePlayer(player)
		end
	end
})