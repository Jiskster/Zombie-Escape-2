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
	radius = 88*FRACUNIT,
	height = 96*FRACUNIT,
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

addHook("MobjMoveCollide", function(instaburst, mobj)
	if (mobj.valid and (mobj.flags & MF_SHOOTABLE) or mobj.player) and instaburst.ib_hitlist then
		local range = instaburst.radius
		local alreadyhit = false
		
		if not ZE2.ZCollide(mobj, instaburst) then 
			return
		end
		
		if instaburst.target == mobj then
			return
		end

		-- Just pretend we can see the fences
		local cansee = mobj.type == MT_PROPWOOD and true or P_CheckSight(mobj, instaburst)
		if not cansee then return end

		-- Check if you hit this individual before in another frame
		for i,v in ipairs(instaburst.ib_hitlist) do
			if v and v.valid and v == mobj then
				alreadyhit = true
			end
		end

		local dist = R_PointToDist2(mobj.x, mobj.y, instaburst.x, instaburst.y)

		if ((mobj.type == MT_PROPWOOD and dist <= 200*FU) --only extend the range for fences
		or dist < range) and not alreadyhit then
			P_DamageMobj(mobj, instaburst, instaburst.target, instaburst.forcedamage)
			table.insert(instaburst.ib_hitlist, mobj)
		end
	end
end, MT_INSTABURST)

xSlinger.registerItem("insta_burst", {
	displayname = "Insta Burst";
	
	icon = "ZMISHIND";
	
	firerate = 34;
	
	sounds = {
		use = {sfx_zish1, sfx_zish2, sfx_zish3};
		hurt = {sfx_zbatk1, sfx_zbatk2, sfx_zbatk3};
	};
	
	damage = 40;
	
	color = SKINCOLOR_RED;
	
	usefunc = function(self, mo)
		local instaburst = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_INSTABURST)
		
		instaburst.target = mo
		instaburst.spritexscale = $*2
		instaburst.spriteyscale = $*2
		instaburst.team = mo.team
		instaburst.forcedamage = self.damage
		instaburst.iteminfo = self
		instaburst.ib_hitlist = {}
	end;
	
	droppable = false;
})