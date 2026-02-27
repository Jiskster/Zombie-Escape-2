freeslot("MT_ZEMO_BUBBLE", "S_ZEMO_BUBBLE", "SPR_ZEMO")
freeslot("SPR_ZT00","SPR_ZT01", "SPR_ZT02", "SPR_ZT03", "SPR_ZT04", "SPR_ZT05")
freeslot("SPR_ZT06","SPR_ZT07", "SPR_ZT08", "SPR_ZT09", "SPR_ZT0A", "SPR_ZT0B")
freeslot("SPR_ZT0C","SPR_ZT0D", "SPR_ZT0E", "SPR_ZT0F", "SPR_ZT10", "SPR_ZT11")
freeslot("SPR_ZT12","SPR_ZT13", "SPR_ZT14", "SPR_ZT15", "SPR_ZT16", "SPR_ZT17")
freeslot("SPR_ZT18")

freeslot("sfx_huhem", "sfx_vboom", "sfx_thwop", "sfx_heheha", "sfx_4ayo")
freeslot("sfx_syeah", "sfx_kohno", "sfx_yccom", "sfx_noiscr", "sfx_pepscr")
freeslot("sfx_actu", "sfx_memore", "sfx_dumba", "sfx_demoem", "sfx_whoinv")
freeslot("sfx_bruh", "sfx_haha1", "sfx_orchit", "sfx_wtsig2", "sfx_mrjisk")
freeslot("sfx_csgogo", "sfx_csflbk")
freeslot("sfx_ddblud")
sfxinfo[sfx_huhem].caption = "\"Huh?\""
sfxinfo[sfx_vboom].caption = "Vine Boom"
sfxinfo[sfx_thwop].caption = "Bwoop"
sfxinfo[sfx_heheha].caption = "He-he-he-haw!"
sfxinfo[sfx_4ayo].caption = "\"Ayo?!\""
sfxinfo[sfx_syeah].caption = "\"Yeah!\""
sfxinfo[sfx_kohno].caption = "\"Oh no!\""
sfxinfo[sfx_yccom].caption = "\"You Can Count On Me!\""
sfxinfo[sfx_noiscr].caption = "Noise screaming"
sfxinfo[sfx_pepscr].caption = "Pepino screaming"
sfxinfo[sfx_actu].caption = "\"Errm... Actually\""
sfxinfo[sfx_memore].caption = "\"No Space In Memory Card\""
sfxinfo[sfx_dumba].caption = "\"Dumbass!\""
sfxinfo[sfx_demoem].caption = "\"Did You Get Those Chaos Emeralds?\""
sfxinfo[sfx_whoinv].caption = "\"Oh My God Bro...\""
sfxinfo[sfx_bruh].caption = "\"BRUH!\""
sfxinfo[sfx_haha1].caption = "\"Ha ha, ha!\""
sfxinfo[sfx_orchit].caption = "Orchesta Hit"
sfxinfo[sfx_wtsig2].caption = "\"What The Sigma?\""
sfxinfo[sfx_mrjisk].caption = "\"Mr. Jisk\""
sfxinfo[sfx_csgogo].caption = "\"Go, Go, Go!\""
sfxinfo[sfx_csflbk].caption = "\"Team Fallback!\""
sfxinfo[sfx_ddblud].caption = "\"What Is Doing On The Calculator?\""

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

function ZE2:AddEmote(emote_spr, name, desc, sound, team)
	local id = #self.Emotes + 1
	self.Emotes[id] = {
		["Sprite"] = emote_spr,
		["Name"] = name,
		["Description"] = desc,
		["Sound"] = sound or 100,
		["Team"] = team or 0,
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
ZE2:AddEmote(SPR_ZT13, "The zombies will be back", "source: trust me", sfx_inf1, 2)
ZE2:AddEmote(SPR_ZT13, "You have been enslaved by the zombies", "1865", sfx_inf2, 2)
ZE2:AddEmote(SPR_ZT14, "Umm what the sigma", "siggmaa", sfx_wtsig2)
ZE2:AddEmote(SPR_ZT15, "Mister Jisk", "mrjisk", sfx_mrjisk)
ZE2:AddEmote(SPR_ZT16, "GO GO GO!", "Counter Strike 1.6 radio command", sfx_csgogo)
ZE2:AddEmote(SPR_ZT17, "TEAM FALL BACK!", "Counter Strike 1.6 radio command", sfx_csflbk)
ZE2:AddEmote(SPR_ZT18, "einstein", "what is this diddy blud doing on the calculator", sfx_ddblud)

COM_AddCommand("z_emote", function(player, emotenum)
	if player.mo and player.mo.valid 
	and player.playerstate ~= PST_DEAD and
	netgame and multiplayer then
		local emotenum_tonum = tonumber(emotenum)
		
		if not ZE2.Emotes[emotenum_tonum] then
			CONS_Printf(player, "Invalid Emote: ("+emotenum_tonum+")")
			return
		end
		
		if ZE2.Emotes[emotenum_tonum].Team then
			if player.mo.team ~= ZE2.Emotes[emotenum_tonum].Team then
				CONS_Printf(player, "Emote "..emotenum_tonum.." is locked to Team "..ZE2.Emotes[emotenum_tonum].Team)
				return
			end
		end
		
		if not(player.emotebubble) and not player.lastemotepress then
			player.lastemotepress = (TICRATE*3 + 25)
			player.mo.emotebubble = P_SpawnMobj(player.mo.x,player.mo.y,player.mo.z+player.mo.height,MT_ZEMO_BUBBLE)
			local ebub = player.mo.emotebubble
			ebub.target = player.mo
			ebub.isemotebubble = true
			
			ebub.sprite = ZE2.Emotes[emotenum_tonum].Sprite
			P_SetScale(ebub, ebub.scale/4)
			S_StartSound(player.mo,ZE2.Emotes[emotenum_tonum].Sound)
		end
	end
end)

COM_AddCommand("z_emotelist", function(player, page)
	local foundemote = false
	page = max(tonumber($) or 1, 1)
	
	CONS_Printf(player,"\x8A\#PAGE \$page\# (z_emotelist <page>)")
	for i=((page-1)*10)+1,(page)*10 do
		if ZE2.Emotes[i] then
			local name = ZE2.Emotes[i].Name
			local description = ZE2.Emotes[i].Description
			
			if name and description then
				CONS_Printf(player,"\x82\+ (\$i\): \$name\")
				CONS_Printf(player,"\x80\| Description: \$description\")
			end
		end
	end
end)

COM_AddCommand("z_setemote", function(player, slot, emote)
	if slot == nil and emote == nil then
		CONS_Printf(player,"z_setemote <slot> <emotenumber>: Sets your slot to an emote.")
		return
	end
	if not(slot) or not tonumber(slot) or not tonumber(emote) or tonumber(slot) > 3 or tonumber(slot) < 1 then
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
end)

addHook("MobjThinker", function(mobj)
	if mobj.isemotebubble ~= true then 
		return 
	end
	
	mobj.em_inc = $ or 0
	mobj.em_inc = $ + 1
	
	if mobj.target and mobj.target.valid and mobj.target.player then
		P_MoveOrigin(mobj, mobj.target.x, mobj.target.y, mobj.target.z+mobj.target.height)
	else
		if mobj and mobj.valid then
			P_RemoveMobj(mobj)
		end
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
end, MT_ZEMO_BUBBLE)
