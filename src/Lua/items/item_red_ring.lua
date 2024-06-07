ZE2:CreateItem("Red Ring",  {
	object = MT_REDRING,
	icon = "RINGIND",
	firerate = 17,
	color = SKINCOLOR_RED,
	knockback = 55*FRACUNIT,
	damage = 17,
	onspawn = function(pmo, mo)
		local mult = (4*FU)/2 
		mo.momx = FixedMul($,mult)
		mo.momy = FixedMul($,mult)
		mo.momz = FixedMul($,mult)
	end,
})