local DC_Timer1 = ZE2:AddTimer("Defend Gate",{
	time = 22*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(30)
	end,
	extrainfo = {color = SKINCOLOR_SILVER},
})

local DC_Timer2 = ZE2:AddTimer("Defend Cave",{
	time = 28*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(62)
	end,
	extrainfo = {color = SKINCOLOR_GALAXY},
})

local DC_Timer3 = ZE2:AddTimer("Defend Barrier",{
	time = 50*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(63)
		S_StartSound(nil, sfx_buzz3, nil)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

local DC_Timer4 = ZE2:AddTimer("[RARE] Defend ring",{
	time = 15*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(77)
		S_StartSound(nil, sfx_buzz3, nil)
	end,
	extrainfo = {color = SKINCOLOR_YELLOW},
})

addHook("LinedefExecute", function()
	DC_Timer1.active = true
end, "DOOMEDC1")

addHook("LinedefExecute", function()
	DC_Timer2.active = true
end, "DOOMEDC2")

addHook("LinedefExecute", function()
	DC_Timer3.active = true
end, "DOOMEDC3")

addHook("LinedefExecute", function()
	if P_RandomChance(FU/3)
		P_LinedefExecute(76)
		S_StartSound(nil, sfx_buzz3, nil)
		DC_Timer4.active = true
	end
end, "DCRARE")