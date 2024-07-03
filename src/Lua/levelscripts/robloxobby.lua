local RobloxObby_Timer1 = ZE2:AddTimer("Defend Barrier",{
	time = 60*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(6)
	end,
	extrainfo = {color = SKINCOLOR_WHITE},
})

local RobloxObby_Timer2 = ZE2:AddTimer("Defend Massive Wall",{
	time = 60*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(10)
	end,
	extrainfo = {color = SKINCOLOR_GREY},
})

addHook("LinedefExecute", function()
	RobloxObby_Timer1.active = true
end, "RBLXOBBY_TIMER1")


addHook("LinedefExecute", function()
	RobloxObby_Timer2.active = true
end, "RBLXOBBY_TIMER2")