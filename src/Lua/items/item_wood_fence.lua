freeslot("MT_PROPWOOD","S_PROP1","S_PROP1_BREAK","SPR_WPRP")

mobjinfo[MT_PROPWOOD] = {
    sprite = SPR_WPRP,
	spawnstate = S_PROP1,
	painstate = S_PROP1,
	painsound = sfx_dmpain,
	deathstate = S_PROP1_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 50,
	speed = 0,
	radius = 96*FRACUNIT,
	height = 138*FRACUNIT,
	flags = MF_SHOOTABLE|MF_SOLID,
}

mobjinfo[MT_PROPWOOD].npc_name = "Wood Fence"
mobjinfo[MT_PROPWOOD].npc_spawnhealth = {300,600}
mobjinfo[MT_PROPWOOD].npc_name_color = SKINCOLOR_BROWN

states[S_PROP1] = {
	nextstate = S_PROP1,
	sprite = SPR_WPRP,
	frame = FF_FULLBRIGHT,
	tics = 2
}

states[S_PROP1_BREAK] = {
	nextstate = S_NULL,
	sprite = SPR_WPRP,
	action = A_Scream,
	frame = B,
	tics = 4
}

local wood_fence = ZE2:CreateItem("Wood Fence", {
	icon = "FENCEIND",
	firerate = TICRATE*5,
	limited = true,
	count = 2,
	max_count = 100,
	color = SKINCOLOR_BROWN,
	ontrigger = function(player)
		local wood = P_SpawnMobj(player.mo.x+FixedMul(128*FRACUNIT, cos(player.mo.angle)),
					             player.mo.y+FixedMul(128*FRACUNIT, sin(player.mo.angle)), 
								 player.mo.z, MT_PROPWOOD)
		wood.angle = player.mo.angle+ANGLE_90
		S_StartSound(player.mo, sfx_jshard)
		wood.renderflags = $|RF_PAPERSPRITE
		wood.mobjteam = player["ze2_info"].team
		wood.target = player.mo
	end,
	skin_overwrite = {
		["tails"] = {
			firerate = TICRATE*3,
		}
	},
	price = 70,
})

addHook("MobjCollide", function(wood, tmo)
	if wood.mobjteam then
		if tmo.type == MT_PLAYER and tmo.player and tmo.player.valid then
			local player = tmo.player
			if wood.mobjteam == player["ze2_info"].team then
				return false
			end
		else
			if wood.mobjteam == tmo.mobjteam then
				return false
			end
		end
	end
end, MT_PROPWOOD)

ZE2:RegisterShop_ItemID(wood_fence)