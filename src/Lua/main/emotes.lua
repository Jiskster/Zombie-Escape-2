freeslot("MT_ZEMO_BUBBLE", "S_ZEMO_BUBBLE", "SPR_ZEMO")
freeslot("SPR_ZT00","SPR_ZT01", "SPR_ZT02", "SPR_ZT03", "SPR_ZT04", "SPR_ZT05")
freeslot("SPR_ZT06","SPR_ZT07", "SPR_ZT08", "SPR_ZT09", "SPR_ZT0A", "SPR_ZT0B")
freeslot("SPR_ZT0C","SPR_ZT0D", "SPR_ZT0E", "SPR_ZT0F", "SPR_ZT10", "SPR_ZT11")
freeslot("SPR_ZT12","SPR_ZT13", "SPR_ZT14")

freeslot("sfx_huhem", "sfx_vboom", "sfx_thwop", "sfx_heheha", "sfx_4ayo")
freeslot("sfx_syeah", "sfx_kohno", "sfx_yccom", "sfx_noiscr", "sfx_pepscr")
freeslot("sfx_actu", "sfx_memore", "sfx_dumba", "sfx_demoem", "sfx_whoinv")
freeslot("sfx_bruh", "sfx_haha1", "sfx_orchit")

mobjinfo[MT_ZEMO_BUBBLE] = {		
	doomednum = -1,
	spawnstate = S_ZEMO_BUBBLE,
	spawnhealth = 2000,
	radius = 9 *FRACUNIT,
	height = 9*FRACUNIT,
	dispoffset = 0,
	activesound = sfx_none,
	flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP,
	raisestate = S_NULL
}

states[S_ZEMO_BUBBLE] = {
	sprite = SPR_ZEMO,
	frame = FF_FULLBRIGHT|FF_TRANS50|A,
	nextstate = S_ZEMO_BUBBLE
}

ZE2.Emotes = {}

function ZE2:AddEmote(emote_spr, name, desc, sound)
	local id = #self.Emotes + 1
	self.Emotes[id] = {
		["Sprite"] = emote_spr,
		["Name"] = name,
		["Description"] = desc,
		["Sound"] = sound or 100,
	}
	
	print("Added ZE2 Emote: " + self.Emotes[#self.Emotes].Name +" ("+#self.Emotes+")" )
end

addHook("PlayerThink", function(player)
	if player.mo and player.mo.valid then
		player.emoteslots = $ or {
			1,
			2,
			3
		}
		player.emotetime = $ or 3*TICRATE
	end
end)

ZE2:AddEmote(SPR_ZT00, "Heal Me!", "Heal me NOW!")
ZE2:AddEmote(SPR_ZT01, "Huh?", "What the?..", sfx_huhem)
ZE2:AddEmote(SPR_ZT02, "Skull Emoji", "hell nah bruh", sfx_vboom)
ZE2:AddEmote(SPR_ZT03, "Sad Sponge", "me when when no 2.3", sfx_thwop)
ZE2:AddEmote(SPR_ZT04, "heheheha", "HE HE HE HA", sfx_heheha)
ZE2:AddEmote(SPR_ZT05, "AYO?", "bro said something mad sus", sfx_4ayo)
ZE2:AddEmote(SPR_ZT06, "HAHA ONE!", "ONE!", sfx_haha1)
ZE2:AddEmote(SPR_ZT07, "sexysonic", "oh yeah", sfx_orchit)
ZE2:AddEmote(SPR_ZT08, "insanesonic", "memory card", sfx_memore)
ZE2:AddEmote(SPR_ZT09, "peppino scream", "italian mating call", sfx_pepscr)
ZE2:AddEmote(SPR_ZT0A, "noise scream", "noid mating call", sfx_noiscr)
ZE2:AddEmote(SPR_ZT0B, "chaos emeralds?", "did you get those chaos emeralds?", sfx_demoem)
ZE2:AddEmote(SPR_ZT0C, "sonic yeah!", "YEAH", sfx_syeah)
ZE2:AddEmote(SPR_ZT0D, "tails slang", "you can count on me", sfx_yccom)
ZE2:AddEmote(SPR_ZT0E, "knuckles thing", "oh no", sfx_kohno)
ZE2:AddEmote(SPR_ZT0F, "dumbass", "scoutdumbass", sfx_dumba)
ZE2:AddEmote(SPR_ZT10, "nerd emoji", "ackktually!", sfx_actu)
ZE2:AddEmote(SPR_ZT11, "who invited this kid", "oh my god who invited this kid!", sfx_whoinv)
ZE2:AddEmote(SPR_ZT12, "bruh", "BRUH", sfx_bruh)
ZE2:AddEmote(SPR_ZT13, "The zombies will be back", "source: trust me", sfx_inf1)
ZE2:AddEmote(SPR_ZT13, "You have been enslaved by the zombies", "1865", sfx_inf2)

COM_AddCommand("z_emote", function(player, emotenum)
	if player.mo and player.mo.valid 
	and player.playerstate ~= PST_DEAD and
	netgame and multiplayer then
		local emotenum_tonum = tonumber(emotenum)
		if not ZE2.Emotes[emotenum_tonum] then
			CONS_Printf(player, "Invalid Emote: ("+emotenum_tonum+")")
			return
		end
		if not(player.emotebubble) and not player.lastemotepress then
			player.lastemotepress = (TICRATE*3 + 25)
			player.mo.emotebubble = P_SpawnMobj(player.mo.x,player.mo.y,player.mo.z+player.mo.height,MT_ZEMO_BUBBLE)
			local ebub = player.mo.emotebubble
			local slotchosen = player.emoteslots[emotenum_tonum]
			ebub.target = player.mo
			ebub.isemotebubble = true
			
			ebub.sprite = ZE2.Emotes[slotchosen].Sprite
			P_SetScale(ebub, ebub.scale/4)
			S_StartSound(player.mo,ZE2.Emotes[slotchosen].Sound)
		end
	end
end)

COM_AddCommand("z_emotelist", function(player)
	for i,v in ipairs(ZE2.Emotes) do
		CONS_Printf(player,"\x82\+ (\$i\): \$v.Name\")
		CONS_Printf(player,"\x88\| Description: \$v.Description\")
	end
end)

COM_AddCommand("z_setemote", function(player, slot, emote)
	if slot == nil and emote == nil then
		CONS_Printf(player,"z_setemote <slot> <emotenumber>: Sets your slot to an emote.")
		return
	end
	if not(slot) or tonumber(slot) > 3 or tonumber(slot) < 1 then
		CONS_Printf(player,"Slot must be a valid number. And between 1 - 3")
		return
	end
	
	if ZE2.Emotes[tonumber(emote)] then
		player.emoteslots[tonumber(slot)] = tonumber(emote)
		CONS_Printf(player,"Slot \$tonumber(slot)\ replaced \$ZE2.Emotes[tonumber(emote)].Name\")
		return
	else
		CONS_Printf(player,"Invalid Emote.")
		return
	end
end)

addHook("PlayerThink", function(player)
	if player.lastemotepress then
		player.lastemotepress = $ - 1
	end
	if player["ze2_info"].pregamemenu_active then
		return
	end
	if (player.cmd.buttons & BT_WEAPONMASK) == 1 then
		COM_BufInsertText(player, "z_emote 1")
	end
	
	if (player.cmd.buttons & BT_WEAPONMASK) == 2 then
		COM_BufInsertText(player, "z_emote 2")
	end
	
	if (player.cmd.buttons & BT_WEAPONMASK) == 3 then
		COM_BufInsertText(player, "z_emote 3")
	end
end)

addHook("MobjThinker", function(mobj)
	if mobj.isemotebubble ~= true then return end
	mobj.em_inc = $ or 0
	mobj.em_inc = $ + 1
	if mobj.target and mobj.target.valid and mobj.target.player then
		P_MoveOrigin(mobj, mobj.target.x, mobj.target.y, mobj.target.z+mobj.target.height)
	end
	if mobj.target and mobj.target.player.emotetime then
		if mobj.em_inc > (mobj.target.player.emotetime + 10) then
			mobj.target.emotebubble = nil
			P_RemoveMobj(mobj)
			return
		end
	else
		if mobj and mobj.valid  then
			mobj.target.emotebubble = nil
			P_RemoveMobj(mobj)
			return
		end
	end
	if mobj.target and mobj.target.player.emotetime
		if mobj.em_inc > mobj.target.player.emotetime then
			mobj.scale = $/2
		end
	end
end)
