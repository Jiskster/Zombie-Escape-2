freeslot("MT_XS_DROPPEDITEM")
freeslot("S_XS_DROPPEDITEM") -- default state

freeslot("S_XS_DROPITEMVFX")
freeslot("SPR_XS_DROPITEMVFX")

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

-- 7 frame advances with each frame lasting 4 tics
states[S_XS_DROPITEMVFX] = {
	sprite = SPR_XS_DROPITEMVFX,
	frame = 2|FF_SEMIBRIGHT,
	tics = 1,
	action = function(v)
		v.alpha = FU - FixedDiv(v.extravalue1*FU, (7*4)*FU)

		v.extravalue1 = $ + 1
		v.frame = ($ &~FF_FRAMEMASK)|(2 + (v.extravalue1/4))
	end,
	nextstate = S_XS_DROPITEMVFX
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

-- Not sure if a MobjThinker is the best way for this
local CORONA_DIST = 1024*FU
addHook("MobjThinker", function(drop)
	if not (drop and drop.valid) then return end

	local zoff = (FixedDiv(drop.height, drop.scale) / 2) + 8*FU

	local fudge = -2 * FU
	local fudge_ang = R_PointToAngle(drop.x, drop.y)
	local fudge_dist = R_PointToDist(drop.x, drop.y)
	local fx = P_ReturnThrustX(nil, fudge_ang, fudge)
	local fy = P_ReturnThrustY(nil, fudge_ang, fudge)

	local f -- flair mobj pointer
	local flair_roll = FixedAngle(leveltime * FU * 3/2)
	local flair_color = drop.color or drop.dropbgcolor 

	---- LINE VFX
		if (leveltime % 4 == 0) then
			local rad = FixedDiv(drop.radius, drop.scale) / FU / 2
			local hei = FixedDiv(drop.height, drop.scale) / FU / 2
			local v = P_SpawnMobjFromMobj(drop,
				P_RandomRange(-rad, rad)*FU,
				P_RandomRange(-rad, rad)*FU,
				zoff + P_RandomRange(-hei, hei)*FU,
				MT_PARTICLE
			)
			v.state = S_XS_DROPITEMVFX
			v.fuse = (7*4)
			v.color = flair_color
			P_SetObjectMomZ(v, FU)
		end
	----

	---- INNER FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_XS_DROPITEMVFX
		f.frame = 0|FF_FULLBRIGHT|FF_ADD

		f.scale = $ * 3/4
		f.dispoffset = -600

		f.rollangle = flair_roll
		f.color = flair_color
		f.alpha = FU/3
		
	----

	---- OUTER FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_XS_DROPITEMVFX
		f.frame = 0|FF_FULLBRIGHT|FF_ADD

		f.scale = $ * 3/2
		f.dispoffset = -650

		f.rollangle = -flair_roll
		f.color = flair_color
		f.alpha = FU/5
	----

	-- LENS FLAIR
		f = P_SpawnMobjFromMobj(drop, fx,fy,zoff, MT_PARTICLE)
		f.tics = 2
		f.fuse = 2

		f.sprite = SPR_XS_DROPITEMVFX
		f.frame = 1|FF_FULLBRIGHT|FF_ADD

		f.dispoffset = -700
		local alpha = FU
		if (fudge_dist < CORONA_DIST) then
			alpha = FixedDiv(fudge_dist, CORONA_DIST)
		end
		f.scale = $ + FixedDiv(fudge_dist - CORONA_DIST/2, CORONA_DIST) / 2
		f.spritexscale = FU/2
		f.spriteyscale = FU/2
		f.alpha = alpha / 3
	--
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