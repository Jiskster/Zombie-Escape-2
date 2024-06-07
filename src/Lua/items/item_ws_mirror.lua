freeslot("MT_MIRRORCLONE", "sfx_mrr12")
sfxinfo[sfx_mrr12].caption="W's Mirror"

mobjinfo[MT_MIRRORCLONE] = {
    doomednum = -1,
    spawnstate = S_PLAY_STND,
    spawnhealth = 1,
    radius = 32*FRACUNIT,
    height = 48*FRACUNIT,
	flags = MF_SOLID,
}

mobjinfo[MT_MIRRORCLONE].npc_name = "Mirror Clone"
mobjinfo[MT_MIRRORCLONE].npc_spawnhealth = {100,100}

ZE2:CreateItem("W's mirror", {
	icon = "MIRRORIND",
	firerate = TICRATE*5,
	sound = sfx_mrr12,
	limited = true,
	count = 5,
	price = 230,
	ontrigger = function(player)
		local mirrorclone = P_SpawnMobjFromMobj(player.mo,0,0,0,MT_MIRRORCLONE)
		mirrorclone.target = player.mo
		mirrorclone.skin = player.mo.skin
		mirrorclone.color = player.mo.color
		mirrorclone.health = player.mo.health
		mirrorclone.maxhealth = player.mo.maxhealth
		mirrorclone.alias = player.name
		mirrorclone.angle = player.mo.angle
		mirrorclone.forcedamage = ZE2:FetchInventorySlot(player).damage
	end
})

addHook("MobjCollide", function(mo,pmo)
	if pmo.player then
		if pmo.skin == "zzombie" then
			local thok = P_SpawnMobjFromMobj(mo,0,0,0,MT_THOK)
			thok.color = mo.color
			thok.fuse = 17
			P_FlashPal(pmo.player, 3, 5*TICRATE)
			P_Thrust(pmo, mo.angle, 180*FRACUNIT)
			S_StartSound(pmo, sfx_bewar2)
			P_SetScale(thok,thok.scale*3)
			P_RemoveMobj(mo)
		else
			return false
		end
	end
end, MT_MIRRORCLONE)