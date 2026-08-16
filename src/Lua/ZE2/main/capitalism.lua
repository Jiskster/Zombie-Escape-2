freeslot("MT_RUBY_BOX", "S_RUBY_BOX", "S_RUBY_BOX_BREAK", "SPR_RBYM")
freeslot("MT_CRRUBY","S_CRRUBY","SPR_RBY1", "sfx_rbyhit")
sfxinfo[sfx_rbyhit].caption = "Ruby"

function ZE2:GivePlayerCash(player, amount)
	if ((player.ze2.cash + amount) > player.ze2.cash_limit) then
		player.ze2.cash = player.ze2.cash_limit
		return false
	else
		player.ze2.cash = player.ze2.cash + amount
	end
	return true
end

ZE2.currencydelay = CV_RegisterVar({
	name = "z_currencydelay",
	defaultvalue = "1",
	PossibleValue = {MIN = 0, MAX = 12},
	flags = CV_NETVAR,
})

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

mobjinfo[MT_CRRUBY] = {
	doomednum = -1,
	spawnstate = S_CRRUBY,
	spawnhealth = 1,
	deathstate = S_SPRK1,
	radius = 25 * FU,
	height = 45 * FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_RUNSPAWNFUNC,
}

states[S_CRRUBY] = {
	sprite = SPR_RBY1,
	frame = FF_FULLBRIGHT|A,
    action = function(mobj)
        mobj.renderflags = mobj.renderflags | RF_NOCOLORMAPS
    end,
	tics = -1,
	nextstate = S_CRRUBY,
}

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

addHook("PlayerThink", function(player)
	if (player.ze2 == nil) then return end

	if (player.ze2.cash > player.ze2.cash_limit) then
		player.ze2.cash = player.ze2.cash_limit
	end

	if player.ze2.currencydelay then
		player.ze2.currencydelay = player.ze2.currencydelay - 1
	end
end)

addHook("MobjDeath", function(mobj)
	if mobj.cashholding then
		A_RubyDrop(mobj,mobj.cashholding)
		mobj.cashholding = 0
	end
end)

addHook("MobjSpawn", function(mobj)
	if mobjinfo[mobj.type].rubydrop and (type(mobjinfo[mobj.type].rubydrop) == "table") and (#mobjinfo[mobj.type].rubydrop == 2) then
		local count = P_RandomRange(mobjinfo[mobj.type].rubydrop[1], mobjinfo[mobj.type].rubydrop[2])
		mobj.cashholding = count
	end
end)


addHook("TouchSpecial", function(special, toucher)
	if not toucher or not toucher.valid or not toucher.player or not toucher.player.valid then return true end
	if (toucher.player.ze2 == nil) then return true end

	if ((toucher.player.ze2.cash + 1) > toucher.player.ze2.cash_limit) then
		return true
	elseif toucher.player.ze2.currencydelay then
		return true
	end

	ZE2:GivePlayerCash(toucher.player, 5)
	toucher.player.ze2:ChangeStamina(5 * FRACUNIT)
	toucher.player.ze2.currencydelay = ZE2.currencydelay.value
	S_StartSound(toucher, sfx_rbyhit)
end, MT_CRRUBY)

addHook("MobjDeath", function(mobj)
	if not mobj or not mobj.valid then return end

	mobj.momx, mobj.momy, mobj.momz = 0, 0, 0
	mobj.alpha = 0

	local effect = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_IVSP)
	effect.fuse = 15
	effect.angle = P_RandomRange(1, 360) * ANG1
	effect.flags = effect.flags & ~(MF_NOGRAVITY)
	effect.color = SKINCOLOR_RUBY
	effect.colorized = true
	P_SetObjectMomZ(effect, P_RandomRange(2, 7) * FU, true)
	P_Thrust(effect, effect.angle, P_RandomRange(4, 25) * FU)
end, MT_CRRUBY)

addHook("MobjThinker", function(mobj)
	if (mobj.sprite == SPR_SPRK) then
		mobj.color = SKINCOLOR_RUBY
		mobj.colorized = true
	end
	if not mobj.health then return end

	if mobj.eflags & MFE_JUSTHITFLOOR then
		P_SetObjectMomZ(mobj, abs(FixedDiv(mobj.lastmomz, P_RandomRange(2, 3 ) * FRACUNIT)))
		if (mobj.momz < FRACUNIT) then
			mobj.momz = 0
		else
			S_StartSoundAtVolume(mobj, sfx_tink, mobj.landvolume or 200)
			mobj.landvolume = min(mobj.landvolume + 30, 200)
		end
	end
	mobj.lastmomz = mobj.momz

	if (mobj.fuse < (3 * TICRATE)) then
		mobj.flags2 = mobj.flags2 ^^ MF2_DONTDRAW
	end

	local findrange = 1024 * mobj.scale
	local pmofound
	for player in players.iterate do
		if player.spectator then continue end
		if not player.mo or not player.mo.valid then continue end
		if (player.mo.team ~= 1) then continue end
		if (player.ze2.cash >= player.ze2.cash_limit) then continue end

		local mo = player.mo
		if not mo then continue end

		local dist = FixedHypot(FixedHypot(mobj.x - mo.x, mobj.y - mo.y), mobj.z - mo.z)
		if (abs(mobj.z - mo.z) <= (300 * mobj.scale)) and (dist <= findrange) then
			if not pmofound then
				pmofound = mo
			else
				local newpmodist = R_PointToDist2(mobj.x, mobj.y, mo.x, mo.y)
				local oldpmodist = R_PointToDist2(mobj.x, mobj.y, pmofound.x, pmofound.y)
				if (newpmodist < oldpmodist) then
					pmofound = mo
				end
			end
		end
	end

	mobj.spritexscale,mobj.spriteyscale = FU,FU
	if ((mobj.momz * P_MobjFlip(mobj)) <= -mobj.scale) then
		local mom = FixedDiv(mobj.momz * P_MobjFlip(mobj), mobj.scale) + FU
		mom = mom / 50
		mom = max(mom, (-FU * 3) / 5)
		mobj.spritexscale, mobj.spriteyscale = mobj.spritexscale + mom, mobj.spriteyscale - mom
	end

	if P_RandomChance(FU / 8) then
		local wind = P_SpawnMobj(
			mobj.x + P_RandomRange(-18, 18) * mobj.scale,
			mobj.y + P_RandomRange(-18, 18) * mobj.scale,
			mobj.z + (mobj.height / 2) + P_RandomRange(-20, 20) * mobj.scale,
			MT_BOXSPARKLE)
		wind.frame = wind.frame | FF_FULLBRIGHT
		wind.renderflags = wind.renderflags | RF_FULLBRIGHT
		wind.color = P_RandomChance(FU / 2) and SKINCOLOR_RED or SKINCOLOR_CRIMSON
		wind.colorized = true
		wind.alpha = FU / 2
		P_SetObjectMomZ(wind, P_RandomRange(1, 3) * FU)
	end
	if not pmofound or not pmofound.valid then return end

	P_FlyTo(mobj, pmofound.x,pmofound.y,pmofound.z, 4 * FRACUNIT, true)
	local ghost = P_SpawnGhostMobj(mobj)
	ghost.fuse = 7
	ghost.renderflags = ghost.renderflags | RF_FULLBRIGHT
	ghost.blendmode = AST_ADD
end, MT_CRRUBY)

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

addHook("MobjThinker", function(mobj)
	if not mobj.fuse then return end

	mobj.alpha = FU - FixedDiv(FU, mobj.fuse * FU)
	P_SetObjectMomZ(mobj, -FU / 2, true)
end, MT_IVSP)