
// Gold Crawla Freeslot
freeslot( 
"MT_GOLDCRAWLA", 
"S_GOSS_STND",
"S_GOSS_RUN1",
"S_GOSS_RUN2",
"S_GOSS_RUN3",
"S_GOSS_RUN4",
"S_GOSS_RUN5",
"S_GOSS_RUN6",
"SPR_GOSS"
)

mobjinfo[MT_BLUECRAWLA].npc_name = "Blue Crawla"
mobjinfo[MT_BLUECRAWLA].npc_spawnhealth = {12,23}
mobjinfo[MT_BLUECRAWLA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_BLUECRAWLA].rubydrop = {2,4}
mobjinfo[MT_BLUECRAWLA].painsound = sfx_dmpain
mobjinfo[MT_BLUECRAWLA].forcedamage = 10
mobjinfo[MT_BLUECRAWLA].forceknockback = 30*FU
mobjinfo[MT_BLUECRAWLA].forceverticalknockback = 10*FU
mobjinfo[MT_BLUECRAWLA].relativeknockback = true

mobjinfo[MT_REDCRAWLA].npc_name = "Red Crawla"
mobjinfo[MT_REDCRAWLA].npc_spawnhealth = {30,45}
mobjinfo[MT_REDCRAWLA].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_REDCRAWLA].rubydrop = {3,5}
mobjinfo[MT_REDCRAWLA].painsound = sfx_dmpain
mobjinfo[MT_REDCRAWLA].forcedamage = 20
mobjinfo[MT_REDCRAWLA].forceknockback = 50*FU -- relativeknockback
mobjinfo[MT_REDCRAWLA].forceverticalknockback = 10*FU
mobjinfo[MT_REDCRAWLA].relativeknockback = true

mobjinfo[MT_GOLDCRAWLA] = {
	doomednum = -1,
	spawnstate = S_GOSS_STND,
	seestate = S_GOSS_RUN1,
	deathstate = S_XPLD_FLICKY,
	deathsound = sfx_pop,
	spawnhealth = 1,
	reactiontime = 32,
	painchance = 170,
	speed = 10,
	radius = 24*FRACUNIT,
	height = 32*FRACUNIT,
	mass = 100,
	flags = MF_ENEMY|MF_SPECIAL|MF_SHOOTABLE,
}

mobjinfo[MT_GOLDCRAWLA].npc_name = "Gold Crawla"
mobjinfo[MT_GOLDCRAWLA].npc_spawnhealth = {150,185}
mobjinfo[MT_GOLDCRAWLA].npc_name_color = SKINCOLOR_GOLD
mobjinfo[MT_GOLDCRAWLA].rubydrop = {70,90}
mobjinfo[MT_GOLDCRAWLA].painsound = sfx_dmpain

states[S_GOSS_STND] = {SPR_GOSS, A, 5, A_Look, 0, 0, S_GOSS_STND}
states[S_GOSS_RUN1] = {SPR_GOSS, A, 1, A_Chase, 0, 0, S_GOSS_RUN2}
states[S_GOSS_RUN2] = {SPR_GOSS, B, 1, A_Chase, 0, 0, S_GOSS_RUN3}
states[S_GOSS_RUN3] = {SPR_GOSS, C, 1, A_Chase, 0, 0, S_GOSS_RUN4}
states[S_GOSS_RUN4] = {SPR_GOSS, D, 1, A_Chase, 0, 0, S_GOSS_RUN5}
states[S_GOSS_RUN5] = {SPR_GOSS, E, 1, A_Chase, 0, 0, S_GOSS_RUN6}
states[S_GOSS_RUN6] = {SPR_GOSS, F, 1, A_Chase, 0, 0, S_GOSS_RUN1}

mobjinfo[MT_GOLDBUZZ].npc_name = "Gold Buzz"
mobjinfo[MT_GOLDBUZZ].npc_spawnhealth = {3,8}
mobjinfo[MT_GOLDBUZZ].npc_name_color = SKINCOLOR_GOLD
mobjinfo[MT_GOLDBUZZ].rubydrop = {1,3}
mobjinfo[MT_GOLDBUZZ].painsound = sfx_dmpain
mobjinfo[MT_GOLDBUZZ].forcedamage = 4
mobjinfo[MT_GOLDBUZZ].forceknockback = 10*FU
mobjinfo[MT_GOLDBUZZ].relativeknockback = true

mobjinfo[MT_REDBUZZ].npc_name = "Red Buzz"
mobjinfo[MT_REDBUZZ].npc_spawnhealth = {10,17}
mobjinfo[MT_REDBUZZ].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_REDBUZZ].rubydrop = {2,4}
mobjinfo[MT_REDBUZZ].painsound = sfx_dmpain
mobjinfo[MT_REDBUZZ].forcedamage = 6
mobjinfo[MT_REDBUZZ].forceknockback = 15*FU
mobjinfo[MT_REDBUZZ].relativeknockback = true

mobjinfo[MT_PENGUINATOR].npc_name = "Penguinator"
mobjinfo[MT_PENGUINATOR].npc_spawnhealth = {10,20}
mobjinfo[MT_PENGUINATOR].npc_name_color = SKINCOLOR_ICY
mobjinfo[MT_PENGUINATOR].rubydrop = {5,8}
mobjinfo[MT_PENGUINATOR].painsound = sfx_dmpain
mobjinfo[MT_PENGUINATOR].forcedamage = 5
mobjinfo[MT_PENGUINATOR].forceknockback = 30*FU -- relativeknockback
mobjinfo[MT_PENGUINATOR].forceverticalknockback = 20*FU
mobjinfo[MT_PENGUINATOR].relativeknockback = true

mobjinfo[MT_GOOMBA].npc_name = "Goomba"
mobjinfo[MT_GOOMBA].npc_spawnhealth = {10,15}
mobjinfo[MT_GOOMBA].npc_name_color = SKINCOLOR_ORANGE
mobjinfo[MT_GOOMBA].rubydrop = {2,2}
mobjinfo[MT_GOOMBA].forcedamage = 10
mobjinfo[MT_GOOMBA].forceknockback = 20*FU -- relativeknockback
mobjinfo[MT_GOOMBA].forceverticalknockback = 6*FU
mobjinfo[MT_GOOMBA].relativeknockback = true

mobjinfo[MT_BLUEGOOMBA].npc_name = "Blue Goomba"
mobjinfo[MT_BLUEGOOMBA].npc_spawnhealth = {10,15}
mobjinfo[MT_BLUEGOOMBA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_BLUEGOOMBA].rubydrop = {2,2}
mobjinfo[MT_BLUEGOOMBA].forcedamage = 10
mobjinfo[MT_BLUEGOOMBA].forceknockback = 20*FU -- relativeknockback
mobjinfo[MT_BLUEGOOMBA].forceverticalknockback = 6*FU
mobjinfo[MT_BLUEGOOMBA].relativeknockback = true

/*
local function GoldCrawlaRNG(mobj)
	if gametype ~= GT_ZE2 then return end
	if P_RandomChance( FRACUNIT/(75-(ZE2.PlayerCount()*2)) ) then
		P_SpawnMobjFromMobj(mobj,0,0,0,MT_GOLDCRAWLA)
		mobj.fuse = 1
		return true
	end
end

addHook("MobjSpawn", GoldCrawlaRNG, MT_BLUECRAWLA)
addHook("MobjSpawn", GoldCrawlaRNG, MT_REDCRAWLA)
*/