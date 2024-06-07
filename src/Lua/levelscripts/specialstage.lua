local ss_mapnum = G_FindMapByNameOrCode("MAPJ6")


local function SS_Tele1()
	for player in players.iterate do
		if player.mo and player.mo.valid then
			if (player.zteam == 1) then
				P_SetOrigin(player.mo, -29024*FRACUNIT, 31648*FRACUNIT, 0*FRACUNIT) 
			end
			if (player.zteam == 2) then
				P_SetOrigin(player.mo, -30304*FRACUNIT, 27040*FRACUNIT, 0*FRACUNIT) 
			end
		end
	end
end

local function SS_Tele2()
	for player in players.iterate do
		if player.mo and player.mo.valid then
			if (player.zteam == 1) then
				P_SetOrigin(player.mo, -28576*FRACUNIT, 31648*FRACUNIT, 0*FRACUNIT) 
			elseif (player.zteam == 2) then
				P_SetOrigin(player.mo, -30304*FRACUNIT, 27040*FRACUNIT, 0*FRACUNIT) 
			end
		end
	end
end

local function SS_Tele3()
	for player in players.iterate do
		if player.mo and player.mo.valid then
			if (player.zteam == 1) then
				P_SetOrigin(player.mo, -28128*FRACUNIT, 31648*FRACUNIT, 0*FRACUNIT) 
			elseif (player.zteam == 2) then
				P_SetOrigin(player.mo, -30304*FRACUNIT, 27040*FRACUNIT, 0*FRACUNIT) 
			end
		end
	end
end

local SpecialStage1_Timer = ZE2:AddTimer("Special Stage 1",{
	time = 60*TICRATE,
	on_end = function(timernum,timername)
		SS_Tele1()
		P_LinedefExecute(43)
		P_LinedefExecute(49)
	end,
	extrainfo = {color = SKINCOLOR_MINT}
}) 

local SpecialStage2_Timer = ZE2:AddTimer("Special Stage 2",{
	time = 60*TICRATE,
	on_end = function(timernum,timername)
		SS_Tele2()
		P_LinedefExecute(52)
		P_LinedefExecute(44)
	end,
	extrainfo = {color = SKINCOLOR_BUBBLEGUM}
}) 

local SpecialStage3_Timer = ZE2:AddTimer("Special Stage 3",{
	time = 120*TICRATE,
	on_end = function(timernum,timername)
		SS_Tele3()
		P_LinedefExecute(53)
		P_LinedefExecute(46)
	end,
	extrainfo = {color = SKINCOLOR_SKY}
}) 

local function SS_Objection1()
	chatprint("\x83\Multiplayer Special Stage 1")
	chatprint("Survive for\x83 60 \x80seconds")
	SpecialStage1_Timer.active = true
end

local function SS_Objection2()
	chatprint("\x81\Multiplayer Special Stage 2")
	chatprint("Survive for\x83 60 \x80seconds")
	SpecialStage2_Timer.active = true
end

local function SS_Objection3()
	chatprint("\x84\Multiplayer Special Stage 3")
	chatprint("Survive for\x85 120 \x80seconds")
	SpecialStage3_Timer.active = true
end

local function SS_Objection4()
	chatprint("\x82\Multiplayer Special Stage 4")
	chatprint("Survive for\x85 120 \x80seconds")
	ZE2.time_limit = ZE2.game_time + 120*TICRATE
end

addHook("LinedefExecute", SS_Objection1, "45ACT1")
addHook("LinedefExecute", SS_Objection2, "45ACT2")
addHook("LinedefExecute", SS_Objection3, "45ACT3")
addHook("LinedefExecute", SS_Objection4, "45ACT4")