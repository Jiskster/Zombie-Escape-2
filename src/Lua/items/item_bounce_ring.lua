mobjinfo[MT_THROWNBOUNCE].relativeknockback = true

local bounce_ring = ZE2:CreateItem("bounce_ring",  {
	displayname = "Bounce Ring",
	object = MT_THROWNBOUNCE,
	icon = "BNCEIND",
	sound = sfx_bnce1,
	firerate = 1,
	color = SKINCOLOR_YELLOW,
	autouse = false,
	damage = 15,
	fuse = 4*TICRATE,
	velocity_multiplier = 3*FU/2,
	--velocity_precision = 4,
	knockback = 12*FRACUNIT,
	flags2 = MF2_BOUNCERING,
	ammo = 50,
	reload_time = TICRATE*6,
	price = 650,
})

-- tm is the bouncering, t is the collidee
addHook("MobjMoveCollide", function(tm, t)
	if not (tm and tm.valid) then return end
	if not (t and t.valid) then return end
	if not (t.player and t.player.valid) then return end

	if (t == tm.tracer)
	or (t.player.ze2.team == tm.mobjteam)
		return false
	end

	tm.fuse = max(0, $ - 10)
	P_DamageMobj(t, tm, tm.target, tm.iteminfo.damage, 0)
	
	return true
end, MT_THROWNBOUNCE)

ZE2:RegisterShop_ItemID(bounce_ring)

