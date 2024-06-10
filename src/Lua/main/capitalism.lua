freeslot("MT_CRRUBY","S_CRRUBY","SPR_RBY1", "sfx_rbyhit") -- idk what CR means but i just slap it there
freeslot("MT_RUBY_BOX","MT_RUBY_ICON", "S_RUBY_BOX", "S_RUBY_ICON1", 
		"S_RUBY_ICON2", "SPR_RBYM")

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

-- Ruby Monitor is unused.
mobjinfo[MT_RUBY_BOX] = {
	--$Name Ruby Monitor
	--$Sprite RBYMA0
	--$Category Monitors
	doomednum = 863,
	spawnstate = S_RUBY_BOX,
	reactiontime = 8,
	painstate = S_RUBY_BOX,
	deathstate = S_BOX_POP1,
	deathsound = sfx_pop,
	speed = 1,
	radius = 18*FRACUNIT,
	height = 40*FRACUNIT,
	mass = 100,
	damage = MT_RUBY_ICON,
	flags = MF_SOLID|MF_SHOOTABLE|MF_MONITOR
}

mobjinfo[MT_RUBY_ICON] = {
	doomednum = -1,
	spawnstate = S_RUBY_ICON1,
	seesound = sfx_kc54,
	reactiontime = 8,
	deathsound = sfx_pop,
	speed = 2*FRACUNIT,
	radius = 8*FRACUNIT,
	height = 14*FRACUNIT,
	mass = 100,
	damage = 62*FRACUNIT,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIP|MF_BOXICON|MF_SCENERY
}

states[S_RUBY_BOX] = {SPR_RBYM, A, 2, nil, 0, 0, S_BOX_FLICKER}
states[S_RUBY_ICON1] = {SPR_RBYM, C|FF_ANIMATE, 18, nil, 3, 4, S_RUBY_ICON2}
states[S_RUBY_ICON2] = {SPR_RBYM, C, 18, A_RubyDrop, 10}

sfxinfo[sfx_rbyhit].caption = "Ruby"

-- Disable Ruby Monitors
addHook("MobjThinker", function(mobj)
	P_RemoveMobj(mobj)
	return true
end, MT_RUBY_BOX)

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
			ghost.fuse = 2
			
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
		if toucher.player["ze2_info"].rubies + 1 > toucher.player["ze2_info"].rubycap then
			return true
		elseif toucher.player["ze2_info"].rubypickupdelay then
			return true
		end

		if not toucher.player["ze2_info"].rubyqueue then
			S_StartSound(toucher, sfx_rbyhit)
		end

		ZE2:QueuePlayerRubies(toucher.player, 1)

		toucher.player["ze2_info"].rubypickupdelay = ZE2.rubypickupdelay.value
	end
end, MT_CRRUBY)

addHook("MobjThinker", function(mobj)
	if mobj.sprite == SPR_SPRK then
		mobj.color = SKINCOLOR_RED
		mobj.colorized = true
	end
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
	local findrange = 1024*FRACUNIT
	searchBlockmap("objects", function(refmobj, foundmobj)
		if foundmobj and abs(mobj.z-foundmobj.z) < 300*FU and foundmobj.valid and foundmobj.player then
			P_FlyTo(mobj,foundmobj.x,foundmobj.y,foundmobj.z,4*FRACUNIT,true)
		end
	end,mobj,
	mobj.x-findrange,mobj.x+findrange,
	mobj.y-findrange,mobj.y+findrange)
end, MT_CRRUBY)

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
	"\x82You sent "..player["ze2_info"].rubies.." rubies to "..players[player2].name)
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
end, 1)
