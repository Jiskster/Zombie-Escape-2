local WE_Timer1 = ZE2:AddTimer("Defend Spring Container",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(5)
	end,
	extrainfo = {color = SKINCOLOR_PINK},
})

local WE_Timer2 = ZE2:AddTimer("Defend Barrier",{
	time = 60*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(17)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

addHook("LinedefExecute", function()
	WE_Timer1.active = true
end, "WESTOP1")

addHook("LinedefExecute", function()
	WE_Timer2.active = true
end, "WESTOP2")