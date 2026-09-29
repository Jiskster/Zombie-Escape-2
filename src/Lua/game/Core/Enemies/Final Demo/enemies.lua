
// Blue Crawla (Final Demo) Freeslot
freeslot(
"MT_OLDBLUECRAWLA",
"S_OPOS_STND",
"S_OPOS_RUN1",
"S_OPOS_RUN2",
"S_OPOS_RUN3",
"S_OPOS_RUN4",
"S_OPOS_RUN5",
"S_OPOS_RUN6",
"SPR_OPOS"
)

mobjinfo[MT_OLDBLUECRAWLA].npc_name = "Blue Crawla"
mobjinfo[MT_OLDBLUECRAWLA].npc_spawnhealth = {10,20}
mobjinfo[MT_OLDBLUECRAWLA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_OLDBLUECRAWLA].rubydrop = {2,4}
mobjinfo[MT_OLDBLUECRAWLA].painsound = sfx_dmpain
mobjinfo[MT_OLDBLUECRAWLA].forcedamage = 5
mobjinfo[MT_OLDBLUECRAWLA].relativeknockback = true
mobjinfo[MT_OLDBLUECRAWLA].forceknockback = 18*FRACUNIT

states[S_OPOS_STND] = {SPR_OPOS, A, 5, A_Look, 0, 0, S_OPOS_STND}
states[S_OPOS_RUN1] = {SPR_OPOS, A, 1, A_Chase, 0, 0, S_OPOS_RUN2}
states[S_OPOS_RUN2] = {SPR_OPOS, B, 1, A_Chase, 0, 0, S_OPOS_RUN3}
states[S_OPOS_RUN3] = {SPR_OPOS, C, 1, A_Chase, 0, 0, S_OPOS_RUN4}
states[S_OPOS_RUN4] = {SPR_OPOS, D, 1, A_Chase, 0, 0, S_OPOS_RUN5}
states[S_OPOS_RUN5] = {SPR_OPOS, E, 1, A_Chase, 0, 0, S_OPOS_RUN6}
states[S_OPOS_RUN6] = {SPR_OPOS, F, 1, A_Chase, 0, 0, S_OPOS_RUN1}

mobjinfo[MT_OLDBLUECRAWLA] = {
		--$Title Blue Crawla (Final Demo)
		--$Sprite OPOSA1
		--$Category Deep Cavern
		--$Color 1
	doomednum = 6000,
	spawnstate = S_OPOS_STND,
	seestate = S_OPOS_RUN1,
	painsound = sfx_dmpain,
	deathstate = S_XPLD_FLICKY,
	deathsound = sfx_pop,
	spawnhealth = 1,
	reactiontime = 32,
	painchance = 200,
	speed = 2,
	radius = 24*FRACUNIT,
	height = 32*FRACUNIT,
	mass = 100,
	flags = MF_ENEMY|MF_SPECIAL|MF_SHOOTABLE,
}

// Red Crawla (Final Demo) Freeslot
freeslot(
"MT_OLDREDCRAWLA",
"S_OSPS_STND",
"S_OSPS_RUN1",
"S_OSPS_RUN2",
"S_OSPS_RUN3",
"S_OSPS_RUN4",
"S_OSPS_RUN5",
"S_OSPS_RUN6",
"SPR_OSPS"
)

mobjinfo[MT_OLDREDCRAWLA].npc_name = "Red Crawla"
mobjinfo[MT_OLDREDCRAWLA].npc_spawnhealth = {45,80}
mobjinfo[MT_OLDREDCRAWLA].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_OLDREDCRAWLA].rubydrop = {12, 22}
mobjinfo[MT_OLDREDCRAWLA].painsound = sfx_dmpain
mobjinfo[MT_OLDREDCRAWLA].forcedamage = 15
mobjinfo[MT_OLDREDCRAWLA].relativeknockback = true
mobjinfo[MT_OLDREDCRAWLA].forceknockback = 22*FRACUNIT

states[S_OSPS_STND] = {SPR_OSPS, A, 5, A_Look, 0, 0, S_OSPS_STND}
states[S_OSPS_RUN1] = {SPR_OSPS, A, 1, A_Chase, 0, 0, S_OSPS_RUN2}
states[S_OSPS_RUN2] = {SPR_OSPS, B, 1, A_Chase, 0, 0, S_OSPS_RUN3}
states[S_OSPS_RUN3] = {SPR_OSPS, C, 1, A_Chase, 0, 0, S_OSPS_RUN4}
states[S_OSPS_RUN4] = {SPR_OSPS, D, 1, A_Chase, 0, 0, S_OSPS_RUN5}
states[S_OSPS_RUN5] = {SPR_OSPS, E, 1, A_Chase, 0, 0, S_OSPS_RUN6}
states[S_OSPS_RUN6] = {SPR_OSPS, F, 1, A_Chase, 0, 0, S_OSPS_RUN1}

mobjinfo[MT_OLDREDCRAWLA] = {
		--$Title Red Crawla (Final Demo)
		--$Sprite OSPSA1
		--$Category Deep Cavern
		--$Color 1
	doomednum = 6001,
	spawnstate = S_OSPS_STND,
	seestate = S_OSPS_RUN1,
	painsound = sfx_dmpain,
	deathstate = S_XPLD_FLICKY,
	deathsound = sfx_pop,
	spawnhealth = 1,
	reactiontime = 32,
	painchance = 170,
	speed = 3,
	radius = 24*FRACUNIT,
	height = 32*FRACUNIT,
	mass = 100,
	flags = MF_ENEMY|MF_SPECIAL|MF_SHOOTABLE,
}

// Big Floating MIne (Final Demo) Freeslot
freeslot(
"MT_OLDBIGMINE",
"S_OLDBIGMINE_IDLE",
"S_OLDBIGMINE_ALERT1",
"S_OLDBIGMINE_ALERT2",
"S_OLDBIGMINE_ALERT3",
"S_OLDBIGMINE_ALERT4",
"S_OLDBIGMINE_ALERT5",
"S_OLDBIGMINE_ALERT6",
"S_OLDBIGMINE_ALERT7",
"S_OLDBIGMINE_SET1",
"S_OLDBIGMINE_SET2",
"S_OLDBIGMINE_SET3",
"SPR_OMNE",
"sfx_ogbeep"
)

sfxinfo[sfx_ogbeep].caption = "old annoying beep"

mobjinfo[MT_OLDBIGMINE].npc_name = "Big Floating Mine"
mobjinfo[MT_OLDBIGMINE].npc_spawnhealth = 1
mobjinfo[MT_OLDBIGMINE].npc_name_color = SKINCOLOR_GREY
mobjinfo[MT_OLDBIGMINE].rubydrop = {1,3}
mobjinfo[MT_OLDBIGMINE].painsound = sfx_dmpain
mobjinfo[MT_OLDBIGMINE].forcedamage = 5
mobjinfo[MT_OLDBIGMINE].relativeknockback = true

states[S_OLDBIGMINE_IDLE] = {SPR_OMNE, A, 5, A_Look, 1, 0, S_OLDBIGMINE_ALERT1}
states[S_OLDBIGMINE_ALERT1] = {SPR_OMNE, B, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT2}
states[S_OLDBIGMINE_ALERT2] = {SPR_OMNE, C, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT3}
states[S_OLDBIGMINE_ALERT3] = {SPR_OMNE, D, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT4}
states[S_OLDBIGMINE_ALERT4] = {SPR_OMNE, E, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT5}
states[S_OLDBIGMINE_ALERT5] = {SPR_OMNE, E, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT6}
states[S_OLDBIGMINE_ALERT6] = {SPR_OMNE, E, 5, A_MineRange, 112, 0, S_OLDBIGMINE_ALERT7}
states[S_OLDBIGMINE_ALERT7] = {SPR_OMNE, F, 5, A_Look, 1, 0, S_OLDBIGMINE_IDLE}
states[S_OLDBIGMINE_SET1] = {SPR_OMNE, I, 25, A_Pain, 0, 0, S_OLDBIGMINE_SET2}
states[S_OLDBIGMINE_SET2] = {SPR_OMNE, I, 10, A_SetObjectFlags, MF_SHOOTABE, 1, S_OLDBIGMINE_SET3}
states[S_OLDBIGMINE_SET3] = {SPR_OMNE, I, 1, A_MineExplode, 0, 0, S_BIGMINE_BLAST1}

mobjinfo[MT_OLDBIGMINE] = {
		--$Title Big Floating Mine (Final Demo)
		--$Sprite OMNEA0
		--$Category Deep Cavern
		--$Color 1
	doomednum = 6002,
	spawnstate = S_OLDBIGMINE_IDLE,
	seestate = S_OLDBIGMINE_ALERT1,
	seesound = sfx_ogbeep,
	painsound = sfx_s3k86,
	meleestate = S_OLDBIGMINE_SET1,
	deathstate = S_OLDBIGMINE_SET2,
	deathsound = sfx_pop,
	spawnhealth = 1,
	reactiontime = 8,
	painchance = 0,
	speed = 1,
	radius = 38*FRACUNIT,
	height = 49*FRACUNIT,
	mass = MT_UWEXPLODE,
	activesound = sfx_ogbeep,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_SHOOTABLE|MF_ENEMY,
}
