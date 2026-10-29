freeslot(
	"MT_INSTABURST",
	"S_INSTABURST",
	"SPR_ZMSH"
)

mobjinfo[MT_INSTABURST] = {
	doomednum = -1,
	spawnhealth = 1,
	spawnstate = S_INSTABURST,
	radius = 88*FRACUNIT,
	height = 96*FRACUNIT,
	flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT,
	dispoffset = 3,
}

states[S_INSTABURST] = {
	sprite = SPR_ZMSH,
	frame = A|FF_FULLBRIGHT|FF_ANIMATE,
	tics = 17,
	var1 = 6,
	var2 = 1,
}

local function increaseRage(player, change)
	player.ze2.special_cooldown = player.ze2.special_cooldown - change

	if (player.ze2.special_cooldown < 0) then
		player.ze2.special_cooldown = 0
	end
end

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
			xSlinger.ShouldDamage(mobj, instaburst, instaburst.target, instaburst.forcedamage)
			table.insert(instaburst.ib_hitlist, mobj)

			if instaburst.target and instaburst.target.valid
			and instaburst.target.player and instaburst.target.player.valid 
			and instaburst.team ~= mobj then
				increaseRage(instaburst.target.player, 15*TICRATE)
			end
		end
	end
end, MT_INSTABURST)

addHook("MobjThinker", function(instaburst)
	local t = instaburst.target
	
	if t and t.valid then
		P_MoveOrigin(instaburst, t.x, t.y, t.z)
		
		if not (leveltime % 2) then
			local ghost = P_SpawnGhostMobj(t)
			ghost.type = MT_OVERLAY
			ghost.tics = 2
			ghost.fuse = 2
			ghost.blendmode = AST_SUBTRACT
			ghost.dispoffset = 2
			ghost.alpha = FU - FixedDiv(instaburst.tics, states[S_INSTABURST].tics)
		end
	end
	
	instaburst.blendmode = AST_SUBTRACT
	instaburst.alpha = $ - ($/32)
	instaburst.spritexscale = $ - ($/48)
	instaburst.spriteyscale = $ - ($/48)

	local ghost = P_SpawnGhostMobj(instaburst)
	ghost.fuse = 7
	ghost.blendmode = AST_TRANSLUCENT
	ghost.alpha = $ - ($/4)
	ghost.rollangle = P_RandomRange(0,360)*ANG1
	ghost.momx = instaburst.momx
	ghost.momy = instaburst.momy
	ghost.momz = instaburst.momz
end, MT_INSTABURST)

xSlinger.registerItem("insta_burst", {

	-- HUD
	
	displayname = "Insta Burst",
	icon = "ZMISHIND",
	color = SKINCOLOR_RED,
	
	-- Item properties

	delay = TICRATE + 5,
	damage = 40,
	droppable = false,
	sounds = {
		use = {sfx_zish1, sfx_zish2, sfx_zish3},
		hurt = {sfx_zbatk1, sfx_zbatk2, sfx_zbatk3},
	},
	usefunc = function(self, mo)
		local instaburst = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_INSTABURST)

		instaburst.target = mo
		instaburst.spritexscale = ($*2)
		instaburst.spriteyscale = ($*2)
		instaburst.team = mo.team
		instaburst.forcedamage = self.damage
		instaburst.iteminfo = self
		instaburst.ib_hitlist = {}
	end,
})