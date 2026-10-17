mobjinfo[MT_BLUECRAWLA].npc_name = "Blue Crawla"
mobjinfo[MT_BLUECRAWLA].npc_spawnhealth = {12,23}
mobjinfo[MT_BLUECRAWLA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_BLUECRAWLA].rubydrop = {2,4}
mobjinfo[MT_BLUECRAWLA].painsound = sfx_dmpain
mobjinfo[MT_BLUECRAWLA].forcedamage = 10
mobjinfo[MT_BLUECRAWLA].relativeknockback = true
mobjinfo[MT_BLUECRAWLA].forceknockback = 17*FRACUNIT

mobjinfo[MT_REDCRAWLA].npc_name = "Red Crawla"
mobjinfo[MT_REDCRAWLA].npc_spawnhealth = {50,85}
mobjinfo[MT_REDCRAWLA].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_REDCRAWLA].rubydrop = {15, 25}
mobjinfo[MT_REDCRAWLA].painsound = sfx_dmpain
mobjinfo[MT_REDCRAWLA].forcedamage = 20
mobjinfo[MT_REDCRAWLA].relativeknockback = true
mobjinfo[MT_REDCRAWLA].forceknockback = 22*FRACUNIT

local function CrawlaDropItems(mobj, red)
	if not mobj or not mobj.valid then return end
	
	if P_RandomChance(FRACUNIT / 20) then
		xSlinger.SpawnItemDrop(mobj, "apple", false)
	elseif red and P_RandomChance(FRACUNIT / 100) then
		xSlinger.SpawnItemDrop(mobj, "energy_drink", false)
	end
end

addHook("MobjDeath", function(mobj, inflictor, source, damagetype)
	if not inflictor and not source then return end
	if (inflictor and not inflictor.player) and (source and not source.player) then return end
	CrawlaDropItems(mobj, false)
end, MT_BLUECRAWLA)

addHook("MobjDeath", function(mobj, inflictor, source, damagetype)
	if not inflictor and not source then return end
	if (inflictor and not inflictor.player) and (source and not source.player) then return end
	CrawlaDropItems(mobj, true)
end, MT_REDCRAWLA)

mobjinfo[MT_GOLDBUZZ].npc_name = "Gold Buzz"
mobjinfo[MT_GOLDBUZZ].npc_spawnhealth = {3,8}
mobjinfo[MT_GOLDBUZZ].npc_name_color = SKINCOLOR_GOLD
mobjinfo[MT_GOLDBUZZ].rubydrop = {1,3}
mobjinfo[MT_GOLDBUZZ].painsound = sfx_dmpain
mobjinfo[MT_GOLDBUZZ].relativeknockback = true
mobjinfo[MT_GOLDBUZZ].forceknockback = 17*FRACUNIT

mobjinfo[MT_REDBUZZ].npc_name = "Red Buzz"
mobjinfo[MT_REDBUZZ].npc_spawnhealth = {10,17}
mobjinfo[MT_REDBUZZ].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_REDBUZZ].rubydrop = {2,4}
mobjinfo[MT_REDBUZZ].painsound = sfx_dmpain
mobjinfo[MT_REDBUZZ].relativeknockback = true
mobjinfo[MT_REDBUZZ].forceknockback = 22*FRACUNIT

mobjinfo[MT_ROBOHOOD].npc_name = "Robo-Hood"
mobjinfo[MT_ROBOHOOD].npc_spawnhealth = {10,15}
mobjinfo[MT_ROBOHOOD].npc_name_color = SKINCOLOR_GREEN
mobjinfo[MT_ROBOHOOD].rubydrop = {6,8}
mobjinfo[MT_ROBOHOOD].painsound = sfx_dmpain
mobjinfo[MT_ROBOHOOD].forcedamage = 10
mobjinfo[MT_ROBOHOOD].relativeknockback = true
mobjinfo[MT_ROBOHOOD].forceknockback = 12*FRACUNIT

mobjinfo[MT_CRUSHSTACEAN].npc_name = "Crushstacean"
mobjinfo[MT_CRUSHSTACEAN].npc_spawnhealth = {10,15}
mobjinfo[MT_CRUSHSTACEAN].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_CRUSHSTACEAN].rubydrop = {6,8}
mobjinfo[MT_CRUSHSTACEAN].painsound = sfx_dmpain
mobjinfo[MT_CRUSHSTACEAN].forcedamage = 10
mobjinfo[MT_CRUSHSTACEAN].relativeknockback = true
mobjinfo[MT_CRUSHSTACEAN].forceknockback = 14*FRACUNIT
mobjinfo[MT_CRUSHCLAW].forcedamage = 10
mobjinfo[MT_CRUSHCLAW].forceknockback = 60*FRACUNIT

mobjinfo[MT_SKIM].npc_name = "Skim"
mobjinfo[MT_SKIM].npc_spawnhealth = {5,5}
mobjinfo[MT_SKIM].npc_name_color = SKINCOLOR_GREY
mobjinfo[MT_SKIM].rubydrop = {5,7}
mobjinfo[MT_SKIM].painsound = sfx_dmpain
mobjinfo[MT_SKIM].forcedamage = 10
mobjinfo[MT_SKIM].relativeknockback = true
mobjinfo[MT_SKIM].forceknockback = 12*FRACUNIT

mobjinfo[MT_JETJAW].npc_name = "Jet Jaw"
mobjinfo[MT_JETJAW].npc_spawnhealth = {4,5}
mobjinfo[MT_JETJAW].npc_name_color = SKINCOLOR_YELLOW
mobjinfo[MT_JETJAW].rubydrop = {4,6}
mobjinfo[MT_JETJAW].painsound = sfx_dmpain
mobjinfo[MT_JETJAW].forcedamage = 4
mobjinfo[MT_JETJAW].relativeknockback = true
mobjinfo[MT_JETJAW].forceknockback = 15*FRACUNIT

mobjinfo[MT_EGGGUARD].npc_name = "Egg Guard"
mobjinfo[MT_EGGGUARD].npc_spawnhealth = {5,5}
mobjinfo[MT_EGGGUARD].npc_name_color = SKINCOLOR_LAVENDER
mobjinfo[MT_EGGGUARD].rubydrop = {5,7}
mobjinfo[MT_EGGGUARD].painsound = sfx_dmpain
mobjinfo[MT_EGGGUARD].forcedamage = 10
mobjinfo[MT_EGGGUARD].forceknockback = 10*FRACUNIT

mobjinfo[MT_EGGSHIELD].flags = MF_SPECIAL|MF_NOGRAVITY|MF_SHOOTABLE

mobjinfo[MT_FACESTABBER].npc_name = "Lance-a-bot"
mobjinfo[MT_FACESTABBER].npc_spawnhealth = {80,150}
mobjinfo[MT_FACESTABBER].npc_name_color = SKINCOLOR_RED
mobjinfo[MT_FACESTABBER].rubydrop = {9,12}
mobjinfo[MT_FACESTABBER].painsound = sfx_dmpain
mobjinfo[MT_FACESTABBER].forcedamage = 15
mobjinfo[MT_FACESTABBER].forceknockback = 40*FRACUNIT

mobjinfo[MT_PENGUINATOR].npc_name = "Penguinator"
mobjinfo[MT_PENGUINATOR].npc_spawnhealth = {10,20}
mobjinfo[MT_PENGUINATOR].npc_name_color = SKINCOLOR_ICY
mobjinfo[MT_PENGUINATOR].rubydrop = {5,8}
mobjinfo[MT_PENGUINATOR].painsound = sfx_dmpain
mobjinfo[MT_PENGUINATOR].forcedamage = 5
mobjinfo[MT_PENGUINATOR].forceknockback = 17*FRACUNIT

mobjinfo[MT_GOOMBA].npc_name = "Goomba"
mobjinfo[MT_GOOMBA].npc_spawnhealth = {10,15}
mobjinfo[MT_GOOMBA].npc_name_color = SKINCOLOR_ORANGE
mobjinfo[MT_GOOMBA].rubydrop = {2,2}
mobjinfo[MT_GOOMBA].forcedamage = 10
mobjinfo[MT_GOOMBA].relativeknockback = true
mobjinfo[MT_GOOMBA].forceknockback = 17*FRACUNIT

mobjinfo[MT_BLUEGOOMBA].npc_name = "Blue Goomba"
mobjinfo[MT_BLUEGOOMBA].npc_spawnhealth = {10,15}
mobjinfo[MT_BLUEGOOMBA].npc_name_color = SKINCOLOR_BLUE
mobjinfo[MT_BLUEGOOMBA].rubydrop = {2,2}
mobjinfo[MT_BLUEGOOMBA].forcedamage = 10
mobjinfo[MT_BLUEGOOMBA].relativeknockback = true
mobjinfo[MT_BLUEGOOMBA].forceknockback = 22*FRACUNIT

-- Hazards
mobjinfo[MT_PROXIMITYTNT].relativeknockback = true
mobjinfo[MT_PROXIMITYTNT].forceknockback = 60*FRACUNIT

-- Turret
mobjinfo[MT_TURRETLASER].forcedamage = 20
mobjinfo[MT_TURRETLASER].forceknockback = 30*FRACUNIT