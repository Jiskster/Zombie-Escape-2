freeslot("MT_XS_DROPPEDITEM")
freeslot("S_XS_DROPPEDITEM") -- default state

freeslot("MT_XS_DROPPEDITEM_SPAWN")

mobjinfo[MT_XS_DROPPEDITEM] = {
	spawnhealth = 1000,
	radius = 32*FU,
	height = 32*FU,
	spawnstate = S_XS_DROPPEDITEM,
	deathstate = S_XS_DROPPEDITEM,
	flags = MF_SPECIAL,
}

states[S_XS_DROPPEDITEM] = {
	sprite = SPR_THOK,
	frame = FF_FULLBRIGHT|FF_TRANS40|A,
	tics = -1,
	nextstate = S_XS_DROPPEDITEM,
}

-- Mapthing
mobjinfo[MT_XS_DROPPEDITEM_SPAWN] = {
	//$Category xSlinger
	//$Name xSlinger Item Spawn

	//$StringArg0 Item ID

	doomednum = 50501,

	spawnhealth = 1000,
	radius = 32*FU,
	height = 32*FU,
	spawnstate = S_INVISIBLE,
	deathstate = S_INVISIBLE,
	flags = MF_NOBLOCKMAP,
}

-- Can put a mobj inside "data".
function xSlinger.SpawnItemDrop(data, item, nothrow)
	if type(item) == "string" then
		item = xSlinger.new(item)
	end

	if not item then
		return end;

	local dropmobj = P_SpawnMobj(data.x, data.y, data.z, MT_XS_DROPPEDITEM)
	dropmobj.iteminfo = item
	dropmobj.droprandomangle = P_RandomRange(-5,5)*ANG1

	if item.dropstate then
		dropmobj.state = item.dropstate
	end

	if item.color and not item.dropignorecolor then
		dropmobj.color = item.color
	elseif item.dropignorecolor then
		dropmobj.dropbgcolor = item.color
	end

	if item.dropscale then
		dropmobj.spritexscale = item.dropscale
		dropmobj.spriteyscale = item.dropscale
	end

	if item.dropyoffset ~= nil then
		dropmobj.spriteyoffset = item.dropyoffset
	else
		dropmobj.spriteyoffset = 16*FU
	end

	dropmobj.friction = 27*FRACUNIT/32

	if data.angle ~= nil then
		dropmobj.angle = data.angle

		if not nothrow then
			P_Thrust(dropmobj, dropmobj.angle, 5*FU)
		end
	end

	if not nothrow then
		P_SetObjectMomZ(dropmobj, 4*FU, true)
	end

	-- Spawn interaction
	local i_obj = P_SpawnMobj(data.x, data.y, data.z, MT_XS_INTERACTION) -- interaction object
	i_obj.target = dropmobj -- to make the interaction follow the dropmobj
	i_obj.interaction = {
		text = "Dropped Item";
		type = "item";
		holdtime = TICRATE/4;
	}
	i_obj.state = S_INVISIBLE
	return i_obj
end

-- Make dropped items push eachother
addHook("MobjMoveCollide", function(tmthing, thing)
	if (tmthing.type ~= thing.type) then
		return end;

	local angle = R_PointToAngle2(tmthing.x, tmthing.y, thing.x, thing.y)
	local push = FRACUNIT/4

	if tmthing.droprandomangle then
		angle = $ + tmthing.droprandomangle
	end

	if not P_IsObjectOnGround(tmthing) then
		push = $ / 3
	end

	P_Thrust(tmthing, angle-ANGLE_180, push)
	P_Thrust(thing, angle-tmthing.droprandomangle, push)
end, MT_XS_DROPPEDITEM)

addHook("TouchSpecial", function(special, toucher)
	return true
end, MT_XS_DROPPEDITEM)

addHook("MapThingSpawn", function(mobj, mapthing)
	if not (mobj and mobj.valid) then
		return end;

	xSlinger.SpawnItemDrop(mobj, mapthing.stringargs[0] or -1, true)
end, MT_XS_DROPPEDITEM_SPAWN)

COM_AddCommand("spawnitemdrop", function(player, item)
	if not (player.mo and player.mo.valid) then
		return end;

	if not (item) then
		return end;

	xSlinger.SpawnItemDrop(player.mo, item)
end, COM_ADMIN)

COM_AddCommand("drophand", function(player)
	local xS = player.xSlinger

	if not (player.mo and player.mo.valid) then
		return end;

	xS:hand_drop()
end)