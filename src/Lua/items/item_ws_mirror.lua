freeslot("MT_MIRRORCLONE", "sfx_mrr12")
sfxinfo[sfx_mrr12].caption="W's Mirror"

mobjinfo[MT_MIRRORCLONE] = {
    doomednum = -1,
    spawnstate = S_PLAY_STND,
    spawnhealth = 1,
    radius = 32*FRACUNIT,
    height = 48*FRACUNIT,
	flags = MF_SHOOTABLE,
}

mobjinfo[MT_MIRRORCLONE].npc_name = "Mirror Clone"
mobjinfo[MT_MIRRORCLONE].npc_spawnhealth = {100,100}

local function flashpmo(pmo, source)
	local thok = P_SpawnMobjFromMobj(source,0,0,0,MT_THOK)
	thok.color = source.color
	thok.fuse = 17
	ZE2:SetDamageFadeAnim(pmo.player, 5*TICRATE)
	P_Thrust(pmo, source.angle, 180*FRACUNIT)
	S_StartSound(pmo, sfx_bewar2)
	P_SetScale(thok,thok.scale*3)
	P_RemoveMobj(source)
end

local w_mirror = ZE2:CreateItem("W's mirror", {
	icon = "MIRRORIND",
	firerate = TICRATE*5,
	sound = sfx_mrr12,
	limited = true,
	count = 3,
	price = 110,
	color = SKINCOLOR_AETHER,
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
		mirrorclone.mobjteam = player["ze2_info"].team
	end
})

addHook("MobjCollide", function(mo,toucher)
	if mo.mobjteam then
		if toucher.player then
			if toucher.player["ze2_info"].team == mo.mobjteam then
				return false
			end
		elseif toucher.mobjteam and (toucher.flags & MF_MISSILE) then
			if toucher.mobjteam == mo.mobjteam then
				return false
			end
		end
	end
end, MT_MIRRORCLONE)

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid) then return end
	
	if mo.mirrorclone_flashing then
		mo.flags2 = $ ^^ MF2_DONTDRAW
		
		mo.mirrorclone_flashing = $ - 1
		
		if not mo.mirrorclone_flashing then
			mo.flags2 = $ & ~MF2_DONTDRAW
		end
	end
end, MT_MIRRORCLONE)

addHook("ShouldDamage", function(mo, inf, src)
	local attacker
	
	if not mo.valid then return end
	if mo.mirrorclone_flashing then return false end
	
	if inf and inf.player then
		attacker = inf
	elseif src and src.player then
		attacker = src
	end
	
	if attacker then
		mo.mirrorclone_flashing = ZE2.survinvtics.value
		S_StartSound(mo, sfx_s3kb9)
	end
end, MT_MIRRORCLONE)

addHook("MobjDeath", function(mo, inf, src)
	local attacker
	
	if inf and inf.player then
		attacker = inf
	elseif src and src.player then
		attacker = src
	end
	
	if attacker then
		flashpmo(attacker, mo)
	end
end, MT_MIRRORCLONE)

ZE2:RegisterShopItem(w_mirror)