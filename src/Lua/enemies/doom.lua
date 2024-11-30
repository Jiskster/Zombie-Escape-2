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

--------------------------ARCH-VILE (SCRAPPED)

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

---------------Lost Soul (SCRAPPED)