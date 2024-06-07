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
	radius = 72*FRACUNIT,
	height = 16*FRACUNIT,
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
	firerate = 24,
	sound = sfx_zish1,
	damage = 20,
	ontrigger = function(player)
		local brange = 512*FU
		local range = 185*FU
		local instaburst = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, MT_INSTABURST)
		
		instaburst.target = player.mo
		instaburst.spritexscale = $*2
		instaburst.spriteyscale = $*2
		instaburst.scale = $*3/2
		instaburst.forcedamage = ZE2:FetchInventorySlot(player).damage
		
		searchBlockmap("objects", function(refmobj,foundmobj)
			if not L_ZCollide(foundmobj,instaburst) then 
				return false
			end
			
			if (foundmobj.valid and ((foundmobj.flags & (MF_SHOOTABLE)) or foundmobj.player)) then
				if R_PointToDist2(foundmobj.x, foundmobj.y, instaburst.x, instaburst.y) < range then
					P_DamageMobj(foundmobj, instaburst, instaburst.target, instaburst.forcedamage)
				end
			end
		end, 
		instaburst, 
		instaburst.x-brange,instaburst.x+brange,
		instaburst.y-brange,instaburst.y+brange)
	end,
})