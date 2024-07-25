local ACata_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 35*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(2)
		S_StartSound(nil, 90, nil)
	end,
	extrainfo = {color = SKINCOLOR_SANDY},
})

local ACata_Timer2 = ZE2:AddTimer("Defend Big Barrier",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(3)
		S_StartSound(nil,90,nil)
	end,
	extrainfo = {color = SKINCOLOR_TAN},
})

addHook("LinedefExecute", function()
	ACata_Timer1.active = true
end, "CATATIMER1")

addHook("LinedefExecute", function()
	ACata_Timer2.active = true
end, "CATATIMER2")