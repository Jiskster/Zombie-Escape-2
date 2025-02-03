local LS_Timer1 = ZE2:AddTimer("Defend Wall",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(30)
	end,
	extrainfo = {color = SKINCOLOR_SILVER},
})

local LS_Timer2 = ZE2:AddTimer("Defend Door",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(69)
	end,
	extrainfo = {color = SKINCOLOR_SILVER},
})

local LS_Timer3 = ZE2:AddTimer("Defend Moving Platform",{
	time = 45*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(70)
	end,
	extrainfo = {color = SKINCOLOR_SILVER},
})

addHook("LinedefExecute", function()
	LS_Timer1.active = true
end, "LOSWR1")

addHook("LinedefExecute", function()
	LS_Timer2.active = true
end, "LOSWR2")

addHook("LinedefExecute", function()
	LS_Timer3.active = true
end, "LOSWR3")