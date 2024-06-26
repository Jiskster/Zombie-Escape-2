freeslot("MT_CRRUBY","S_CRRUBY","SPR_RBY1", "sfx_rbyhit") -- idk what CR means but i just slap it there
														  --stands for Cool Rock you fool
freeslot("MT_RUBY_BOX", "S_RUBY_BOX", "S_RUBY_BOX_BREAK",
		"SPR_RBYM")

function ZE2:GivePlayerRubies(player, amount)
	if player["ze2_info"].rubies + amount > player["ze2_info"].rubycap then
		player["ze2_info"].rubies = player["ze2_info"].rubycap
		return false
	else
		player["ze2_info"].rubies = $ + amount
	end
	
	return true
end

function ZE2:QueuePlayerRubies(player, amount)
	player["ze2_info"].rubyqueue = $ + amount
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
			local th = P_SpawnMobj(displayplayer.realmo.x,
				displayplayer.realmo.y,
				displayplayer.realmo.z+(displayplayer.realmo.height/2),
				MT_NULL
			)
			th.angle = displayplayer.realmo.angle
			cam = th
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

ZE2.rubypickupdelay = CV_RegisterVar({
	name = "z_rubypickupdelay",
	defaultvalue = "0",
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
		the_ruby.fuse = 16*TICRATE
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
	flags = MF_SLIDEME|MF_SPECIAL,
}

states[S_CRRUBY] = {
	sprite = SPR_RBY1,
	frame = FF_FULLBRIGHT|A,
	tics = -1,
	nextstate = S_CRRUBY,
}

mobjinfo[MT_RUBY_BOX] = {
	--$Name Ruby Crate
	--$Sprite RBYMA0
	--change later?
	--$Category Monitors
	doomednum = 863,
	spawnstate = S_RUBY_BOX,
	deathstate = S_RUBY_BOX_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 1,
	height = 64*FRACUNIT,
	radius = 32*FRACUNIT,
	flags = MF_MONITOR|MF_SOLID|MF_SHOOTABLE|MF_RUNSPAWNFUNC
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
		--SpawnEnemyGibs(mo,mo,nil,true)
		--SpawnEnemyGibs(mo,mo,nil,true)
		--SpawnBam(mo,true)
		
		ZE2:DeleteCrate3D(mo)
		
		local sfx = P_SpawnGhostMobj(mo)
		sfx.flags2 = $|MF2_DONTDRAW
		sfx.fuse = TICRATE
		S_StartSound(sfx,mo.info.deathsound)
		
		A_RubyDrop(mo, 5)
	end,
	tics = 1,
}

sfxinfo[sfx_rbyhit].caption = "Ruby"

addHook("PlayerThink", function(player)
	if player["ze2_info"].rubies > player["ze2_info"].rubycap then
		player["ze2_info"].rubies = player["ze2_info"].rubycap
	end
	
	if player["ze2_info"].rubypickupdelay then
		player["ze2_info"].rubypickupdelay = $ - 1
	end

	if player.mo and player.mo.valid then
		if player["ze2_info"].rubyqueue then
			local ghost = P_SpawnGhostMobj(player.mo)
			ghost.color = SKINCOLOR_RED
			ghost.colorized = true
			ghost.frame = $|FF_TRANS10
			ghost.fuse = 4
			
			ZE2:GivePlayerRubies(player, 1)
			S_StartSound(player.mo, sfx_rbyhit)
			player["ze2_info"].rubyqueue = $ - 1
		end
	end
end)

addHook("MobjDeath", function(mobj)
	if gametype ~= GT_ZE2 return end
	
	if mobj.rubiesholding then
		A_RubyDrop(mobj,mobj.rubiesholding)
		mobj.rubiesholding = 0
	end
end)

addHook("MobjSpawn", function(mobj)
	if gametype ~= GT_ZE2 then return end
	
	if mobjinfo[mobj.type].rubydrop and type(mobjinfo[mobj.type].rubydrop) == "table" 
	and #mobjinfo[mobj.type].rubydrop == 2 then
		local ruby_count = P_RandomRange(mobjinfo[mobj.type].rubydrop[1],mobjinfo[mobj.type].rubydrop[2])
		mobj.rubiesholding = ruby_count
	end
end)


addHook("TouchSpecial", function(special, toucher)
	if toucher and toucher.valid and toucher.player then
		local team = toucher.player["ze2_info"].team 
		
		if team == 2 then
			return true
		end
		
		if toucher.player["ze2_info"].rubies + 1 > toucher.player["ze2_info"].rubycap then
			return true
		elseif toucher.player["ze2_info"].rubypickupdelay then
			return true
		end

		if not toucher.player["ze2_info"].rubyqueue then
			S_StartSound(toucher, sfx_rbyhit)
		end

		ZE2:QueuePlayerRubies(toucher.player, 1)
		ZE2:IncrementSprint(toucher.player, 5*FRACUNIT)

		toucher.player["ze2_info"].rubypickupdelay = ZE2.rubypickupdelay.value
	end
end, MT_CRRUBY)

addHook("MobjDeath", function(mobj)
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
end, MT_CRRUBY)

addHook("MobjThinker", function(mobj)
	if mobj.sprite == SPR_SPRK then
		mobj.color = SKINCOLOR_RED
		mobj.colorized = true
	end
	
	if not mobj.health then return end 
	
	--P_RingZMovement(mobj)
	if mobj.eflags & MFE_JUSTHITFLOOR then
		P_SetObjectMomZ(mobj, abs(FixedDiv(mobj.lastmomz, P_RandomRange(2,3)*FRACUNIT)))
		if mobj.momz < FRACUNIT then
			mobj.momz = 0
		else
			S_StartSound(mobj, sfx_tink)
		end
	end
	mobj.lastmomz = mobj.momz
	
	if mobj.fuse < 3*TICRATE then
		mobj.flags2 = $^^MF2_DONTDRAW
	end
	local findrange = 1024*mobj.scale
	local pmofound
	
	for p in players.iterate
		if p["ze2_info"].team ~= 1 then continue end
		if p.spectator then continue end
		if p["ze2_info"].rubies == p["ze2_info"].rubycap then continue end
		if not (p.mo and p.mo.valid) then continue end

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

	if pmofound and pmofound.valid then
		P_FlyTo(mobj,pmofound.x,pmofound.y,pmofound.z,4*FRACUNIT,true)
	end
end, MT_CRRUBY)

addHook("MobjThinker",function(door)
	if not (door and door.valid) then return end
	
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
		
		local thok = P_SpawnMobj(cam.x, cam.y, cam.z, MT_NULL)
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
					P_ReturnThrustX(nil,angle,32*door.scale),
					P_ReturnThrustY(nil,angle,32*door.scale),
					0,MT_THOK
				)
				list[0+i].frame = A
				list[0+i].sprite = SPR_RBYM
				list[0+i].tics,list[0+i].fuse = -1,-1
				list[0+i].flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
				list[0+i].renderflags = $|RF_PAPERSPRITE|RF_NOSPLATBILLBOARD
				list[0+i].angle = angle+ANGLE_90
				list[0+i].height = 64*FU
				list[0+i].radius = 0
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
			P_SetOrigin(list[5],list[5].x,list[5].y,GetActorZ(door,list[5],2))
			
			list[6] = P_SpawnMobjFromMobj(door,0,0,0,MT_THOK)
			list[6].frame = C
			list[6].sprite = SPR_RBYM
			list[6].tics,list[5].fuse = -1,-1
			list[6].flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
			list[6].renderflags = $|RF_FLOORSPRITE|RF_NOSPLATBILLBOARD
			list[6].angle = door.angle
			list[6].height = 0
			P_SetOrigin(list[6],list[6].x,list[6].y,GetActorZ(door,list[6],1))
			
			door.made3d = true
		
		--update positions
		else
			local list = door.sides
			
			for i = 1,4
				local angle = door.angle+(FixedAngle(90*FU*(i-1)))
				list[0+i].angle = angle+ANGLE_90
				list[0+i].height = 64*FU
				list[0+i].radius = 0
				list[0+i].scale = door.scale
				P_MoveOrigin(list[0+i],
					door.x+P_ReturnThrustX(nil,angle,32*door.scale),
					door.y+P_ReturnThrustY(nil,angle,32*door.scale),
					GetActorZ(door,list[0+i],1)
				)
			end
			list[5].angle = door.angle
			list[5].height = 0
			list[5].scale = door.scale
			list[5].shadowscale = door.scale*14/10
			P_MoveOrigin(list[5],
				door.x,
				door.y,
				GetActorZ(door,list[5],2)
			)

			P_SetOrigin(list[6],door.x,door.y,door.z)
			list[6].angle = door.angle
			list[6].height = 0
			list[6].scale = door.scale
			P_MoveOrigin(list[6],
				door.x,
				door.y,
				GetActorZ(door,list[6],1)
			)
			
		end
	end
end,MT_RUBY_BOX)

addHook("MobjSpawn", function(crate)
	crate.scale = $ / 2
end, MT_RUBY_BOX)

COM_AddCommand("z_sendrubies", function(player, player2, rubies)
	local function giveinstructions()
		CONS_Printf(player, "z_sendrubies <receivingplayernum> <rubies>: gives rubies to a player")
	end
	if (not player2) or (not rubies) or (not tonumber(rubies)) then
		giveinstructions()
		return
	end
	
	rubies = tonumber($)
	player2 = tonumber($)
	if not players[player2] then
		CONS_Printf(player, "\x85This player does not exist.")
		return
	end
	
	if rubies > player["ze2_info"].rubies then
		CONS_Printf(player, "\x85You don't have enough rubies to do this.")
		return
	end
	
	if rubies <= 0 then 
		CONS_Printf(player, "\x85Rubies must be positive value.")
		return
	end
	
	player["ze2_info"].rubies = $ - rubies 
	players[player2]["ze2_info"].rubies = $ + rubies
	
	CONS_Printf(player, 
	"\x82You sent "..rubies.." rubies to "..players[player2].name)
	CONS_Printf(players[player2], 
	string.format("\x82%s\x82 sent you %s rubies", player.name, tostring(rubies))
	)
end)

COM_AddCommand("z_giverubies", function(player, rubies)
	local function giveinstructions()
		CONS_Printf(player, "z_giverubies <rubies>: gives rubies to yourself")
	end

	if (not rubies) or (not tonumber(rubies)) then
		giveinstructions()
		return
	end
	
	rubies = tonumber($)
	
	if rubies <= 0 then 
		CONS_Printf(player, "\x85Rubies must be positive value.")
		return
	end

	ZE2:QueuePlayerRubies(player, rubies)
	
	CONS_Printf(player, "\x82You got "..rubies.." rubies")
end, COM_ADMIN)
