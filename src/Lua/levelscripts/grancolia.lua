ZE2:AddTimer("GRANCOLIA_1",
"Defend Underground Barrier",
{
	time = 30*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(4)
	end,
	textcolor = SKINCOLOR_RUST,
})

ZE2:AddTimer("GRANCOLIA_2",
"Defend Huge Barrier",
{
	time = 40*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(8)
	end,
	textcolor = SKINCOLOR_RUST,
})

ZE2:AddTimer("GRANCOLIA_1",
"Defend Final Barrier",
{
	time = 20*TICRATE,
	on_end = function(timernum,timername)
		P_LinedefExecute(11)
	end,
	textcolor = SKINCOLOR_RUST,
})

addHook("LinedefExecute", function()
	ZE2:StartTimer("GRANCOLIA_1")
end, "GRANCOLIATIMER1")

addHook("LinedefExecute", function()
	ZE2:StartTimer("GRANCOLIA_2")
end, "GRANCOLIATIMER2")

addHook("LinedefExecute", function()
	ZE2:StartTimer("GRANCOLIA_3")
end, "GRANCOLIATIMER3")