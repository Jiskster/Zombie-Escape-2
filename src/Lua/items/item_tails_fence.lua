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
	flags = MF_SHOOTABLE|MF_SOLID|MF_PAPERCOLLISION,
}

mobjinfo[MT_PROPWOOD].npc_name = "Wood Fence"
mobjinfo[MT_PROPWOOD].npc_spawnhealth = {50,100}
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

SRBZ:CreateItem("Tails' fence", {
	icon = "FENCEIND",
	firerate = TICRATE*8,
	limited = true,
	count = 5,
	ontrigger = function(player)
		local wood = P_SpawnMobj(player.mo.x+FixedMul(128*FRACUNIT, cos(player.mo.angle)),
					             player.mo.y+FixedMul(128*FRACUNIT, sin(player.mo.angle)), 
								 player.mo.z, MT_PROPWOOD)
		wood.angle = player.mo.angle+ANGLE_90
		S_StartSound(player.mo, sfx_jshard)
		wood.renderflags = $|RF_PAPERSPRITE
		wood.mobjteam = player.zteam
		wood.flags = $|MF_SHOOTABLE|MF_SOLID|MF_PAPERCOLLISION -- Reapply flags to prevent desynch (for some reason)
		wood.target = player.mo
	end,
	price = 110,
})

addHook("MobjCollide", function(wood, tmo)
	if wood.mobjteam then
		if tmo.type == MT_PLAYER and tmo.player and tmo.player.valid then
			local player = tmo.player
			if wood.mobjteam == player.zteam then
				return false
			end
		else
			if wood.mobjteam == tmo.mobjteam then
				return false
			end
		end
	end
end, MT_PROPWOOD)