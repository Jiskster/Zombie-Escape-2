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

addHook("MobjMoveCollide", function(tmthing, thing)
	if thing == tmthing.target then return false end
	
	if thing.player and thing.player.valid then
		tmthing.fuse = max(0, $ - 10)
		P_DamageMobj(thing, tmthing, tmthing.target, tmthing.iteminfo.damage, 0)
	end
	return true
end, MT_THROWNBOUNCE)


ZE2:RegisterShop_ItemID(bounce_ring)

