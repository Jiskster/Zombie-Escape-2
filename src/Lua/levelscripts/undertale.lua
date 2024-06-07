local ut_mapnum = G_FindMapByNameOrCode("MAPJ5")

freeslot(
"sfx_utatk",
"sfx_utdi",
"sfx_fwtlk",
"sfx_trtlk",
"sfx_utbtl",
"sfx_utdgr",
"sfx_utesc"
)

freeslot("MT_TORIEL") -- fuck you SOC

mobjinfo[MT_TORIEL].npc_name = "Toriel"
mobjinfo[MT_TORIEL].npc_name_color = SKINCOLOR_WHITE
mobjinfo[MT_TORIEL].npc_spawnhealth = {1400,3700}

local function undertale_floweytalk()
	chatprint("\x82\<Flowey>\x80 Hey, why are you in a hurry- Wait!")
	S_StartSound(player, sfx_fwtlk)
end

local function undertale_floweytalk2()
	chatprint("\x82\<Flowey>\x80 Hmm you didn't die. This is for now. Hehehe")
	S_StartSound(player, sfx_fwtlk)
end

local function undertale_BattleTele1Surv()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 1) then
			P_SetOrigin(player.mo, -7168*FRACUNIT, -6272*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele1Zm()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 2) then
			P_SetOrigin(player.mo, -7168*FRACUNIT, -6272*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele2Surv()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 1) then
			P_SetOrigin(player.mo, 6976*FRACUNIT, 3008*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele2Zm()
      for player in players.iterate
	   if player.mo and player.mo.valid and (player.zteam == 2) then
	      P_SetOrigin(player.mo, 5056*FRACUNIT, -2880*FRACUNIT, 0*FRACUNIT)
       end
	end
end

local function undertale_BattleTele3Surv()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 1) then
			P_SetOrigin(player.mo, -2368*FRACUNIT, -5504*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele3Zm()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 2) then
			P_SetOrigin(player.mo, -1088*FRACUNIT, -4736*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele4Surv()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 1) then
			P_SetOrigin(player.mo, 17280*FRACUNIT, 7104*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local function undertale_BattleTele4Zm()
	for player in players.iterate
		if player.mo and player.mo.valid and (player.zteam == 2) then
			P_SetOrigin(player.mo, 5056*FRACUNIT, -2880*FRACUNIT, 0*FRACUNIT)
		end
	end
end

local Undertale_DoorTimer = ZE2:AddTimer("Door 1",{
	time = 45*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(31)
		S_ChangeMusic("UTRNS",true,player)
	end,
}) 

local Undertale_Prebattle1Timer = ZE2:AddTimer("Incoming Zombies",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		undertale_BattleTele1Zm()
	end,
	extrainfo = {
		color = SKINCOLOR_FOREST,
		[1] = {
			event_time = 5*TICRATE,
			event_func = do
				undertale_BattleTele1Surv()
			end
		},
		[2] = {
			event_time = 6*TICRATE,
			event_func = do
				S_StartSound(player, sfx_utbtl)
			end
		}
	}
}) 

local Undertale_Battle1Timer = ZE2:AddTimer("Survive Zombies",{
	time = 60*TICRATE,
	extrainfo = {
		color = SKINCOLOR_FOREST,
		[1] = {
			event_time = 1*TICRATE,
			event_func = do
				S_StartSound(player, sfx_utesc)
				S_ChangeMusic("UTRNS",true,player)
				undertale_BattleTele2Zm()
				undertale_BattleTele2Surv()
			end
		},
		[2] = {
			event_time = 30*TICRATE,
			event_func = do
				S_StartSound(nil, sfx_oldrad)
				chatprint("\x82\ 30 \x80seconds remaining")
			end
		},
		[3] = {
			event_time = 15*TICRATE,
			event_func = do
				S_StartSound(nil, sfx_oldrad)
				chatprint("\x82\ 15 \x80seconds remaining")
			end
		},
		[4] = {
			event_time = 5*TICRATE,
			event_func = do
				S_StartSound(nil, sfx_oldrad)
				chatprint("\x83\ 5 \x80seconds remaining")
			end
		}
	}
}) 

local Undertale_Prebattle2Timer = ZE2:AddTimer("Toriel Encounter",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		undertale_BattleTele3Surv()
		undertale_BattleTele3Zm()
	end,
	extrainfo = {
		color = SKINCOLOR_WHITE,
		-- Presidential Speech
		[1] = {
			event_time = 19*TICRATE,
			event_func = do
				chatprint("\x89\<Toriel>\x80 You want to leave so badly? Hmph...")
				S_StartSound(player, sfx_trtlk)
			end
		},
		[2] = {
			event_time = 15*TICRATE,
			event_func = do
				chatprint("\x89\<Toriel>\x80 You are just like the others. There is only one solution to this")
				S_StartSound(player, sfx_trtlk)
			end
		},
		[3] = {
			event_time = 5*TICRATE,
			event_func = do
				chatprint("\x89\<Toriel>\x80 Prove yourself... Prove to me you are strong enough to survive.")
				S_StartSound(player, sfx_trtlk)
			end
		},
		[4] = {
			event_time = 1*TICRATE,
			event_func = do
				S_StartSound(player, sfx_utbtl)
			end
		}
	}
}) 

local function undertale_door1()
	chatprint("\x89\Door \x80will open in\x85 45 \x80seconds")
	S_StartSound(player, sfx_utdgr)
	
	Undertale_DoorTimer.active = true
end

local function undertale_Prebattle1()
	chatprint("\x8B\Zombies \x80will appear in\x82 20 \x80seconds")
	S_StartSound(player, sfx_utdgr)
	Undertale_Prebattle1Timer.active = true
end

local function undertale_Startbattle1()
	chatprint("Survive for\x85 60 \x80seconds")
	S_ChangeMusic("UTBTL2",true,player)
	S_StartSound(player, sfx_utdgr)
	Undertale_Battle1Timer.active = true
end

local function undertale_Prebattle2()
	Undertale_Prebattle2Timer.active = true
end

local function undertale_Startbattle2()
	ZE2.ZombieCheckpoints = {
		[1] = {
			x = -1088,
			y = -4736,
			z = 0,
			angle = ANGLE_180,
		}
	}
	
	ZE2.CurrentZombieCheckpoint = 1
	
	for player in players.iterate do
		if player.mo and player.mo.valid then
			player.mo.health = 1
			player.mo.maxhealth = 1
		end
	end
end

addHook("MobjLineCollide", function(mobj,line)
	if gamemap ~= ut_mapnum then return end 
	if not mobj.valid or not mobj.player then return end
	
	if line.tag == 52 and mobj.player.zteam == 2 then
		return true
	end
end, MT_PLAYER)

addHook("MobjDeath", function(mobj)
	if gamemap ~= ut_mapnum then return end 
	
	P_LinedefExecute(42)
end, MT_TORIEL)

addHook("LinedefExecute", undertale_floweytalk, "FWTLK1")
addHook("LinedefExecute", undertale_floweytalk2, "FWTLK2")

addHook("LinedefExecute", undertale_door1, "48DR1")
addHook("LinedefExecute", undertale_Prebattle1, "48BTL1")
addHook("LinedefExecute", undertale_Startbattle1, "48BTL2")
addHook("LinedefExecute", undertale_Prebattle2, "48PRE2")
addHook("LinedefExecute", undertale_Startbattle2, "48BTLT")