return function()
	if gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if ZE2.win_tics >= 12*TICRATE and not ZE2.queuing_round then
		ZE2.queuing_round = true
		COM_BufInsertText(server, "map "..gamemap)
	end
end