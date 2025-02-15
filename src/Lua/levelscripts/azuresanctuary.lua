local AZUR_Timer1 = ZE2:AddTimer("Defend Temple Gate",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(25)
	end,
	extrainfo = {color = SKINCOLOR_BLUE},
})

local AZUR_Timer2 = ZE2:AddTimer("Defend Debris",{
	time = 35*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(39)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

local AZUR_Timer3 = ZE2:AddTimer("Reach the top of the Temple",{
	time = 35*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(6)
	end,
	extrainfo = {color = SKINCOLOR_PURPLE},
})

addHook("LinedefExecute", function()
	AZUR_Timer1.active = true
end, "AZURTIMER1")

addHook("LinedefExecute", function()
	AZUR_Timer2.active = true
end, "AZURTIMER2")

addHook("LinedefExecute", function()
	AZUR_Timer3.active = true
end, "AZURTIMER3")