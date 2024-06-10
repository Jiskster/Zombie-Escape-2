-- Ported From RSNEO

ZE2:CreateItem("Scatra",  {
	icon = "SCATRAIND",
	firerate = 25,
	sound = sfx_shgn,
	knockback = 5*FRACUNIT,
	damage = 10,
	fuse = 6,
	color = SKINCOLOR_DUSK,
	price = 250,
	ammo = 10,
	reload_time = 5*TICRATE,
	ontrigger = function(player)
		local mt = MT_ZE2_THROWNSCATTER
		local mo = player.mo
		local spread = 3
		--S_StartSound(mo, sfx_shgn)
		for i = -1, 1
			local shot = P_SPMAngle(mo, mt, mo.angle + i * ANG1*spread, 1, 0)
			if shot and shot.valid
				shot.color = ZE2:FetchInventorySlot(player).color
				shot.fuse = ZE2:FetchInventorySlot(player).fuse
				shot.forcedamage = ZE2:FetchInventorySlot(player).damage
				shot.forceknockback = ZE2:FetchInventorySlot(player).knockback
				shot.colorized = true
				
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		for i = -1, 1, 2
			local prevaim = player.aiming
			player.aiming = $ + i * ANG1*spread
			local shot = P_SPMAngle(mo, mt, mo.angle, 1, 0)
			player.aiming = prevaim
			if shot and shot.valid
				shot.color = ZE2:FetchInventorySlot(player).color
				shot.fuse = ZE2:FetchInventorySlot(player).fuse
				shot.forcedamage = ZE2:FetchInventorySlot(player).damage
				shot.forceknockback = ZE2:FetchInventorySlot(player).knockback
				shot.colorized =  true
				
				shot.momx = $ + mo.momx / 3
				shot.momy = $ + mo.momy / 3
				shot.momz = $ + mo.momz / 3
			end
		end
		if not P_IsObjectOnGround(mo)
			local aim = max(-FRACUNIT, min(FRACUNIT, -player.aiming/13000))
			if P_MobjFlip(mo) * aim > 0
				aim = ($ * 2)>>3
			end
			mo.momz = $ + FixedMul(mo.scale, aim)
			P_Thrust(mo, mo.angle, -FRACUNIT*9)
		end
	end
})