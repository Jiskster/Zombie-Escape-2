freeslot("sfx_dcrp01")

local DC_Timer1 = ZE2:AddTimer("Defend Elevator",{
	time = 27*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(30)
	end,
	extrainfo = {color = SKINCOLOR_BLUE},
})

local DC_Timer2 = ZE2:AddTimer("Defend The Barrier",{
	time = 50*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(62)
	end,
	extrainfo = {color = SKINCOLOR_WHITE},
})

addHook("LinedefExecute", function()
	DC_Timer1.active = true
end, "DOOMEDC1")

addHook("LinedefExecute", function()
	DC_Timer2.active = true
end, "DOOMEDC2")