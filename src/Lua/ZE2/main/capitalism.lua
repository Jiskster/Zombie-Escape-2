freeslot("MT_CRRUBY","S_CRRUBY","SPR_RBY1", "sfx_rbyhit") -- idk what CR means but i just slap it there
sfxinfo[sfx_rbyhit].caption = "Ruby"
														  --stands for Cool Rock you fool
freeslot("MT_RUBY_BOX", "S_RUBY_BOX", "S_RUBY_BOX_BREAK",
		"SPR_RBYM")

function ZE2:GivePlayerCash(player, amount)
	if player.ze2.cash + amount > player.ze2.cash_limit then
		player.ze2.cash = player.ze2.cash_limit
		return false
	else
		player.ze2.cash = $ + amount
	end
	
	return true
end

function ZE2:DeleteCrate3D(door)
	if door.sides then
		for k,v in pairs(door.sides) do
			if v and v.valid then
				P_RemoveMobj(v)
			end
		end
	end
	
	door.made3d = false
	door.flags2 = $ &~MF2_DONTDRAW
end

function ZE2:GetCameraMobj()
	local cam = camera
	if (displayplayer and displayplayer.valid)
		
		if not CV_FindVar("chasecam").value
			
			local pmo = displayplayer.realmo
			if not (pmo and pmo.valid)
				pmo = displayplayer.mo
			end
			
			if (pmo and pmo.valid)
				local th = P_SpawnMobj(
					pmo.x,
					pmo.y,
					GetActorZ(pmo,pmo,2),
					MT_RAY
				)
				th.angle = pmo.angle
				pmo = th
			end
			cam = pmo
		else
			cam = camera
		end
		
		if displayplayer.awayviewtics
		and (displayplayer.awayviewmobj and displayplayer.awayviewmobj.valid)
			cam = displayplayer.awayviewmobj
		end
		
		if not (cam and cam.valid)
			cam = camera
		end
	end
	return cam
end

ZE2.currencydelay = CV_RegisterVar({
	name = "z_currencydelay",
	defaultvalue = "1",
	PossibleValue = {MIN = 0, MAX = 12},
	flags = CV_NETVAR,
})

function A_RubyDrop(actor, var1)
	local rubyamount = var1
	if mapheaderinfo[gamemap].ze2_zombieswarm then
		rubyamount = $ / 2
	end
	for i=1,rubyamount do
		local the_ruby = P_SpawnMobjFromMobj(actor,0,0,10*FU,MT_CRRUBY)
		the_ruby.scale = FRACUNIT
		the_ruby.shadowscale = FRACUNIT
		the_ruby.fuse = 16*TICRATE
		the_ruby.landvolume = min(512/rubyamount, 200)
		P_SetObjectMomZ(the_ruby, P_RandomRange(7,10)*FU)

		if rubyamount > 1 then
			local angle = P_RandomFixed() * FU
			P_InstaThrust(the_ruby, angle, 2*FU)
		end
	end
end

mobjinfo[MT_CRRUBY]= {
	doomednum = -1,
	spawnstate = S_CRRUBY,
	spawnhealth = 1,
	deathstate = S_SPRK1,
	--deathsound = sfx_rbyhit,
	radius = 25*FU,
	height = 45*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_RUNSPAWNFUNC,
}

states[S_CRRUBY] = {
	sprite = SPR_RBY1,
	frame = FF_FULLBRIGHT|A,
    --MF_RUNSPAWNFUNC so we can always get this on the ruby, no matter how its spawned
    action = function(mo)
        mo.renderflags = $|RF_NOCOLORMAPS
    end,
	tics = -1,
	nextstate = S_CRRUBY,
}

mobjinfo[MT_RUBY_BOX] = {
	//$Category Zombie Escape 2
	//$Name Ruby Crate
	//$Sprite RBYMARAL
	
	doomednum = 863,
	spawnstate = S_RUBY_BOX,
	deathstate = S_RUBY_BOX_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 1,
	height = 32*FRACUNIT,
	radius = 16*FRACUNIT,
	flags = MF_SOLID|MF_SHOOTABLE|MF_RUNSPAWNFUNC
}

states[S_RUBY_BOX] = {
    sprite = SPR_RBYM,
	action = function(crate)
		crate.spawnpos = {crate.x,crate.y,crate.z}
	end,
    frame = A,
	tics = -1,
}

states[S_RUBY_BOX_BREAK] = {
    sprite = SPR_RBYM,
    frame = A,
	action = function(mo)
		mo.flags2 = $|MF2_DONTDRAW
		ZE2:DeleteCrate3D(mo)
		
		local sfx = P_SpawnGhostMobj(mo)
		sfx.flags2 = $|MF2_DONTDRAW
		sfx.fuse = TICRATE
		S_StartSound(sfx,mo.info.deathsound)
		
		A_RubyDrop(mo, 5)

		--Cool !
		for i = 0,8
			local fa = FixedAngle(45*FU*i)
			local plank = P_SpawnMobjFromMobj(mo,
				P_ReturnThrustX(nil, fa, FixedDiv(mo.radius,mo.scale)),
				P_ReturnThrustY(nil, fa, FixedDiv(mo.radius,mo.scale)),
				P_RandomRange(0, FixedDiv(mo.height,mo.scale)>>FRACBITS)*FU,
				MT_THOK
			)
			plank.tics = -1
			plank.fuse = TICRATE
			plank.state = S_WOODDEBRIS
			plank.frame = $|FF_PAPERSPRITE
			plank.colorized = true
			plank.color = SKINCOLOR_RED
			plank.flags = MF_NOCLIP|MF_NOCLIPHEIGHT
			plank.angle = fa + P_RandomRange(-180,180)*ANG1
			plank.rollangle = FixedAngle(P_RandomRange(0,359)*FU+P_RandomFixed())
			P_Thrust(plank, fa, P_RandomRange(1,5)*plank.scale+P_RandomFixed())
			P_SetObjectMomZ(plank,P_RandomRange(2,10)*FU+P_RandomFixed())
		end
	end,
	tics = 1,
}

sfxinfo[sfx_rbyhit].caption = "Ruby"

addHook("PlayerThink", function(player)
	if player.ze2.cash > player.ze2.cash_limit then
		player.ze2.cash = player.ze2.cash_limit
	end
	
	if player.ze2.currencydelay then
		player.ze2.currencydelay = $ - 1
	end
end)

addHook("MobjDeath", function(mobj)
	if gametype ~= GT_ZE2 return end
	
	if mobj.cashholding then
		A_RubyDrop(mobj,mobj.cashholding)
		mobj.cashholding = 0
	end
end)

addHook("MobjSpawn", function(mobj)
	if gametype ~= GT_ZE2 then return end
	
	if mobjinfo[mobj.type].rubydrop and type(mobjinfo[mobj.type].rubydrop) == "table" 
	and #mobjinfo[mobj.type].rubydrop == 2 then
		local ruby_count = P_RandomRange(mobjinfo[mobj.type].rubydrop[1],mobjinfo[mobj.type].rubydrop[2])
		mobj.cashholding = ruby_count
	end
end)


addHook("TouchSpecial", function(special, toucher)
	if toucher and toucher.valid and toucher.player then
		local team = toucher.player.xSlinger.team
		
		if toucher.player.ze2.cash + 1 > toucher.player.ze2.cash_limit then
			return true
		elseif toucher.player.ze2.currencydelay then
			return true
		end

		S_StartSound(toucher, sfx_rbyhit)

		ZE2:GivePlayerCash(toucher.player, 5)
		S_StartSound(toucher, sfx_rbyhit)
		toucher.player.ze2:ChangeStamina(5*FRACUNIT)

		toucher.player.ze2.currencydelay = ZE2.currencydelay.value
	end
end, MT_CRRUBY)

addHook("MobjDeath", function(mobj)
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
	mobj.alpha = 0
	
	if mobj and mobj.valid then
		local iv = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_IVSP)
		iv.fuse = 15
		iv.angle = P_RandomRange(1,360)*ANG1
		iv.flags = $ & ~(MF_NOGRAVITY)
		P_SetObjectMomZ(iv, P_RandomRange(2,7)*FU, true)
		P_Thrust(iv, iv.angle, P_RandomRange(4,25)*FU)
		
		iv.color = SKINCOLOR_RUBY
		iv.colorized = true
	end
end, MT_CRRUBY)

addHook("MobjThinker", function(mobj)
	if mobj.sprite == SPR_SPRK then
		mobj.color = SKINCOLOR_RUBY
		mobj.colorized = true
	end
	
	if not mobj.health then return end 
	
	--P_RingZMovement(mobj)
	if mobj.eflags & MFE_JUSTHITFLOOR then
		P_SetObjectMomZ(mobj, abs(FixedDiv(mobj.lastmomz, P_RandomRange(2,3)*FRACUNIT)))
		if mobj.momz < FRACUNIT then
			mobj.momz = 0
		else
			S_StartSoundAtVolume(mobj, sfx_tink, mobj.landvolume or 200)
			mobj.landvolume = min($ + 30, 200)
		end
	end
	mobj.lastmomz = mobj.momz
	
	if mobj.fuse < 3*TICRATE then
		mobj.flags2 = $^^MF2_DONTDRAW
	end
	local findrange = 1024*mobj.scale
	local pmofound
	
	for p in players.iterate
		if p.spectator then continue end
		if not (p.mo and p.mo.valid) then continue end
		if p.xSlinger.team ~= 1 then continue end
		if p.ze2.cash >= p.ze2.cash_limit then continue end
		
		local mo = p.mo
		local dist = FixedHypot(FixedHypot(mobj.x - mo.x, mobj.y - mo.y), mobj.z - mo.z)

		if abs(mobj.z - mo.z) <= 300*mobj.scale
		and dist <= findrange then
			if not pmofound then
				pmofound = mo
			else
				local newpmodist = R_PointToDist2(mobj.x, mobj.y, mo.x, mo.y)
				local oldpmodist = R_PointToDist2(mobj.x, mobj.y, pmofound.x, pmofound.y)
				
				if newpmodist < oldpmodist then
					pmofound = mo
				end
			end
		end
	end

	mobj.spritexscale,mobj.spriteyscale = FU,FU
	if mobj.momz*P_MobjFlip(mobj) <= -mobj.scale then
		local mom = FixedDiv(mobj.momz*P_MobjFlip(mobj),mobj.scale)+FU
		mom = $/50
		mom = max($,-FU*3/5)
		mobj.spritexscale,
		mobj.spriteyscale = $1+mom,$2-mom
	end
	
	if P_RandomChance(FU/8)
		local wind = P_SpawnMobj(
			mobj.x + P_RandomRange(-18,18)*mobj.scale,
			mobj.y + P_RandomRange(-18,18)*mobj.scale,
			mobj.z + (mobj.height/2) + P_RandomRange(-20,20)*mobj.scale,
			MT_BOXSPARKLE
		)
		wind.frame = $|FF_FULLBRIGHT
		wind.renderflags = $|RF_FULLBRIGHT
		wind.color = P_RandomChance(FU/2) and SKINCOLOR_RED or SKINCOLOR_CRIMSON
		wind.colorized = true
		wind.alpha = FU/2
		
		P_SetObjectMomZ(wind,P_RandomRange(1,3)*FU)
	end

	if pmofound and pmofound.valid then
		P_FlyTo(mobj,pmofound.x,pmofound.y,pmofound.z,4*FRACUNIT,true)
		local ghost = P_SpawnGhostMobj(mobj)
		ghost.fuse = 7
		ghost.renderflags = $|(RF_FULLBRIGHT)
		ghost.blendmode = AST_ADD
	end
end, MT_CRRUBY)

--TODO: this code kinda sucks ngl
addHook("MobjThinker",function(door)
	if not (door and door.valid) then return end
	
	/*
	--You should really be using `mobjscale` in the Custom tab.
	door.radius = FixedMul(mobjinfo[MT_RUBY_BOX].radius, door.spritexscale)
	door.height = FixedMul(mobjinfo[MT_RUBY_BOX].height, door.spriteyscale)
	*/
	
	door.takis_flingme = false
	door.takis_monitorgibs = true
	door.takis_gibsprite = SPR_RBYM
	door.takis_gibframes = {P,Q,R,S}
	door.takis_gibframeflags = FF_PAPERSPRITE
	
	local dist = 0
	local cullout = true
	local doculling = true
	if doculling
		local cam = ZE2:GetCameraMobj()
		
		dist = R_PointToDist2(cam.x,cam.y, door.x,door.y)
		
		local thok = P_SpawnMobj(cam.x, cam.y, cam.z, MT_RAY)
		thok.angle = cam.angle
		thok.flags2 = $|MF2_DONTDRAW
		if dist <= 5000*FU
		and P_CheckSight(thok,door)
			cullout = false
		end
		
		if not cullout
			local back = FixedAngle(AngleFixed(thok.angle)+180*FU)
			local diff = FixedAngle(AngleFixed(R_PointToAngle2(thok.x, thok.y, door.x, door.y))-AngleFixed(back))
			if AngleFixed(diff) > 180*FU
				diff = InvAngle(diff)
			end
			
			--in the cameras view
			if AngleFixed(diff) > 90*FU
				cullout = false
			else
				cullout = true
			end
		end
		
		if not door.health
			cullout = true
		end
		P_RemoveMobj(thok)
	end
	
	if cullout
		ZE2:DeleteCrate3D(door)
		return
	end
	
	if not cullout
		if not door.made3d
			local list
			local flip = P_MobjFlip(door)
			door.flags2 = $|MF2_DONTDRAW
			
			door.sides = {}
			list = door.sides
			
			for i = 1,4
				local angle = door.angle+(FixedAngle(90*FU*(i-1)))
				list[0+i] = P_SpawnMobjFromMobj(door,
					--dont scale up door.spritexscale, since the func already does
					P_ReturnThrustX(nil,angle,16*door.spritexscale),
					P_ReturnThrustY(nil,angle,16*door.spritexscale),
					0,MT_THOK
				)
				list[0+i].frame = A
				list[0+i].sprite = SPR_RBYM
				list[0+i].tics,list[0+i].fuse = -1,-1
				list[0+i].flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
				list[0+i].renderflags = $|RF_PAPERSPRITE|RF_NOSPLATBILLBOARD
				list[0+i].angle = angle+ANGLE_90
				list[0+i].height = 32*FU
				list[0+i].radius = 0
				list[0+i].spritexscale = door.spritexscale
				list[0+i].spriteyscale = door.spriteyscale
				P_SetOrigin(list[0+i],
					list[0+i].x,
					list[0+i].y,
					GetActorZ(door,list[0+i],1)
				)
			end
			list[5] = P_SpawnMobjFromMobj(door,0,0,0,MT_THOK)
			list[5].frame = B
			list[5].sprite = SPR_RBYM
			list[5].tics,list[5].fuse = -1,-1
			list[5].flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
			list[5].renderflags = $|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
			list[5].angle = door.angle
			list[5].height = 0
			list[5].spritexscale = door.spritexscale
			list[5].spriteyscale = door.spritexscale
			P_SetOrigin(list[5],list[5].x,list[5].y,GetActorZ(door,list[5],2))
			
			list[6] = P_SpawnMobjFromMobj(door,0,0,0,MT_THOK)
			list[6].frame = C
			list[6].sprite = SPR_RBYM
			list[6].tics,list[5].fuse = -1,-1
			list[6].flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
			list[6].renderflags = $|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
			list[6].angle = door.angle
			list[6].height = 0
			list[6].spritexscale = door.spritexscale
			list[6].spriteyscale = door.spritexscale
			P_SetOrigin(list[6],list[6].x,list[6].y,GetActorZ(door,list[6],1))
			
			door.made3d = true
		
		--update positions
		else
			local list = door.sides
			
			for i = 1,4
				local angle = door.angle+(FixedAngle(90*FU*(i-1)))
				list[0+i].angle = angle+ANGLE_90
				list[0+i].height = 32*FU
				list[0+i].radius = 0
				list[0+i].scale = door.scale
				list[0+i].spritexscale = door.spritexscale
				list[0+i].spriteyscale = door.spriteyscale
				P_MoveOrigin(list[0+i],
					door.x+P_ReturnThrustX(nil,angle,16*FixedMul(door.spritexscale, door.scale)) + door.momx,
					door.y+P_ReturnThrustY(nil,angle,16*FixedMul(door.spritexscale, door.scale)) + door.momy,
					GetActorZ(door,list[0+i],1) + door.momz
				)
			end
			list[5].angle = door.angle
			list[5].height = 0
			list[5].scale = door.scale
			list[5].shadowscale = (FU/2)*14/10
			list[5].spritexscale = door.spritexscale
			list[5].spriteyscale = door.spritexscale
			P_MoveOrigin(list[5],
				door.x + door.momx,
				door.y + door.momy,
				(P_MobjFlip(door) == 1 and (door.z + door.height) or door.z) + door.momz
			)

			P_SetOrigin(list[6],door.x,door.y,door.z)
			list[6].angle = door.angle
			list[6].height = 0
			list[6].scale = door.scale
			list[6].spritexscale = door.spritexscale
			list[6].spriteyscale = door.spritexscale
			P_MoveOrigin(list[6],
				door.x + door.momx,
				door.y + door.momy,
				(P_MobjFlip(door) == 1 and door.z or door.z + door.height) + door.momz
			)
			
		end
	end
end,MT_RUBY_BOX)

addHook("MobjThinker", function(mobj)
	if mobj.fuse then
		mobj.alpha = FU - FixedDiv(FU, mobj.fuse*FU)
		P_SetObjectMomZ(mobj, (-1*FU)/2, true)
	end
end, MT_IVSP)
