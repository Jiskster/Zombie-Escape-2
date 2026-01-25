freeslot("MT_XS_DROPPEDITEM")
freeslot("S_XS_DROPPEDITEM") -- default state

mobjinfo[MT_XS_DROPPEDITEM] = {
	spawnhealth = 1000,
	radius = 32*FU,
	height = 32*FU,
	spawnstate = S_XS_DROPPEDITEM,
	deathstate = S_XS_DROPPEDITEM,
}

states[S_XS_DROPPEDITEM] = {
	sprite = SPR_THOK,
	frame = FF_FULLBRIGHT|FF_TRANS40|A,
	tics = -1,
	nextstate = S_XS_DROPPEDITEM,
}

-- Can put a mobj inside "data".
function xSlinger.SpawnItemDrop(data, item)
	if type(item) == "string" then
		item = xSlinger.new(item)
	end
	
	if not item then
		return end;
	
	local dropmobj = P_SpawnMobj(data.x, data.y, data.z, MT_XS_DROPPEDITEM)
	dropmobj.iteminfo = item

	if item.dropstate then
		dropmobj.state = item.dropstate
	end
	
	if item.color then
		dropmobj.color = item.color
	end
	
	dropmobj.spriteyoffset = 16*FU
	
	-- Spawn interaction
	local i_obj = P_SpawnMobj(data.x, data.y, data.z, MT_XS_INTERACTION) -- interaction object
	i_obj.target = dropmobj -- to make the interaction follow the dropmobj
	i_obj.interaction = {
		text = "Dropped Item";
		type = "item";
		holdtime = TICRATE/2;
	}
	i_obj.state = S_INVISIBLE
end

addHook("TouchSpecial", function(special, toucher)
	return true
end, MT_XS_DROPPEDITEM)

COM_AddCommand("drop", function(player, item)
	if not (player.mo and player.mo.valid) then
		return end;
		
	if not (item) then
		return end;
		
	xSlinger.SpawnItemDrop(player.mo, item)
end, COM_ADMIN)