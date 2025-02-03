local Alphacombs_Timer1 = ZE2:AddTimer("Defend First Barrier",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(3)
		S_StartSound(nil, 90, nil)
	end,
	extrainfo = {color = SKINCOLOR_ORANGE},
})

local Alphacombs_Timer2 = ZE2:AddTimer("Defend Second Barrier",{
	time = 26*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(7)
		S_StartSound(nil,90,nil)
	end,
	extrainfo = {color = SKINCOLOR_BLACK},
})

local Alphacombs_Timer3 = ZE2:AddTimer("Leaving Platform",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(23)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

addHook("LinedefExecute", function()
	Alphacombs_Timer1.active = true
end, "ALPHACOMBSTIMER1")

addHook("LinedefExecute", function()
	Alphacombs_Timer2.active = true
end, "ALPHACOMBSTIMER2")

addHook("LinedefExecute", function()
	Alphacombs_Timer3.active = true
end, "ALPHACOMBSTIMER3")