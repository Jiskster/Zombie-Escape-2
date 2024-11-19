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

local NOXY_Timer3 = ZE2:AddTimer("Leaving Platform",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(23)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

addHook("LinedefExecute", function()
	NOXY_Timer1.active = true
end, "NOXYTIMER1")

addHook("LinedefExecute", function()
	NOXY_Timer2.active = true
end, "NOXYTIMER2")

addHook("LinedefExecute", function()
	NOXY_Timer3.active = true
end, "NOXYTIMER3")