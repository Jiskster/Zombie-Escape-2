local CVOID_Timer1 = ZE2:AddTimer("SURVIVE",{
	time = 62*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(10)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

local CVOID_Timer2 = ZE2:AddTimer("Defend Barrier",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

local CVOID_Timer3 = ZE2:AddTimer("Good Luck!",{
	time = 75*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(22)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

local CVOID_Timer4 = ZE2:AddTimer("Defend Barrier",{
	time = 5*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

addHook("LinedefExecute", function()
	CVOID_Timer1.active = true
end, "CVOIDTIMER1")

addHook("LinedefExecute", function()
	CVOID_Timer2.active = true
end, "CVOIDTIMER2")

addHook("LinedefExecute", function()
	CVOID_Timer3.active = true
end, "CVOIDTIMER3")

addHook("LinedefExecute", function()
	CVOID_Timer4.active = true
end, "CVOIDTIMER4")