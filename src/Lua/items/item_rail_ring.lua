local raildmg = 60
local railkb = 160*FRACUNIT

freeslot("MT_SRBZ_RAILSHOT")

mobjinfo[MT_SRBZ_RAILSHOT] = {
	spawnstate = S_RRNG1,
	deathstate = S_SPRK1,
	deathsound = sfx_rs_die,
	speed = 128*FRACUNIT,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY,
}

local ring = function(x,y,z,scale,angle)
	local th = P_SpawnMobj(x, y, z, MT_THOK)
	if th and th.valid
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
	
local function trigger_func(player, iteminfo)
	local mo = player.mo
	mo.momx = $ / 3
	mo.momy = $ / 3
	P_SetObjectMomZ(mo, 2*FRACUNIT, false)
	mo.state = S_PLAY_SPRING
	mo.player.pflags = $ & ~(PF_JUMPED | PF_SPINNING)
	S_StartSound(mo, sfx_rail1)
	local rail = P_SPMAngle(mo, MT_SRBZ_RAILSHOT, mo.angle, 1, MF2_DONTDRAW)
	
	if rail and rail.valid then
		rail.forcedamage = SRBZ:FetchInventorySlot(player).damage
		rail.forceknockback = SRBZ:FetchInventorySlot(player).knockback
		rail.iteminfo = iteminfo
		
		local range = 16
		
		for i = 0, range do
			if i % 2 == 0 then
				local spark = P_SpawnMobj(rail.x, rail.y, rail.z, MT_SPARK)
				
				if spark and spark.valid then
					if i % 3 == 0 then
						spark.color = player.skincolor
						spark.colorized = true
					else
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
			end
			
			if (not rail.valid) or (xx == rail.x and y == rail.y and z == rail.z) then
				break
			end
		end

		if rail and rail.valid then
			ring(rail.x,rail.y,rail.z,rail.scale,rail.angle)
			P_KillMobj(rail)
		end
	end
end

SRBZ:CreateItem("Rail Ring", {
	shake = 20,
	icon = "RAILIND",
	firerate = 5,
	knockback = railkb,
	damage = raildmg,
	price = 1460,
	ammo = 2,
	reload_time = 7*TICRATE,
	ontrigger = trigger_func,
})