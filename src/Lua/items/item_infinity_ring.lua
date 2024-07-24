local infinity_ring = ZE2:CreateItem("Infinity Ring",	{
	object = MT_THROWNINFINITY,
	icon = "INFNIND",
	firerate = 5,
	color = SKINCOLOR_SALMON,
	knockback = 8*FRACUNIT,
	damage = 40,
	price = 115,
	autouse = true,
	thinker = function(pmo, mo)
		if mo.framethati_usedinfinity then
			local angleoffset = mo.angle + ANGLE_90
			P_Thrust(mo, angleoffset, sin(FixedAngle(leveltime+mo.framethati_usedinfinity*FU*8)))
		end
	end,
	onspawn = function(pmo, mo)
		mo.framethati_usedinfinity = leveltime
		
		pmo.momx = $ / 2
		pmo.momy = $ / 2
		--pmo.momz = $ / 2	
	end
})

ZE2:RegisterShop_ItemID(infinity_ring)