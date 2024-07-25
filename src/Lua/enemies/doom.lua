--Zombie Man's shotgun missile

freeslot("MT_ZOMBIEMAN_MISSILE", "S_ZOMBIEMAN_MISSILE", "SPR_ZMMS", "SFX_SHOTGN","SFX_BLTDTH")
states[S_ZOMBIEMAN_MISSILE] = {SPR_ZMMS, FF_FULLBRIGHT|A, 1, nil, 0, 0, S_ZOMBIEMAN_MISSILE}

mobjinfo[MT_ZOMBIEMAN_MISSILE] = {
        doomednum = -1,
        spawnstate = S_ZOMBIEMAN_MISSILE,
		seesound = sfx_shotgn,
        spawnhealth = 1000,
        deathsound = SFX_BLTDTH,
        speed = 150*FRACUNIT,
        radius = 8*FRACUNIT,
        height = 8*FRACUNIT,
        mass = 100,
        flags = MF_NOBLOCKMAP|MF_MISSILE|MF_NOGRAVITY
}

mobjinfo[MT_ZOMBIEMAN_MISSILE].forcedamage = 12
mobjinfo[MT_ZOMBIEMAN_MISSILE].forceknockback = 3*FU
mobjinfo[MT_ZOMBIEMAN_MISSILE].forceverticalknockback = 3*FU
mobjinfo[MT_ZOMBIEMAN_MISSILE].relativeknockback = true

---------------------------------------Zombie Man

freeslot("MT_ZOMBIEMAN", "S_ZOMBIEMAN_STND", "S_ZOMBIEMAN_WALKSOUND1",
		 "S_ZOMBIEMAN_WALKSOUND2", "S_ZOMBIEMAN_LOOK", "S_ZOMBIEMAN_WALK1",
		 "S_ZOMBIEMAN_WALK2", "S_ZOMBIEMAN_WALK3", "S_ZOMBIEMAN_WALK4",
		 "S_ZOMBIEMAN_SHOOT1", "S_ZOMBIEMAN_SHOOT2", "S_ZOMBIEMAN_HURT",
		 "S_ZOMBIEMAN_DEATH1", "S_ZOMBIEMAN_DEATH2", "S_ZOMBIEMAN_DEATH3",
		 "S_ZOMBIEMAN_DEATH4", "S_ZOMBIEMAN_DEATH5", "SPR_DEN1", "sfx_zmwlk1",
		 "sfx_zmwlk2", "sfx_zmtnt1", "sfx_zmdeth", "sfx_shotgn")

--Zombie Man ZE2 Support

mobjinfo[MT_ZOMBIEMAN].npc_name = "Zombie Man"
mobjinfo[MT_ZOMBIEMAN].npc_spawnhealth = {30,45}
mobjinfo[MT_ZOMBIEMAN].npc_name_color = SKINCOLOR_GREEN
mobjinfo[MT_ZOMBIEMAN].rubydrop = {3,5}
mobjinfo[MT_ZOMBIEMAN].painsound = sfx_zpa2
mobjinfo[MT_ZOMBIEMAN].forcedamage = 10
mobjinfo[MT_ZOMBIEMAN].forceknockback = 9*FU
mobjinfo[MT_ZOMBIEMAN].forceverticalknockback = 5*FU
mobjinfo[MT_ZOMBIEMAN].relativeknockback = true

states[S_ZOMBIEMAN_WALKSOUND1] = {SPR_DEN1, A, 2, A_PlaySound, sfx_zmwlk1, 1, S_ZOMBIEMAN_WALKSOUND1}
states[S_ZOMBIEMAN_WALKSOUND2] = {SPR_DEN1, A, 2, A_PlaySound, sfx_zmwlk2, 1, S_ZOMBIEMAN_WALKSOUND1}
states[S_ZOMBIEMAN_LOOK] = {SPR_DEN1, A, 2, A_Chase, 0, 0, S_ZOMBIEMAN_LOOK}


states[S_ZOMBIEMAN_STND] = {SPR_DEN1, A, 2, A_Look, 0, 0, S_ZOMBIEMAN_STND}
states[S_ZOMBIEMAN_WALK1] = {SPR_DEN1, C, 6, A_DualAction, S_ZOMBIEMAN_WALKSOUND1, S_ZOMBIEMAN_LOOK, S_ZOMBIEMAN_WALK2}
states[S_ZOMBIEMAN_WALK2] = {SPR_DEN1, D, 10, A_Thrust, 5, 0, S_ZOMBIEMAN_WALK3}
states[S_ZOMBIEMAN_WALK3] = {SPR_DEN1, A, 6, A_DualAction, S_ZOMBIEMAN_WALKSOUND2, S_ZOMBIEMAN_LOOK, S_ZOMBIEMAN_WALK4}
states[S_ZOMBIEMAN_WALK4] = {SPR_DEN1, B, 10, A_Thrust, 5, 0, S_ZOMBIEMAN_WALK1}
states[S_ZOMBIEMAN_SHOOT1] = {SPR_DEN1, E, 10, A_FaceTarget, 0, 0, S_ZOMBIEMAN_SHOOT2}
states[S_ZOMBIEMAN_SHOOT2] = {SPR_DEN1, FF_FULLBRIGHT|F, 10, A_FireShot, MT_ZOMBIEMAN_MISSILE, 0, S_ZOMBIEMAN_WALK1}
states[S_ZOMBIEMAN_HURT] = {SPR_DEN1, G, 15, A_Pain, 0, 0, S_ZOMBIEMAN_WALK1}
states[S_ZOMBIEMAN_DEATH1] = {SPR_DEN1, H, 4, A_Scream, 0, 0, S_ZOMBIEMAN_DEATH2}
states[S_ZOMBIEMAN_DEATH2] = {SPR_DEN1, I, 4, nil, 0, 0, S_ZOMBIEMAN_DEATH3}
states[S_ZOMBIEMAN_DEATH3] = {SPR_DEN1, J, 4, nil, 0, 0, S_ZOMBIEMAN_DEATH4}
states[S_ZOMBIEMAN_DEATH4] = {SPR_DEN1, K, 4, nil, 0, 0, S_ZOMBIEMAN_DEATH5}
states[S_ZOMBIEMAN_DEATH5] = {SPR_DEN1, L, -1, nil, 0, 0, S_ZOMBIEMAN_DEATH5}

mobjinfo[MT_ZOMBIEMAN] = {
		--$Title Zombie Man
		--$Sprite DEN1A1
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1726,
        spawnstate = S_ZOMBIEMAN_STND,
        spawnhealth = 25,
        seestate = S_ZOMBIEMAN_WALK1,
        seesound = sfx_zmtnt1,
        reactiontime = 2,
        painstate = S_ZOMBIEMAN_HURT,
        painsound = sfx_zpa2,
		meleestate = S_ZOMBIEMAN_SHOOT1,
        missilestate = S_ZOMBIEMAN_SHOOT1,
        deathstate = S_ZOMBIEMAN_DEATH1,
        xdeathstate = S_NULL,
        deathsound = sfx_zmdeth,
        speed = 0,
        radius = 16*FRACUNIT,
        height = 70*FRACUNIT,
        dispoffset = 0,
        mass = 100,
        activesound = sfx_None,
        flags = MF_ENEMY|MF_SHOOTABLE|MF_SPECIAL,
		painchance = 3000
}

--------------------------------------------Demon (Pink)

freeslot("MT_DEMONPINK", "S_DEMONPINK_STND", "S_DEMONPINK_WALKSOUND1",
		 "S_DEMONPINK_WALKSOUND2", "S_DEMONPINK_LOOK", "S_DEMONPINK_WALK1",
		 "S_DEMONPINK_WALK2", "S_DEMONPINK_WALK3", "S_DEMONPINK_MELEE1",
		 "S_DEMONPINK_MELEE2", "S_DEMONPINK_MELEE3", "S_DEMONPINK_WALK4",
		 "S_DEMONPINK_HURT", "S_DEMONPINK_DEATH1", "S_DEMONPINK_DEATH2",
		 "S_DEMONPINK_DEATH3", "S_DEMONPINK_DEATH4", "S_DEMONPINK_DEATH5",
		 "S_DEMONPINK_DEATH6", "SPR_DPNK", "sfx_dpwlk1", "sfx_dpwlk2",
		 "sfx_dptnt1", "sfx_dpdeth", "sfx_dphurt")
	

mobjinfo[MT_DEMONPINK].npc_name = "Demon Pink"
mobjinfo[MT_DEMONPINK].npc_spawnhealth = {50,70}
mobjinfo[MT_DEMONPINK].npc_name_color = SKINCOLOR_PINK
mobjinfo[MT_DEMONPINK].rubydrop = {5,8}
mobjinfo[MT_DEMONPINK].painsound = sfx_dphurt
mobjinfo[MT_DEMONPINK].forcedamage = 10
mobjinfo[MT_DEMONPINK].forceknockback = 20*FU
mobjinfo[MT_DEMONPINK].forceverticalknockback = 10*FU
mobjinfo[MT_DEMONPINK].relativeknockback = true

states[S_DEMONPINK_WALKSOUND1] = {SPR_DEN1, A, 2, A_PlaySound, sfx_dpwlk1, 1, S_DEMONPINK_WALKSOUND1}
states[S_DEMONPINK_WALKSOUND2] = {SPR_DEN1, A, 2, A_PlaySound, sfx_dpwlk2, 1, S_DEMONPINK_WALKSOUND1}
states[S_DEMONPINK_LOOK] = {SPR_DEN1, A, 2, A_FaceTarget, 0, 0, S_DEMONPINK_LOOK}

states[S_DEMONPINK_STND] = {SPR_DPNK, A, 2, A_Look, 0, 0, S_DEMONPINK_STND}
states[S_DEMONPINK_WALK1] = {SPR_DPNK, C, 4, A_DualAction, S_DEMONPINK_WALKSOUND1, S_DEMONPINK_LOOK, S_DEMONPINK_WALK2}
states[S_DEMONPINK_WALK2] = {SPR_DPNK, D, 4, A_Chase, 4, 0, S_DEMONPINK_WALK3}
states[S_DEMONPINK_WALK3] = {SPR_DPNK, A, 4, A_DualAction, S_DEMONPINK_WALKSOUND2, S_DEMONPINK_LOOK, S_DEMONPINK_WALK4}
states[S_DEMONPINK_WALK4] = {SPR_DPNK, B, 4, A_Chase, 4, 0, S_DEMONPINK_WALK1}
states[S_DEMONPINK_MELEE1] = {SPR_DPNK, E, 10, A_FaceTarget, 0, 0, S_DEMONPINK_MELEE2}
states[S_DEMONPINK_MELEE2] = {SPR_DPNK, F, 10, A_Chase, 0, 0, S_DEMONPINK_MELEE3}
states[S_DEMONPINK_MELEE3] = {SPR_DPNK, G, 10, nil, 0, 0, S_DEMONPINK_WALK1}
states[S_DEMONPINK_HURT] = {SPR_DPNK, H, 15, A_Pain, 0, 0, S_DEMONPINK_WALK1}
states[S_DEMONPINK_DEATH1] = {SPR_DPNK, I, 4, A_Scream, 0, 0, S_DEMONPINK_DEATH2}
states[S_DEMONPINK_DEATH2] = {SPR_DPNK, J, 4, nil, 0, 0, S_DEMONPINK_DEATH3}
states[S_DEMONPINK_DEATH3] = {SPR_DPNK, K, 4, nil, 0, 0, S_DEMONPINK_DEATH4}
states[S_DEMONPINK_DEATH4] = {SPR_DPNK, L, 4, nil, 0, 0, S_DEMONPINK_DEATH5}
states[S_DEMONPINK_DEATH5] = {SPR_DPNK, M, 4, nil, 0, 0, S_DEMONPINK_DEATH6}
states[S_DEMONPINK_DEATH6] = {SPR_DPNK, N, -1, nil, 0, 0, S_DEMONPINK_DEATH6}

mobjinfo[MT_DEMONPINK] = {
		--$Title Demon (Pink)
		--$Sprite DPNKA1
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1727,
        spawnstate = S_DEMONPINK_STND,
        spawnhealth = 25, --ZE2 support will override this
        seestate = S_DEMONPINK_WALK1,
        seesound = sfx_dptnt1,
        reactiontime = 0,
        painstate = S_DEMONPINK_HURT,
        painsound = sfx_dphurt,
        meleestate = S_DEMONPINK_MELEE1,
        deathstate = S_DEMONPINK_DEATH1,
        xdeathstate = S_NULL,
        deathsound = sfx_dpdeth,
        speed = 30,
        radius = 23*FRACUNIT,
        height = 76*FRACUNIT,
        dispoffset = 0,
        mass = 100,
        activesound = sfx_None,
        flags = MF_ENEMY|MF_SHOOTABLE|MF_SPECIAL,
}

--------------------------ARCH-VILE

--Arch-vile fire to target

freeslot("MT_ARCHVILE_FIRE", "S_ARCHVILE_FIRE1", "S_ARCHVILE_FIRE2", "S_ARCHVILE_FIRE3",
		 "S_ARCHVILE_FIRE4", "S_ARCHVILE_FIRE5", "S_ARCHVILE_FIRE6", "S_ARCHVILE_FIRE7",
		 "S_ARCHVILE_FIRE8", "S_ARCHVILE_FIRE9", "S_ARCHVILE_FIRE10", "S_ARCHVILE_FIRE11",
		 "S_ARCHVILE_FIRE12", "S_ARCHVILE_FIRE13", "S_ARCHVILE_FIRE14", "S_ARCHVILE_FIRE15",
		 "S_ARCHVILE_FIRE16", "S_ARCHVILE_FIRE17", "S_ARCHVILE_FIRE18", "S_ARCHVILE_FIRE19",
		 "S_ARCHVILE_FIRE20", "S_ARCHVILE_FIREDTH1", "S_ARCHVILE_FIREDTH2", "S_ARCHVILE_FIREDTH3",
		 "S_ARCHVILE_FIREDTH4", "S_ARCHVILE_FIREDTH5", "S_ARCHVILE_FIREDTH6",
		 "S_ARCHVILE_FIREDTH7", "S_ARCHVILE_FIREDTH8", "S_ARCHVILE_FIREDTH9",
		 "S_ARCHVILE_FIREDTH10", "S_ARCHVILE_FIREDTH11", "S_ARCHVILE_FIREDTH12",
		 "S_ARCHVILE_FIREDTH13", "S_ARCHVILE_FIREDTH14", "S_ARCHVILE_FIREDTH15",
		 "S_ARCHVILE_FIREDTH16", "S_ARCHVILE_FIREDTH17", "S_ARCHVILE_FIREDTH18",
		 "S_ARCHVILE_FIREDTH19", "S_ARCHVILE_FIREDTH20", "S_ARCHVILE_FIREDTH21",
		 "SPR_AVFI")

--State spam bruh (blame SOC aaah)

--Arch-vile fire anims
states[S_ARCHVILE_FIRE1] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE2}
states[S_ARCHVILE_FIRE2] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE3}
states[S_ARCHVILE_FIRE3] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE4}
states[S_ARCHVILE_FIRE4] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE5}
states[S_ARCHVILE_FIRE5] = {SPR_AVFI, FF_FULLBRIGHT|A, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE6}
states[S_ARCHVILE_FIRE6] = {SPR_AVFI, FF_FULLBRIGHT|A, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE7}
states[S_ARCHVILE_FIRE7] = {SPR_AVFI, FF_FULLBRIGHT|A, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE8}
states[S_ARCHVILE_FIRE8] = {SPR_AVFI, FF_FULLBRIGHT|A, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE9}
states[S_ARCHVILE_FIRE9] = {SPR_AVFI, FF_FULLBRIGHT|C, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE10}
states[S_ARCHVILE_FIRE10] = {SPR_AVFI, FF_FULLBRIGHT|C, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE11}
states[S_ARCHVILE_FIRE11] = {SPR_AVFI, FF_FULLBRIGHT|C, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE12}
states[S_ARCHVILE_FIRE12] = {SPR_AVFI, FF_FULLBRIGHT|C, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE13}
states[S_ARCHVILE_FIRE13] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE14}
states[S_ARCHVILE_FIRE14] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE15}
states[S_ARCHVILE_FIRE15] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE16}
states[S_ARCHVILE_FIRE16] = {SPR_AVFI, FF_FULLBRIGHT|B, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE17}
states[S_ARCHVILE_FIRE17] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE18}
states[S_ARCHVILE_FIRE18] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE19}
states[S_ARCHVILE_FIRE19] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIRE20}
states[S_ARCHVILE_FIRE20] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_Repeat, 3, S_ARCHVILE_FIRE1, S_NULL}

--Arch-vile fire end
states[S_ARCHVILE_FIREDTH1] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH2}
states[S_ARCHVILE_FIREDTH2] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH3}
states[S_ARCHVILE_FIREDTH3] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH4}
states[S_ARCHVILE_FIREDTH4] = {SPR_AVFI, FF_FULLBRIGHT|D, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH5}
states[S_ARCHVILE_FIREDTH5] = {SPR_AVFI, FF_FULLBRIGHT|E, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH6}
states[S_ARCHVILE_FIREDTH6] = {SPR_AVFI, FF_FULLBRIGHT|E, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH7}
states[S_ARCHVILE_FIREDTH7] = {SPR_AVFI, FF_FULLBRIGHT|E, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH8}
states[S_ARCHVILE_FIREDTH8] = {SPR_AVFI, FF_FULLBRIGHT|E, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH9}
states[S_ARCHVILE_FIREDTH9] = {SPR_AVFI, FF_FULLBRIGHT|F, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH10}
states[S_ARCHVILE_FIREDTH10] = {SPR_AVFI, FF_FULLBRIGHT|F, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH11}
states[S_ARCHVILE_FIREDTH11] = {SPR_AVFI, FF_FULLBRIGHT|F, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH12}
states[S_ARCHVILE_FIREDTH12] = {SPR_AVFI, FF_FULLBRIGHT|F, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH13}
states[S_ARCHVILE_FIREDTH13] = {SPR_AVFI, FF_FULLBRIGHT|G, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH14}
states[S_ARCHVILE_FIREDTH14] = {SPR_AVFI, FF_FULLBRIGHT|G, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH15}
states[S_ARCHVILE_FIREDTH15] = {SPR_AVFI, FF_FULLBRIGHT|G, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH16}
states[S_ARCHVILE_FIREDTH16] = {SPR_AVFI, FF_FULLBRIGHT|G, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH17}
states[S_ARCHVILE_FIREDTH17] = {SPR_AVFI, FF_FULLBRIGHT|H, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH18}
states[S_ARCHVILE_FIREDTH18] = {SPR_AVFI, FF_FULLBRIGHT|H, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH19}
states[S_ARCHVILE_FIREDTH19] = {SPR_AVFI, FF_FULLBRIGHT|H, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH20}
states[S_ARCHVILE_FIREDTH20] = {SPR_AVFI, FF_FULLBRIGHT|H, 1, A_VileFire, 0, 0, S_ARCHVILE_FIREDTH21}
states[S_ARCHVILE_FIREDTH21] = {SPR_NULL, FF_FULLBRIGHT|A, 1, A_RemoteDamage, 0, 2, S_NULL}

mobjinfo[MT_ARCHVILE_FIRE] = {
		--$Title Arch-vile fire test
		--$Sprite AVFIC0
		--$Category Doomed Corp
		--$Color 1
        doomednum = -1,
        spawnstate = S_ARCHVILE_FIRE1,
        spawnhealth = 1000,
        speed = 10*FRACUNIT,
        radius = 30*FRACUNIT,
        height = 70*FRACUNIT,
        mass = 100,
		damage = 1,
		reactiontime = 8,
        flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_RUNSPAWNFUNC
}

freeslot("MT_ARCHVILE", "S_ARCHVILE_STND", "S_ARCHVILE_WALKSOUND1", "S_ARCHVILE_WALKSOUND2",
		 "S_ARCHVILE_LOOK", "S_ARCHVILE_CHASE", "S_ARCHVILE_WALK1", "S_ARCHVILE_WALK2",
		 "S_ARCHVILE_WALK3", "S_ARCHVILE_WALK4", "S_ARCHVILE_WALK5", "S_ARCHVILE_WALK6",
		 "S_ARCHVILE_FIRECLAP1", "S_ARCHVILE_FIRECLAP2", "S_ARCHVILE_FIRECLAP3",
		 "S_ARCHVILE_FIRECLAP4", "S_ARCHVILE_FIRECLAP5", "S_ARCHVILE_FIRECLAP6",
		 "S_ARCHVILE_FIRECLAP7", "S_ARCHVILE_FIRECLAP8", "S_ARCHVILE_FIRECLAP9",
		 "S_ARCHVILE_FIRECLAP10", "S_ARCHVILE_HURT", "S_ARCHVILE_DEATH1",
		 "S_ARCHVILE_DEATH2", "S_ARCHVILE_DEATH3", "S_ARCHVILE_DEATH4",
		 "S_ARCHVILE_DEATH5", "S_ARCHVILE_DEATH6", "S_ARCHVILE_DEATH7",
		 "S_ARCHVILE_DEATH8", "S_ARCHVILE_DEATH9", "SPR_VILE", "sfx_vilsit",
		 "sfx_vilact", "sfx_vipain", "sfx_vildth")
	
--Arch-Vile ZE2 Support
mobjinfo[MT_ARCHVILE].npc_name = "Arch-Vile"
mobjinfo[MT_ARCHVILE].npc_spawnhealth = {400,800}
mobjinfo[MT_ARCHVILE].npc_name_color = SKINCOLOR_YELLOW
mobjinfo[MT_ARCHVILE].rubydrop = {30,60}
mobjinfo[MT_ARCHVILE].painsound = sfx_vipain
mobjinfo[MT_ARCHVILE].forcedamage = 15
mobjinfo[MT_ARCHVILE].forceknockback = 20*FU
mobjinfo[MT_ARCHVILE].forceverticalknockback = 10*FU
mobjinfo[MT_ARCHVILE].relativeknockback = true

--Double Actions
states[S_ARCHVILE_LOOK] = {SPR_VILE, A, 2, A_FaceTarget, 0, 0, S_ARCHVILE_LOOK}
states[S_ARCHVILE_CHASE] = {SPR_VILE, A, 2, A_Chase, 0, 0, S_ARCHVILE_LOOK}

--Stand/Looking for players on sight
states[S_ARCHVILE_STND] = {SPR_VILE, A, 2, A_Look, 0, 0, S_ARCHVILE_STND}

--Walk
states[S_ARCHVILE_WALK1] = {SPR_VILE, A, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK2}
states[S_ARCHVILE_WALK2] = {SPR_VILE, B, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK3}
states[S_ARCHVILE_WALK3] = {SPR_VILE, C, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK4}
states[S_ARCHVILE_WALK4] = {SPR_VILE, D, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK5}
states[S_ARCHVILE_WALK5] = {SPR_VILE, E, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK6}
states[S_ARCHVILE_WALK6] = {SPR_VILE, F, 2, A_DualAction, S_ARCHVILE_LOOK, S_ARCHVILE_CHASE, S_ARCHVILE_WALK1}

--Pain state
states[S_ARCHVILE_HURT] = {SPR_VILE, Q, 30, A_Pain, 0, 0, S_ARCHVILE_WALK1}

--Death Frames
states[S_ARCHVILE_DEATH1] = {SPR_VILE, R, 4, A_Scream, 0, 0, S_ARCHVILE_DEATH2}
states[S_ARCHVILE_DEATH2] = {SPR_VILE, S, 4, nil, 0, 0, S_ARCHVILE_DEATH3}
states[S_ARCHVILE_DEATH3] = {SPR_VILE, T, 4, nil, 0, 0, S_ARCHVILE_DEATH4}
states[S_ARCHVILE_DEATH4] = {SPR_VILE, U, 4, nil, 0, 0, S_ARCHVILE_DEATH5}
states[S_ARCHVILE_DEATH5] = {SPR_VILE, V, 4, nil, 0, 0, S_ARCHVILE_DEATH6}
states[S_ARCHVILE_DEATH6] = {SPR_VILE, W, 4, nil, 0, 0, S_ARCHVILE_DEATH7}
states[S_ARCHVILE_DEATH7] = {SPR_VILE, X, 4, nil, 0, 0, S_ARCHVILE_DEATH8}
states[S_ARCHVILE_DEATH8] = {SPR_VILE, Y, 4, nil, 0, 0, S_ARCHVILE_DEATH9}
states[S_ARCHVILE_DEATH9] = {SPR_VILE, Z, -1, nil, 0, 0, S_ARCHVILE_DEATH9}

--Fire Clap Frames
states[S_ARCHVILE_FIRECLAP1] = {SPR_VILE, G, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP2}
states[S_ARCHVILE_FIRECLAP2] = {SPR_VILE, FF_SEMIBRIGHT|H, 8, A_VileTarget, MT_ARCHVILE_FIRE, 0, S_ARCHVILE_FIRECLAP3}
states[S_ARCHVILE_FIRECLAP3] = {SPR_VILE, FF_SEMIBRIGHT|I, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP4}
states[S_ARCHVILE_FIRECLAP4] = {SPR_VILE, FF_FULLBRIGHT|J, 8, A_SetObjectFlags, MF_SHOOTABLE, 1, S_ARCHVILE_FIRECLAP5}
states[S_ARCHVILE_FIRECLAP5] = {SPR_VILE, FF_FULLBRIGHT|K, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP6}
states[S_ARCHVILE_FIRECLAP6] = {SPR_VILE, FF_FULLBRIGHT|L, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP7}
states[S_ARCHVILE_FIRECLAP7] = {SPR_VILE, FF_FULLBRIGHT|M, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP8}
states[S_ARCHVILE_FIRECLAP8] = {SPR_VILE, FF_FULLBRIGHT|N, 8, nil, 0, 0, S_ARCHVILE_FIRECLAP9}
states[S_ARCHVILE_FIRECLAP9] = {SPR_VILE, FF_FULLBRIGHT|O, 8, A_VileAttack, 0, MT_ARCHVILE_FIRE+(1<<16), S_ARCHVILE_FIRECLAP10}
states[S_ARCHVILE_FIRECLAP10] = {SPR_VILE, FF_SEMIBRIGHT|P, 8, A_SetObjectFlags, MF_SHOOTABLE, 2, S_ARCHVILE_WALK1}

mobjinfo[MT_ARCHVILE] = {
        doomednum = 1728,
        spawnstate = S_ARCHVILE_STND,
        spawnhealth = 25, --ZE2 support will override this
        seestate = S_ARCHVILE_WALK1,
        seesound = sfx_vilsit,
        reactiontime = 8,
        painstate = S_ARCHVILE_HURT,
        painsound = sfx_vipain,
		attacksound = sfx_vilact,
		missilestate = S_ARCHVILE_FIRECLAP1,
        deathstate = S_ARCHVILE_DEATH1,
        xdeathstate = S_NULL,
        deathsound = sfx_vildth,
        speed = 10,
        radius = 20*FRACUNIT,
        height = 115*FRACUNIT,
        dispoffset = 0,
        mass = 500,
        activesound = sfx_None,
        flags = MF_ENEMY|MF_SHOOTABLE|MF_SPECIAL,
		painchance = 10
}

--Arch-vile's low spawn chance
addHook("MapLoad", function(mapnum) 
	local archvile_spawnchance
	
	if (mapnum == 220) then
		archvile_spawnchance = P_RandomChance(FRACUNIT/6)
	end
	
	if archvile_spawnchance then
		P_SpawnMobj(-2816*FRACUNIT, -5088*FRACUNIT, 760*FRACUNIT, MT_ARCHVILE)
	end
end)

--bigger scale for Arch-vile
addHook("MobjSpawn", function(mobj) 
	if mobj and mobj.valid then
		mobj.scale = 2*FRACUNIT
		mobj.angle = ANGLE_90
	end
end, MT_ARCHVILE)

-------------------SPECTRE---------------

freeslot("MT_SPECTRE", "S_SPECTRE_STND", "S_SPECTRE_WALKSOUND1",
		 "S_SPECTRE_WALKSOUND2", "S_SPECTRE_LOOK", "S_SPECTRE_WALK1",
		 "S_SPECTRE_WALK2", "S_SPECTRE_WALK3", "S_SPECTRE_MELEE1",
		 "S_SPECTRE_MELEE2", "S_SPECTRE_MELEE3", "S_SPECTRE_WALK4",
		 "S_SPECTRE_HURT", "S_SPECTRE_DEATH1", "S_SPECTRE_DEATH2",
		 "S_SPECTRE_DEATH3", "S_SPECTRE_DEATH4", "S_SPECTRE_DEATH5",
		 "S_SPECTRE_DEATH6", "SPR_SPCT")
	

mobjinfo[MT_SPECTRE].npc_name = "Spectre"
mobjinfo[MT_SPECTRE].npc_spawnhealth = {70,80}
mobjinfo[MT_SPECTRE].npc_name_color = SKINCOLOR_JET
mobjinfo[MT_SPECTRE].rubydrop = {5,8}
mobjinfo[MT_SPECTRE].painsound = sfx_dphurt
mobjinfo[MT_SPECTRE].forcedamage = 10
mobjinfo[MT_SPECTRE].forceknockback = 20*FU
mobjinfo[MT_SPECTRE].forceverticalknockback = 10*FU
mobjinfo[MT_SPECTRE].relativeknockback = true

states[S_SPECTRE_WALKSOUND1] = {SPR_SPCT, A, 2, A_PlaySound, sfx_dpwlk1, 1, S_SPECTRE_WALKSOUND1}
states[S_SPECTRE_WALKSOUND2] = {SPR_SPCT, A, 2, A_PlaySound, sfx_dpwlk2, 1, S_SPECTRE_WALKSOUND1}
states[S_SPECTRE_LOOK] = {SPR_SPCT, A, 2, A_FaceTarget, 0, 0, S_SPECTRE_LOOK}

states[S_SPECTRE_STND] = {SPR_SPCT, A, 2, A_Look, 0, 0, S_SPECTRE_STND}
states[S_SPECTRE_WALK1] = {SPR_SPCT, FF_TRANS60|C, 4, A_DualAction, S_SPECTRE_WALKSOUND1, S_SPECTRE_LOOK, S_SPECTRE_WALK2}
states[S_SPECTRE_WALK2] = {SPR_SPCT, FF_TRANS60|D, 4, A_Chase, 4, 0, S_SPECTRE_WALK3}
states[S_SPECTRE_WALK3] = {SPR_SPCT, FF_TRANS60|A, 4, A_DualAction, S_SPECTRE_WALKSOUND2, S_SPECTRE_LOOK, S_SPECTRE_WALK4}
states[S_SPECTRE_WALK4] = {SPR_SPCT, FF_TRANS60|B, 4, A_Chase, 4, 0, S_SPECTRE_WALK1}
states[S_SPECTRE_MELEE1] = {SPR_SPCT, FF_TRANS60|E, 10, A_FaceTarget, 0, 0, S_SPECTRE_MELEE2}
states[S_SPECTRE_MELEE2] = {SPR_SPCT, FF_TRANS60|F, 10, A_Chase, 0, 0, S_SPECTRE_MELEE3}
states[S_SPECTRE_MELEE3] = {SPR_SPCT, FF_TRANS60|G, 10, nil, 0, 0, S_SPECTRE_WALK1}
states[S_SPECTRE_HURT] = {SPR_SPCT, H, 15, A_Pain, 0, 0, S_SPECTRE_WALK1}
states[S_SPECTRE_DEATH1] = {SPR_SPCT, I, 4, A_Scream, 0, 0, S_SPECTRE_DEATH2}
states[S_SPECTRE_DEATH2] = {SPR_SPCT, J, 4, nil, 0, 0, S_SPECTRE_DEATH3}
states[S_SPECTRE_DEATH3] = {SPR_SPCT, K, 4, nil, 0, 0, S_SPECTRE_DEATH4}
states[S_SPECTRE_DEATH4] = {SPR_SPCT, L, 4, nil, 0, 0, S_SPECTRE_DEATH5}
states[S_SPECTRE_DEATH5] = {SPR_SPCT, M, 4, nil, 0, 0, S_SPECTRE_DEATH6}
states[S_SPECTRE_DEATH6] = {SPR_SPCT, N, -1, nil, 0, 0, S_SPECTRE_DEATH6}

mobjinfo[MT_SPECTRE] = {
		--$Title Spectre
		--$Sprite SPCTA1
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1729,
        spawnstate = S_SPECTRE_STND,
        spawnhealth = 25, --ZE2 support will override this
        seestate = S_SPECTRE_WALK1,
        seesound = sfx_dptnt1,
        reactiontime = 0,
        painstate = S_SPECTRE_HURT,
        painsound = sfx_dphurt,
        meleestate = S_SPECTRE_MELEE1,
        deathstate = S_SPECTRE_DEATH1,
        xdeathstate = S_NULL,
        deathsound = sfx_dpdeth,
        speed = 30,
        radius = 23*FRACUNIT,
        height = 76*FRACUNIT,
        dispoffset = 0,
        mass = 100,
        activesound = sfx_None,
        flags = MF_ENEMY|MF_SHOOTABLE|MF_SPECIAL
}

--Spectre spawn chance on bathrooms
addHook("MapLoad", function(mapnum) 
	local spectre1_spawnchance
	local spectre2_spawnchance
	
	if (mapnum == 220) then
		spectre1_spawnchance = P_RandomChance(FRACUNIT/3)
		spectre2_spawnchance = P_RandomChance(FRACUNIT/3)
	end
	
	if spectre1_spawnchance then
		P_SpawnMobj(-3792*FRACUNIT, -6480*FRACUNIT, 760*FRACUNIT, MT_SPECTRE)
	end
	
	if spectre2_spawnchance then
		P_SpawnMobj(-2192*FRACUNIT, -6832*FRACUNIT, 760*FRACUNIT, MT_SPECTRE)
	end
end)

addHook("MobjSpawn", function(mobj) 
	if mobj and mobj.valid then
		mobj.angle = ANGLE_270
	end
end, MT_SPECTRE)

---------------Lost Soul

freeslot("MT_LOSTSOUL","S_LOSTSOUL_ACTION0","S_LOSTSOUL_ACTION1","S_LOSTSOUL_ACTION2",
		 "S_LOSTSOUL_RANDOMFLY1","S_LOSTSOUL_RANDOMFLY2","S_LOSTSOUL_RANDOMFLY3",
		 "S_LOSTSOUL_RANDOMFLY4","S_LOSTSOUL_RANDOMFLY5","S_LOSTSOUL_RANDOMFLY6",
		 "S_LOSTSOUL_RANDOMFLY7","S_LOSTSOUL_CHASE1","S_LOSTSOUL_CHASE2",
		 "S_LOSTSOUL_CHASE3","S_LOSTSOUL_CHASE4","S_LOSTSOUL_CHASE5","S_LOSTSOUL_CHASE6",
		 "S_LOSTSOUL_LUNGE1","S_LOSTSOUL_LUNGE2","S_LOSTSOUL_LUNGE3","S_LOSTSOUL_LUNGE4",
		 "S_LOSTSOUL_LUNGE5","S_LOSTSOUL_LUNGE6","S_LOSTSOUL_LUNGE7","S_LOSTSOUL_LUNGE8",
		 "S_LOSTSOUL_LUNGE9","S_LOSTSOUL_DEATH1","S_LOSTSOUL_DEATH2","S_LOSTSOUL_DEATH3",
		 "S_LOSTSOUL_DEATH4","S_LOSTSOUL_DEATH5","S_LOSTSOUL_DEATH6","S_LOSTSOUL_DEATH7",
		 "S_LOSTSOUL_DEATH8","S_LOSTSOUL_DEATH9","sfx_fre043","sfx_fre044","sfx_fre045",
		 "sfx_fre046","SPR_LSSL", "sfx_firxpl")

states[S_LOSTSOUL_ACTION0] = {SPR_LSSL, FF_FULLBRIGHT|B, 1, A_Look, 1, 0, S_LOSTSOUL_ACTION0}
states[S_LOSTSOUL_ACTION1] = {SPR_LSSL, FF_FULLBRIGHT|B, 1, A_MoveRelative, 0, 3, S_LOSTSOUL_ACTION1}
states[S_LOSTSOUL_ACTION2] = {SPR_LSSL, FF_FULLBRIGHT|B, 1, A_PlaySound, sfx_fre043, 1, S_LOSTSOUL_ACTION2}

states[S_LOSTSOUL_RANDOMFLY1] = {SPR_LSSL, FF_FULLBRIGHT|A, 1, A_ChangeAngleRelative, -360, 360, S_LOSTSOUL_RANDOMFLY2}
states[S_LOSTSOUL_RANDOMFLY2] = {SPR_LSSL, FF_FULLBRIGHT|A, 4, A_DualAction, S_LOSTSOUL_ACTION1, S_LOSTSOUL_ACTION2, S_LOSTSOUL_RANDOMFLY3}
states[S_LOSTSOUL_RANDOMFLY3] = {SPR_LSSL, FF_FULLBRIGHT|B, 4, A_DualAction, S_LOSTSOUL_ACTION0, S_LOSTSOUL_ACTION1, S_LOSTSOUL_RANDOMFLY4}
states[S_LOSTSOUL_RANDOMFLY4] = {SPR_LSSL, FF_FULLBRIGHT|C, 4, A_DualAction, S_LOSTSOUL_ACTION0, S_LOSTSOUL_ACTION1, S_LOSTSOUL_RANDOMFLY5}
states[S_LOSTSOUL_RANDOMFLY5] = {SPR_LSSL, FF_FULLBRIGHT|A, 4, A_DualAction, S_LOSTSOUL_ACTION0, S_LOSTSOUL_ACTION1, S_LOSTSOUL_RANDOMFLY6}
states[S_LOSTSOUL_RANDOMFLY6] = {SPR_LSSL, FF_FULLBRIGHT|B, 4, A_DualAction, S_LOSTSOUL_ACTION0, S_LOSTSOUL_ACTION1, S_LOSTSOUL_RANDOMFLY7}
states[S_LOSTSOUL_RANDOMFLY7] = {SPR_LSSL, FF_FULLBRIGHT|C, 4, A_DualAction, S_LOSTSOUL_ACTION0, S_LOSTSOUL_ACTION1, S_LOSTSOUL_RANDOMFLY1}

states[S_LOSTSOUL_CHASE1] = {SPR_LSSL, FF_FULLBRIGHT|A, 4, A_DualAction, S_LOSTSOUL_ACTION2, S_LOSTSOUL_CHASE2, S_LOSTSOUL_CHASE2}
states[S_LOSTSOUL_CHASE2] = {SPR_LSSL, FF_FULLBRIGHT|B, 4, A_Chase, 0, 0, S_LOSTSOUL_CHASE3}
states[S_LOSTSOUL_CHASE3] = {SPR_LSSL, FF_FULLBRIGHT|C, 4, A_Chase, 0, 0, S_LOSTSOUL_CHASE4}
states[S_LOSTSOUL_CHASE4] = {SPR_LSSL, FF_FULLBRIGHT|A, 4, A_Chase, 0, 0, S_LOSTSOUL_CHASE5}
states[S_LOSTSOUL_CHASE5] = {SPR_LSSL, FF_FULLBRIGHT|B, 4, A_Chase, 0, 0, S_LOSTSOUL_CHASE6}
states[S_LOSTSOUL_CHASE6] = {SPR_LSSL, FF_FULLBRIGHT|C, 4, A_Chase, 0, 0, S_LOSTSOUL_CHASE1}

states[S_LOSTSOUL_LUNGE1] = {SPR_LSSL, FF_FULLBRIGHT|D, 1, A_FaceTarget, 0, 0, S_LOSTSOUL_LUNGE2}
states[S_LOSTSOUL_LUNGE2] = {SPR_LSSL, FF_FULLBRIGHT|E, 2, A_PlaySound, sfx_fre045, 1, S_LOSTSOUL_LUNGE3}
states[S_LOSTSOUL_LUNGE3] = {SPR_LSSL, FF_FULLBRIGHT|D, 2, A_MoveRelative, 0, 30, S_LOSTSOUL_LUNGE4}
states[S_LOSTSOUL_LUNGE4] = {SPR_LSSL, FF_FULLBRIGHT|E, 2, nil, 0, 0, S_LOSTSOUL_LUNGE5}
states[S_LOSTSOUL_LUNGE5] = {SPR_LSSL, FF_FULLBRIGHT|D, 2, nil, 0, 0, S_LOSTSOUL_LUNGE6}
states[S_LOSTSOUL_LUNGE6] = {SPR_LSSL, FF_FULLBRIGHT|E, 2, nil, 0, 0, S_LOSTSOUL_LUNGE7}
states[S_LOSTSOUL_LUNGE7] = {SPR_LSSL, FF_FULLBRIGHT|D, 2, nil, 0, 0, S_LOSTSOUL_LUNGE8}
states[S_LOSTSOUL_LUNGE8] = {SPR_LSSL, FF_FULLBRIGHT|E, 2, nil, 0, 0, S_LOSTSOUL_LUNGE9}
states[S_LOSTSOUL_LUNGE9] = {SPR_LSSL, FF_FULLBRIGHT|D, 2, nil, 0, 0, S_LOSTSOUL_CHASE1}

states[S_LOSTSOUL_DEATH1] = {SPR_LSSL, G, 4, A_Scream, 0, 0, S_LOSTSOUL_DEATH2}
states[S_LOSTSOUL_DEATH2] = {SPR_LSSL, H, 4, A_Fall, 0, 0, S_LOSTSOUL_DEATH3}
states[S_LOSTSOUL_DEATH3] = {SPR_LSSL, I, 4, nil, 0, 0, S_LOSTSOUL_DEATH4}
states[S_LOSTSOUL_DEATH4] = {SPR_LSSL, J, 4, nil, 0, 0, S_LOSTSOUL_DEATH5}
states[S_LOSTSOUL_DEATH5] = {SPR_LSSL, K, 4, nil, 0, 0, S_LOSTSOUL_DEATH6}
states[S_LOSTSOUL_DEATH6] = {SPR_LSSL, L, 4, nil, 0, 0, S_LOSTSOUL_DEATH7}
states[S_LOSTSOUL_DEATH7] = {SPR_LSSL, M, 4, nil, 0, 0, S_LOSTSOUL_DEATH8}
states[S_LOSTSOUL_DEATH8] = {SPR_LSSL, N, 4, nil, 0, 0, S_LOSTSOUL_DEATH9}
states[S_LOSTSOUL_DEATH9] = {SPR_LSSL, O, 4, nil, 0, 0, S_NULL}


mobjinfo[MT_LOSTSOUL].npc_name = "Lost Soul"
mobjinfo[MT_LOSTSOUL].npc_spawnhealth = {10,15}
mobjinfo[MT_LOSTSOUL].npc_name_color = SKINCOLOR_ORANGE
mobjinfo[MT_LOSTSOUL].rubydrop = {4,6}
mobjinfo[MT_LOSTSOUL].forcedamage = 10
mobjinfo[MT_LOSTSOUL].forceknockback = 10*FU
mobjinfo[MT_LOSTSOUL].forceverticalknockback = 7*FU
mobjinfo[MT_LOSTSOUL].relativeknockback = true

mobjinfo[MT_LOSTSOUL] = {
		--$Title Lost Soul
		--$Sprite LSSLA1
		--$Category Doomed Corp
		--$Color 1
        doomednum = 1730,
        spawnstate = S_LOSTSOUL_RANDOMFLY1,
        spawnhealth = 1, --ZE2 support will override this
        seestate = S_LOSTSOUL_CHASE1,
        seesound = sfx_fre044,
        reactiontime = 3,
        deathstate = S_LOSTSOUL_DEATH1,
        xdeathstate = S_NULL,
        deathsound = sfx_firxpl,
		missilestate = S_LOSTSOUL_LUNGE1,
        speed = 16*FRACUNIT,
        radius = 25*FRACUNIT,
		painchance = 300,
        height = 50*FRACUNIT,
        dispoffset = 0,
        mass = 100,
        activesound = sfx_None,
        flags = MF_SPECIAL|MF_SHOOTABLE|MF_NOGRAVITY|MF_SLIDEME|MF_FLOAT|MF_ENEMY
}