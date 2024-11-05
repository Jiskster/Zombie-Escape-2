local NOXY_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(2)
	end,
	extrainfo = {color = SKINCOLOR_YELLOW},
})

local NOXY_Timer2 = ZE2:AddTimer("Defend Final Barrier",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(6)
	end,
	extrainfo = {color = SKINCOLOR_PURPLE},
})

addHook("LinedefExecute", function()
	NOXY_Timer1.active = true
end, "NOXYTIMER1")

addHook("LinedefExecute", function()
	NOXY_Timer2.active = true
end, "NOXYTIMER2")