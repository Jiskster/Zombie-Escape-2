ZE2.TWRITE_MAPNAME_COUNT = 0 --lvlttl
ZE2.TWRITE_COUNT = 0 --subtitle

ZE2.typewriterdelay = CV_RegisterVar({
	name = "z_typewriterdelay",
	defaultvalue = "20",
	PossibleValue = {MIN = 0, MAX = 350},
	flags = CV_NETVAR,
})

addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 or gamestate ~= GS_LEVEL then return end
	if player.ze2.pregamemenu_type ~= 2 then return end
	
	local mapinfo = mapheaderinfo[gamemap]
	
	if mapinfo and leveltime > ZE2.typewriterdelay.value and leveltime%2 then
		local lengthOfSubtitle = mapinfo.subttl:len()
		local lengthOfTitle = mapinfo.lvlttl:len()
		if ZE2.TWRITE_MAPNAME_COUNT < lengthOfTitle then
			ZE2.TWRITE_MAPNAME_COUNT = $ + 1
			S_StartSound(nil, sfx_oldrad)
			--print(mapinfo.lvlttl:sub(1,ZE2.TWRITE_MAPNAME_COUNT))
		elseif ZE2.TWRITE_COUNT < lengthOfSubtitle
			ZE2.TWRITE_COUNT = $ + 1
			S_StartSound(nil, sfx_oldrad)
			--print(mapinfo.subttl:sub(1,ZE2.TWRITE_COUNT))
		end
	end
end)


addHook("MapLoad", function()
	ZE2.TWRITE_COUNT = 0 -- subtitle
	ZE2.TWRITE_MAPNAME_COUNT = 0 -- title
end)