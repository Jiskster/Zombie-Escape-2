freeslot("sfx_UTMMRY")

local UTWTRFLL_Timer1 = ZE2:AddTimer("Defend Rock",{
	time = 35*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(21)
	end,
	extrainfo = {color = SKINCOLOR_PURPLE},
})

local UTWTRFLL_Timer2 = ZE2:AddTimer("Defend Barrier",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(22)
	end,
	extrainfo = {color = SKINCOLOR_AZURE},
})

local UTWTRFLL_Timer3 = ZE2:AddTimer("Leaving platform",{
	time = 25*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(40)
	end,
	extrainfo = {color = SKINCOLOR_ORANGE},
})

addHook("LinedefExecute", function()
	UTWTRFLL_Timer1.active = true
end, "WATERFALL1")

addHook("LinedefExecute", function()
	UTWTRFLL_Timer2.active = true
end, "WATERFALL2")

addHook("LinedefExecute", function()
	UTWTRFLL_Timer3.active = true
end, "WATERFALL3")