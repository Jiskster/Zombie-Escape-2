freeslot("sfx_thoklw")

ZE2:CreateItem("Silver Spray",  {
	object = MT_THROWNAUTOMATIC,
	icon = "SILVERSPRAYIND",
	firerate = 2,
	color = SKINCOLOR_SILVER,
	damage = 2,
	knockback = 2*FRACUNIT,
	flags2 = MF2_AUTOMATIC,
	ammo = 10,
	autouse = true,
	reload_time = TICRATE,
	sound = sfx_thoklw,
})