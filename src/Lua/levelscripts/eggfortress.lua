local FORT_Timer1 = ZE2:AddTimer("Defend the Gate",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(9)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

local FORT_Timer2 = ZE2:AddTimer("Defend the Second Gate",{
	time = 35*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(19)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

local FORT_Timer3 = ZE2:AddTimer("Defend the Secret Entrance",{
	time = 45*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(41)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

addHook("LinedefExecute", function()
	FORT_Timer1.active = true
end, "FORTTIMER1")

addHook("LinedefExecute", function()
	FORT_Timer2.active = true
end, "FORTTIMER2")

addHook("LinedefExecute", function()
	FORT_Timer3.active = true
end, "FORTTIMER3")