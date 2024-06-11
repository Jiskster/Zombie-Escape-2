ZE2:CreateItem("Red Ring",  {
	object = MT_REDRING,
	icon = "RINGIND",
	firerate = 9,
	color = SKINCOLOR_RED,
	knockback = 45*FRACUNIT,
	damage = 15,
	onspawn = function(pmo, mo)
		local mult = (2*FU)
		
		mo.momx = FixedMul($,mult)
		mo.momy = FixedMul($,mult)
		mo.momz = FixedMul($,mult)
	end,
})