local eb_mapnum = G_FindMapByNameOrCode("MAPEB")

--freeslot
freeslot(
"sfx_ebtext",
"sfx_ebgif1",
"sfx_ebgif2",
"sfx_ebehit",
"sfx_ebedie",
"sfx_ebeatk",
"sfx_smaash"
)

-- Spoiler Warning
local function ebspoilr()
	chatprint("\x82\Warning:\x80\ This map contains spoilers for \x81\Earthbound.")
end

-- Present Easter Egg
local function eblebat1()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("%s opened the Present.",player.name))
		end
	end
end

local function eblebat2()
	chatprint("There is a Legendary Bat inside!")
end

local function eblebat3()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("%s takes it.",player.name))
		end
	end
end

local function eblebat4()
	chatprint("There is a \x88\Mega Orb\x80\ inside!")
end

-- Prayer Spots
local function prayerr1()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\%s\x80\ prayed from the bottom of their heart!",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayerr2()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\<%s>\x80\ ...Please give us strength, if it is possible... Please...... Somebody... help us...",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayerr3()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("(\x84\%s\x80\ friends began having an uneasy feeling in their hearts and prayed for their safety.)",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayerr4()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("(They began to pray for the safety of \x84\%s\x80\ and their friends)",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayerr5()
	chatprint("\x85\Giygas' defenses became unstable!")
	chatprint("\x84\Health Restored!")
	S_StartSound(player, sfx_ebtext)
	for player in players.iterate do
		if player.mo and player.mo.valid then
			if (player["ze2_info"].team == 1) then
				player.mo.health = player.mo.maxhealth
			end
		end
	end
end

local function prayerr6()
	chatprint("\x84\ 47 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

local function prayerr7()
	chatprint("\x84\ 93 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

local function prayerr8()
	chatprint("\x84\ 318 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

local function prayerr9()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\<%s>\x80\ I can't think of anyone else... Someone, anyone... Please help us...",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayer10()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\%s\x80\'s call was absorbed by the darkness.",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayer11()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\<%s>\x80\ Someone... Can you hear me?! Please, give us strength!",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayer12()
	for player in players.iterate
		if player.rings == 1 then
			chatprint(string.format("\x84\%s\x80\ and their friends' calls touched your heart.",player.name))
		end
	end
	S_StartSound(player, sfx_ebtext)
end

local function prayer13()
	chatprint("You prayed for the survivors, having never even met them before.")
	S_StartSound(player, sfx_ebtext)
end

local function prayer14()
	chatprint("You kept praying.")
	S_StartSound(player, sfx_ebtext)
end

local function prayer15()
	chatprint("\x84\ 2938 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

local function prayer16()
	chatprint("\x84\ 5200 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

local function prayer17()
	chatprint("\x84\ 15450 HP of damage to Giygas!")
	S_StartSound(player, sfx_ebehit)
end

--Pokey Dialouge
local COTPPokeyTimer = ZE2:AddTimer("Pokey Encounter",{
	time = 30*TICRATE,
	extrainfo = {
		color = SKINCOLOR_WHITE,
		-- Presidential Speech 2: Electric Boogaloo
		[1] = {
			event_time = 28*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ Hey! Aren't you surprised? It's me, Pokey!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[2] = {
			event_time = 22*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ Hold it... Where the hell is Ness?!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[3] = {
			event_time = 16*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ NO! NO! NO! NOOO!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[4] = {
			event_time = 8*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ The Apple of Enlightenment told me Ness was gonna be here, not a bunch of damn fur balls!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[5] = {
			event_time = 2*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ You all ruined this for me! I'm not even gonna fight! I'll watch Giygas devour you all! Heh heh heh!")
				S_StartSound(player, sfx_ebtext)
			end
		}
	}
})

local COTPPreZombieTimer = ZE2:AddTimer("Incoming Zombies",{
	time = 15*TICRATE,
	extrainfo = {
		color = SKINCOLOR_WHITE,
		[1] = {
			event_time = 13*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ So, isn't this terrifying? I'm terrified, too.")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[2] = {
			event_time = 10*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ Giygas cannot think rationally any more,")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[3] = {
			event_time = 5*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ and you... you will be... just another meal to him!")
				S_StartSound(player, sfx_ebtext)
			end
		}
	}
})

local COTPGiygasTimer = ZE2:AddTimer("Survive Giygas",{
	time = 45*TICRATE,
	extrainfo = {
		color = SKINCOLOR_RED,
		[1] = {
			event_time = 20*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ GrrrrAHHH! Why won't you all die?!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[2] = {
			event_time = 16*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ You have no purpose in being here!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[3] = {
			event_time = 12*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ This was supposed to be the moment I finally surpassed Ness!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[4] = {
			event_time = 8*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ Nobody will save you and you'll be burned like the rest of the garbage of the cosmos!")
				S_StartSound(player, sfx_ebtext)
			end
		},
		[5] = {
			event_time = 1*TICRATE,
			event_func = do
				chatprint("\x84\<Pokey>\x80\ Go ahead and cry out, nobody will save you now!")
				S_StartSound(player, sfx_ebtext)
			end
		}
	}
})

local function poketak1()
	ZE2.ZombieCheckpoints = {
		[1] = {
			x = -5920,
			y = -16544,
			z = 184,
			angle = 90,
		}
	}
	
	ZE2.CurrentZombieCheckpoint = 1
	
	COTPPokeyTimer.active = true
end

local function poketak2()
	ZE2.ZombieCheckpoints = {
		[2] = {
			x = -12800,
			y = -832,
			z = 0,
			angle = ANGLE_90,
		}
	}
	
	ZE2.CurrentZombieCheckpoint = 2

	for player in players.iterate
		if player.mo and player.mo.valid then
			if (player["ze2_info"].team == 1) then
				P_SetOrigin(player.mo, -16096*FRACUNIT, -4960*FRACUNIT, 0*FRACUNIT)
			end
			if (player["ze2_info"].team == 2) then
				P_SetOrigin(player.mo, -12800*FRACUNIT, -832*FRACUNIT, 0*FRACUNIT)
			end
		end
	end
	
	COTPPreZombieTimer.active = true
end

local function giygasfn()
	ZE2.ZombieCheckpoints = {
		[3] = {
			x = -16096,
			y = -4960,
			z = 0,
			angle = ANGLE_90,
		}
	}
	
	ZE2.CurrentZombieCheckpoint = 3

	for player in players.iterate
		if player.mo and player.mo.valid then
			if (player["ze2_info"].team == 2) then
				P_SetOrigin(player.mo, -16096*FRACUNIT, -4960*FRACUNIT, 0*FRACUNIT)
			end
		end
	end
	COTPGiygasTimer.active = true
end

local function prayer18()
	ZE2.ZombieCheckpoints = {
		[4] = {
			x = -12800,
			y = -832,
			z = 0,
			angle = ANGLE_90,
		}
	}

	ZE2.CurrentZombieCheckpoint = 4

	chatprint("\x84\ 27600 HP of damage to Giygas!")
	S_StartSound(player, sfx_smaash)
	for player in players.iterate
		if player.mo and player.mo.valid then
			if (player["ze2_info"].team == 1) then
				P_SetOrigin(player.mo, 11712*FRACUNIT, 6656*FRACUNIT, 0*FRACUNIT)
			end
			if (player["ze2_info"].team == 2) then
				P_SetOrigin(player.mo, -12800*FRACUNIT, -832*FRACUNIT, 0*FRACUNIT)
			end
		end
	end
end

addHook("LinedefExecute", ebspoilr, "EBSPOI")
addHook("LinedefExecute", eblebat1, "EBLBT1")
addHook("LinedefExecute", eblebat2, "EBLBT2")
addHook("LinedefExecute", eblebat3, "EBLBT3")
addHook("LinedefExecute", eblebat4, "EBLBT4")
addHook("LinedefExecute", poketak1, "POKTK1")
addHook("LinedefExecute", poketak2, "POKTK2")
addHook("LinedefExecute", prayerr1, "PRAYR1")
addHook("LinedefExecute", prayerr2, "PRAYR2")
addHook("LinedefExecute", prayerr3, "PRAYR3")
addHook("LinedefExecute", prayerr4, "PRAYR4")
addHook("LinedefExecute", prayerr5, "PRAYR5")
addHook("LinedefExecute", prayerr6, "PRAYR6")
addHook("LinedefExecute", prayerr7, "PRAYR7")
addHook("LinedefExecute", prayerr8, "PRAYR8")
addHook("LinedefExecute", prayerr9, "PRAYR9")
addHook("LinedefExecute", prayer10, "PRAY10")
addHook("LinedefExecute", prayer11, "PRAY11")
addHook("LinedefExecute", prayer12, "PRAY12")
addHook("LinedefExecute", prayer13, "PRAY13")
addHook("LinedefExecute", prayer14, "PRAY14")
addHook("LinedefExecute", prayer15, "PRAY15")
addHook("LinedefExecute", prayer16, "PRAY16")
addHook("LinedefExecute", prayer17, "PRAY17")
addHook("LinedefExecute", giygasfn, "GIYFIN")
addHook("LinedefExecute", prayer18, "PRAY18")