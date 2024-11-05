freeslot(
	"MT_INSTABURST",
	"S_INSTABURST",
	"S_INSTABURST1A",
	"S_INSTABURST1B",
	"S_INSTABURST2A",
	"S_INSTABURST2B",
	"S_INSTABURST3A",
	"S_INSTABURST3B",
	"S_INSTABURST4A",
	"S_INSTABURST4B",
	"S_INSTABURST5A",
	"S_INSTABURST5B",
	"S_INSTABURST6A",
	"S_INSTABURST6B",
	"SPR_ZMSH"
)

mobjinfo[MT_INSTABURST] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_INSTABURST,
	radius = 128*FRACUNIT,
	height = 128*FRACUNIT,
	flags = MF_NOGRAVITY|MF_NOBLOCKMAP
}

states[S_INSTABURST] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST1A}
states[S_INSTABURST1A] = {SPR_ZMSH, 0|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST1B}
states[S_INSTABURST1B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST2A}
states[S_INSTABURST2A] = {SPR_ZMSH, 1|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST2B}
states[S_INSTABURST2B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST3A}
states[S_INSTABURST3A] = {SPR_ZMSH, 2|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST3B}
states[S_INSTABURST3B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST4A}
states[S_INSTABURST4A] = {SPR_ZMSH, 3|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST4B}
states[S_INSTABURST4B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST5A}
states[S_INSTABURST5A] = {SPR_ZMSH, 4|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST5B}
states[S_INSTABURST5B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_INSTABURST6A}
states[S_INSTABURST6A] = {SPR_ZMSH, 5|FF_FULLBRIGHT, 1, A_CapeChase, 0, 0, S_INSTABURST6B}
states[S_INSTABURST6B] = {SPR_NULL, 0, 1, A_CapeChase, 0, 0, S_NULL}

ZE2:CreateItem("Insta Burst", {
	icon = "ZMISHIND",
	firerate = 20,
	sound = sfx_zish1,
	damage = 100,
	color = SKINCOLOR_RED,
	ontrigger = function(player)
		local instaburst = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_INSTABURST)
		
		instaburst.target = player.mo
		instaburst.spritexscale = $*2
		instaburst.spriteyscale = $*2
		instaburst.mobjteam = player["ze2_info"].team
		instaburst.forcedamage = ZE2:FetchInventorySlot(player).damage
		instaburst.ib_hitlist = {}
	end,
})

addHook("MobjMoveCollide", function(instaburst, mobj)
	if (mobj.valid and (mobj.flags & MF_SHOOTABLE) or mobj.player) and instaburst.ib_hitlist then
		local range = 190*FU
		local alreadyhit = false
		
		if not ZE2.ZCollide(mobj, instaburst) then 
			return
		end
		
		-- Check if you hit this individual before in another frame
		for i,v in ipairs(instaburst.ib_hitlist) do
			if v and v.valid and v == mobj then
				alreadyhit = true
			end
		end
		
		if R_PointToDist2(mobj.x, mobj.y, instaburst.x, instaburst.y) < range and not alreadyhit then
			P_DamageMobj(mobj, instaburst, instaburst.target, instaburst.forcedamage)
			table.insert(instaburst.ib_hitlist, mobj)
		end
	end
end, MT_INSTABURST)