local TR = TICRATE

freeslot("MT_DOOMEDCORP_SPARK",
	"S_DOOMEDCORP_WAIT",
	"S_DOOMEDCORP_SPARK",
	"SPR_DCSP"
)

mobjinfo[MT_DOOMEDCORP_SPARK] = {
	--$Name Spark Spawner
	--$Sprite DCSPARAL
	--$Category Doomed Corp
	doomednum = 5440,
	spawnstate = S_DOOMEDCORP_SPARK,
	spawnhealth = 1,
	height = 32*FRACUNIT,
	radius = 16*FRACUNIT,
	flags = MF_NOCLIPTHING|MF_NOBLOCKMAP
}

states[S_DOOMEDCORP_SPARK] = {
	sprite = SPR_DCSP,
	frame = A|FF_PAPERSPRITE|FF_FULLBRIGHT|FF_ADD,
	tics = -1,
	var1 = 12,
	var2 = TR
}

addHook("MapThingSpawn",function(mo,mt)
	mo.flags2 = $|MF2_DONTDRAW
	mo.flags = $|MF_NOGRAVITY
	mo.tics = -1
	mo.fuse = -1
end,MT_DOOMEDCORP_SPARK)

addHook("MobjThinker",function(mo)
	if not (mo and mo.valid) then return end
	
	if mo.truespark
		local th = mo
		
		th.angle = R_PointToAngle2(0,0, th.momx,th.momy)
		th.rollangle = R_PointToAngle2(0, 0, R_PointToDist2(0,0,th.momx,th.momy), th.momz*P_MobjFlip(th))
		--th.momz = $+(P_GetMobjGravity(th)*2*P_MobjFlip(th))
		--th.spritexscale,th.spriteyscale = FU*3/2,FU*3/2
		
		if P_IsObjectOnGround(th)
		and th.lastmomz ~= nil
			if P_RandomChance(FU/2)
			and (th.lastmomz*P_MobjFlip(th)) <= -5*th.scale
			and (not th.bouncedup)
				P_SetObjectMomZ(th,-
					FixedDiv(
						FixedDiv(th.lastmomz,th.scale),
						2*FU+(P_RandomFixed()*(P_RandomChance(FU/2) and 1 or -1))
					)
				)
				th.bouncedup = true
			end
		end
		
		th.frame = ($ &~FF_FRAMEMASK)|A+P_RandomRange(0,2)
		if th.tics == 10
			th.destscale = 0
			th.scalespeed = FixedDiv(th.scale,10*FU)
		end
		th.lastmomz = th.momz
		
		if th.timealive == nil
			th.timealive = 0
		else
			th.timealive = $+1
		end
		th.color = SKINCOLOR_ORANGE
		local tics = max(8-(th.timealive/4),0)
		if tics > 4
		and tics <= 6
			th.color = SKINCOLOR_APRICOT
		elseif tics > 2
		and tics <= 4
			th.color = SKINCOLOR_LEMON
		elseif tics <= 2
			th.color = SKINCOLOR_WHITE
		end
		return
	end
	
	if mo.sparkwait == nil then mo.sparkwait = P_RandomRange(5, 35) end
	
	if mo.sparkwait
		mo.sparkwait = $-1
	else
		for i = 4, P_RandomRange(7,10)
			local sp = P_SpawnMobjFromMobj(mo,0,0,0,MT_DOOMEDCORP_SPARK)
			P_Thrust(sp,
				FixedAngle(P_RandomRange(0,360)*FU),
				3*mo.scale
			)
			sp.angle = R_PointToAngle2(mo.x,mo.y, sp.x,sp.y)
			sp.tics = TR + P_RandomRange(0,10)
			sp.fuse = sp.tics
			sp.truespark = true
			
			sp.height = 8*mo.scale
			sp.radius = 4*mo.scale
			P_SetObjectMomZ(sp,P_RandomRange(-1,3)*FU)
		end
		mo.sparkwait = P_RandomRange(15, 38)
	end
end,MT_DOOMEDCORP_SPARK)