local blue_spring = ZE2:CreateItem("blue_spring",  {
	displayname = "Blue Spring",
	icon = "BLUESPRINGIND",
	firerate = 4*TICRATE,
	limited = true,
	count = 10,
	max_count = 50,
	color = SKINCOLOR_BLUE,
	ontrigger = function(player)
		local spring = P_SpawnMobj(player.mo.x+FixedMul(128*FRACUNIT, cos(player.mo.angle)),
					             player.mo.y+FixedMul(128*FRACUNIT, sin(player.mo.angle)), 
								 player.mo.z, MT_BLUESPRING)
		spring.angle = player.mo.angle+ANGLE_90
		S_StartSound(player.mo, sfx_jshard)
		spring.target = player.mo
		if (spring.ceilingz - spring.floorz < (spring.height*5))
			spring.fuse = 3 -- Kills crouch parts spring softlocking
		else
			spring.fuse = 5*TICRATE
		end
	end,
	price = 350,
})

ZE2:RegisterShop_ItemID(blue_spring)