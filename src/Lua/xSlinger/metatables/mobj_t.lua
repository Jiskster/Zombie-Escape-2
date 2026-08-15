-- TODO: Move file
addHook("MobjSpawn", function(mobj)
	if mobj.type == MT_PLAYER then 
		return end;
		
	mobj.team = 0
end)
