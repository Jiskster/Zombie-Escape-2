local ZB_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 55*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(60)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

local ZB_Timer2 = ZE2:AddTimer("Defend Barrier 2",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(61)
	end,
	extrainfo = {color = SKINCOLOR_EMERALD},
})

addHook("LinedefExecute", function()
	ZB_Timer1.active = true
end, "ZOMBIOB1")

addHook("LinedefExecute", function()
	ZB_Timer2.active = true
end, "ZOMBIOB2")