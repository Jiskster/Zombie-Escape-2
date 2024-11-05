local Colia_Timer1 = ZE2:AddTimer("Defend Underground Barrier",{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(4)
	end,
	extrainfo = {color = SKINCOLOR_RUST},
})

local Colia_Timer2 = ZE2:AddTimer("Defend Huge Barrier",{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
	end,
	extrainfo = {color = SKINCOLOR_RUST},
})

local Colia_Timer3 = ZE2:AddTimer("Defend Final Barrier",{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
	end,
	extrainfo = {color = SKINCOLOR_RUST},
})

addHook("LinedefExecute", function()
	Colia_Timer1.active = true
end, "GRANCOLIATIMER1")

addHook("LinedefExecute", function()
	Colia_Timer2.active = true
end, "GRANCOLIATIMER2")

addHook("LinedefExecute", function()
	Colia_Timer3.active = true
end, "GRANCOLIATIMER3")