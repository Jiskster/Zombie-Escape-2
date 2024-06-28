local SF_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 45*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(5)
	end,
	extrainfo = {color = SKINCOLOR_BROWN},
})

local SF_Timer2 = ZE2:AddTimer("Defend The Second Barrier",{
	time = 50*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(17)
	end,
	extrainfo = {color = SKINCOLOR_BROWN},
})

addHook("LinedefExecute", function()
	SF_Timer1.active = true
end, "SPOOKYF1")

addHook("LinedefExecute", function()
	SF_Timer2.active = true
end, "SPOOKYF2")