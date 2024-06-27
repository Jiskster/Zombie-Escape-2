ZE2.mapinfohud = function(v, player)
	if not player["ze2_info"].pregamemenu_active then return end
	if player["ze2_info"].pregamemenu_type ~= 1 then return end
	if gametype ~= GT_ZE2 then return end
	local mapinfo = mapheaderinfo[gamemap]

	local lvlttlY = 44*FU
	local subttlY = 52*FU
	
	if (ZE2.TWRITE_MAPNAME_COUNT < mapinfo.lvlttl:len() and leveltime>10) then 
		customhud.CustomFontString(v,0,lvlttlY, mapinfo.lvlttl:sub(1,ZE2.TWRITE_MAPNAME_COUNT).."_", "TNYFC", V_SNAPTOLEFT|V_SNAPTOTOP, nil, FU, SKINCOLOR_BLUE)
	elseif (leveltime>10) then
		customhud.CustomFontString(v,0,lvlttlY, mapinfo.lvlttl, "TNYFC", V_SNAPTOLEFT|V_SNAPTOTOP, nil, FU, SKINCOLOR_BLUE)
	end
	if (ZE2.TWRITE_COUNT < mapinfo.subttl:len()) then
		customhud.CustomFontString(v,0,subttlY, mapinfo.subttl:sub(1,ZE2.TWRITE_COUNT), "TNYFC", V_SNAPTOLEFT|V_SNAPTOTOP, nil, FU, SKINCOLOR_WHITE)
	else
		if ((leveltime%16)<8) then customhud.CustomFontString(v,0,subttlY, mapinfo.subttl.."_", "TNYFC", V_SNAPTOLEFT|V_SNAPTOTOP, nil, FU, SKINCOLOR_WHITE)
		else customhud.CustomFontString(v,0,subttlY, mapinfo.subttl, "TNYFC", V_SNAPTOLEFT|V_SNAPTOTOP, nil, FU, SKINCOLOR_WHITE) end
	end
end