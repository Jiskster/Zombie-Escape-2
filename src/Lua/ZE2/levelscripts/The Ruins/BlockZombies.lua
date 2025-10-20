local ut_mapnum = G_FindMapByNameOrCode("MAP03")

addHook("MobjLineCollide", function(mobj,line)
	if gamemap ~= ut_mapnum then return end 
	if not mobj.valid or not mobj.player then return end
	
	if line.tag == 6000 and mobj.player.ze2.team == 2 then
		return true
	end
end, MT_PLAYER)