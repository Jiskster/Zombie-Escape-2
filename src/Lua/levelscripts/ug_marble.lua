local UGMarble_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
	end,
	extrainfo = {color = SKINCOLOR_PURPLE},
})

local UGMarble_Timer2 = ZE2:AddTimer("Defend Barrier 2",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(13)
	end,
	extrainfo = {color = SKINCOLOR_PURPLE},
})

addHook("LinedefExecute", function()
	UGMarble_Timer1.active = true
end, "UGMARBLETIMER1")

addHook("LinedefExecute", function()
	UGMarble_Timer2.active = true
end, "UGMARBLETIMER2")