local Desert_Timer1 = ZE2:AddTimer("Defend First Barrier",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(2)
		S_StartSound(nil, 90, nil)
	end,
	extrainfo = {color = SKINCOLOR_ORANGE},
})

local Desert_Timer2 = ZE2:AddTimer("Defend Second Barrier",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
		S_StartSound(nil,90,nil)
	end,
	extrainfo = {color = SKINCOLOR_SANDY},
})

local Desert_Timer3 = ZE2:AddTimer("Defend Final Barrier",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
		S_StartSound(nil, 90, nil)
	end,
	extrainfo = {color = SKINCOLOR_RED},
})

addHook("LinedefExecute", function()
	Desert_Timer1.active = true
end, "DESERTTIMER1")

addHook("LinedefExecute", function()
	Desert_Timer2.active = true
end, "DESERTTIMER2")

addHook("LinedefExecute", function()
	Desert_Timer3.active = true
end, "DESERTTIMER3")