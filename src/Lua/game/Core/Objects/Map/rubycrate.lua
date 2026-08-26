freeslot("MT_RUBY_BOX", "S_RUBY_BOX", "S_RUBY_BOX_BREAK", "SPR_RBYM")

function A_RubyDrop(actor, var1)
	local amount = var1

	for i = 1, amount do
		local ruby = P_SpawnMobjFromMobj(actor, 0, 0, 10 * FU, MT_CRRUBY)
		ruby.scale = FRACUNIT
		ruby.shadowscale = FRACUNIT
		ruby.fuse = 16*TICRATE
		ruby.landvolume = min(512 / amount, 200)
		P_SetObjectMomZ(ruby, P_RandomRange(7, 10) * FU)

		if (amount > 1) then
			local angle = P_RandomFixed() * FU
			P_InstaThrust(ruby, angle, 2 * FU)
		end
	end
end

mobjinfo[MT_RUBY_BOX] = {
	//$Category Zombie Escape 2
	//$Name Ruby Crate
	//$Sprite RBYMARAL
	doomednum = 863,
	spawnstate = S_RUBY_BOX,
	deathstate = S_RUBY_BOX_BREAK,
	deathsound = sfx_wbreak,
	spawnhealth = 1,
	height = 32*FRACUNIT,
	radius = 16*FRACUNIT,
	flags = MF_SOLID|MF_SHOOTABLE|MF_RUNSPAWNFUNC
}

states[S_RUBY_BOX] = {
    sprite = SPR_RBYM,
    frame = A,
	tics = -1
}

states[S_RUBY_BOX_BREAK] = {
    sprite = SPR_RBYM,
    frame = A,
	action = function(mobj)
		mobj.flags2 = mobj.flags2 | (MF2_DONTDRAW|MF2_DONTRESPAWN)
		mobj.papersprites = mobj.papersprites or {}
		for index = 1, 4, 1 do
			local wall = mobj.papersprites[index]
			if not wall or not wall.valid then continue end

			P_RemoveMobj(wall)
		end

		mobj.splats = mobj.splats or {}
		for index = 1, 2, 1 do
			local splat = mobj.splats[index]
			if not splat or not splat.valid then continue end

			P_RemoveMobj(splat)
		end

		local sound = P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_ZVISUAL)
		sound.fuse = TICRATE
		S_StartSound(sound, mobj.info.deathsound)

		A_RubyDrop(mobj, 5)
		for index = 0, 8, 1 do
			local angle = ANGLE_45 * index
			local effect = P_SpawnMobjFromMobj(mobj,
				P_ReturnThrustX(nil, angle, FixedDiv(mobj.radius, mobj.scale)),
				P_ReturnThrustY(nil, angle, FixedDiv(mobj.radius, mobj.scale)),
				P_RandomRange(0, FixedDiv(mobj.height, mobj.scale) >> FRACBITS) * FU,
				MT_THOK)
			effect.tics = -1
			effect.fuse = TICRATE
			effect.state = S_WOODDEBRIS
			effect.frame = effect.frame | FF_PAPERSPRITE
			effect.colorized = true
			effect.color = SKINCOLOR_RED
			effect.flags = MF_NOCLIP|MF_NOCLIPHEIGHT
			effect.angle = angle + P_RandomRange(-180, 180) * ANG1
			P_Thrust(effect, angle, P_RandomRange(1, 5) * (effect.scale + P_RandomFixed()))
			P_SetObjectMomZ(effect, P_RandomRange(2, 10) * (FU + P_RandomFixed()))
		end
	end,
	tics = 1
}

local Sides = {0, ANGLE_90, ANGLE_180, ANGLE_270}
local function SpawnPaperSprites(mobj)
	mobj.papersprites = mobj.papersprites or {}
	for index = 1, 4, 1 do
		local offsetx = P_ReturnThrustX(mobj, mobj.angle + (Sides[index] + ANGLE_90), mobj.radius)
		local offsety = P_ReturnThrustY(mobj, mobj.angle + (Sides[index] + ANGLE_90), mobj.radius)

		local wall = mobj.papersprites[index]
		if not wall or not wall.valid then
			wall = P_SpawnMobj(mobj.x + offsetx, mobj.y + offsety, mobj.z, MT_ZVISUAL)
			mobj.papersprites[index] = wall
		end
		P_SetOrigin(wall, mobj.x + offsetx, mobj.y + offsety, mobj.z)
		wall.sprite = SPR_RBYM
		wall.frame = 0
		wall.renderflags = RF_PAPERSPRITE
		wall.angle = mobj.angle + Sides[index]
		wall.scale = mobj.scale
		wall.spritexscale = mobj.spritexscale
		wall.spriteyscale = mobj.spriteyscale
	end
end

local function SpawnSplats(mobj) -- no need for a for loop
	mobj.splats = mobj.splats or {}

	local splat = mobj.splats[1]
	if not splat or not splat.valid then
		splat = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_ZVISUAL)
		mobj.splats[1] = splat
	end
	P_SetOrigin(splat, mobj.x, mobj.y, mobj.z)
	splat.sprite = SPR_RBYM
	splat.frame = 2
	splat.renderflags = RF_FLOORSPRITE|RF_NOSPLATROLLANGLE|RF_NOSPLATBILLBOARD
	splat.angle = mobj.angle + ANGLE_90
	splat.scale = mobj.scale
	splat.spritexscale = mobj.spritexscale
	splat.spriteyscale = mobj.spritexscale

	local splat = mobj.splats[2]
	if not splat or not splat.valid then
		splat = P_SpawnMobj(mobj.x, mobj.y, mobj.z + mobj.height, MT_ZVISUAL)
		mobj.splats[2] = splat
	end
	P_SetOrigin(splat, mobj.x, mobj.y, mobj.z + mobj.height)
	splat.sprite = SPR_RBYM
	splat.frame = 1
	splat.renderflags = RF_FLOORSPRITE|RF_NOSPLATROLLANGLE|RF_NOSPLATBILLBOARD
	splat.angle = mobj.angle + ANGLE_90
	splat.scale = mobj.scale
	splat.spritexscale = mobj.spritexscale
	splat.spriteyscale = mobj.spritexscale
end
addHook("MobjThinker", function(mobj)
	if not mobj or not mobj.valid then return end
	if (mobj.flags2 & MF2_DONTRESPAWN) then return end

	mobj.scale = mobj.scale
	mobj.radius = FixedMul(FixedMul(mobjinfo[mobj.type].radius, mobj.spritexscale), mobj.scale)
	mobj.height = FixedMul(FixedMul(mobjinfo[mobj.type].height, mobj.spriteyscale), mobj.scale)
	mobj.flags2 = mobj.flags2 | MF2_DONTDRAW
	SpawnPaperSprites(mobj)
	SpawnSplats(mobj)
end, MT_RUBY_BOX)