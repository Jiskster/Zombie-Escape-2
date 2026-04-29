freeslot("MT_XSLINGER_SHIELD")

-- NOTE: mobj_t.shield_def shouldn't be edited. It's a reference.

xSlinger.CachedShieldMobjs = {}

-- Don't Synch
xSlinger.ShieldDefinitions = {
	[1] = {
		name = "Pity",
		health = 50,
		state = S_PITY1,
		color = SKINCOLOR_MOSS,
	},
	[2] = {
		name = "Whirlwind",
		health = 20,
		state = S_WIND1,
		color = SKINCOLOR_BONE,
		--jumpfactor_multiplier = 3*FRACUNIT/2,
	},
	[3] = {
		name = "Armageddon",
		health = 65,
		state = S_ARMA1, -- missing overlay
		color = SKINCOLOR_CRIMSON,
	},
	[4] = {
		name = "Pink",
		health = 50,
		state = S_PITY1,
		color = SKINCOLOR_PINK,
		colorized = true,
	},
	[5] = {
		name = "Elemental",
		health = 35,
		state = S_ELEM1,
		color = SKINCOLOR_EVENTIDE,
	},
	[6] = {
		name = "Attraction",
		health = 40,
		state = S_MAGN1,
		color = SKINCOLOR_YELLOW,
	},
	[7] = {
		name = "Flame",
		health = 50,
		state = S_FIRSB1,
		color = SKINCOLOR_CRIMSON,
	},
	[8] = {
		name = "Bubble",
		health = 15,
		state = S_BUBSB1,
		color = SKINCOLOR_SKY,
	},
	[9] = {
		name = "Lightning",
		health = 40,
		state = S_ZAPSB1,
		color = SKINCOLOR_WHITE,
	},
	[10] = {
		name = "Force",
		health = 70,
		state = S_FORC1,
		color = SKINCOLOR_MAGENTA,
	}
}

local convertvanilla = {
	[SH_PITY] = 1;
	[SH_WHIRLWIND] = 2;
	[SH_ARMAGEDDON] = 3;
	[SH_PINK] = 4;
	[SH_ELEMENTAL] = 5;
	[SH_ATTRACT] = 6;
	[SH_FLAMEAURA] = 7;
	[SH_BUBBLEWRAP] = 8;
	[SH_THUNDERCOIN] = 9;
}

mobjinfo[MT_XSLINGER_SHIELD] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	spawnhealth = 1000,
	radius = 64*FRACUNIT,
	height = 64*FRACUNIT,
	dispoffset = 4,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_SCENERY,
}

function xSlinger.GiveShieldToMobj(mobj, shieldid)
	if not xSlinger.ShieldDefinitions[shieldid] then return false end

	xSlinger.RemoveShieldFromMobj(mobj)

	mobj.shield_def = xSlinger.ShieldDefinitions[shieldid]

	if mobj.shield_def.health then
		mobj.shield_health = mobj.shield_def.health
	end

	mobj.shield_orb = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_XSLINGER_SHIELD)

	if mobj.shield_def.state then
		mobj.shield_orb.state = mobj.shield_def.state
	end

	if mobj.shield_def.color then
		mobj.shield_orb.color = mobj.shield_def.color
	end

	if mobj.shield_def.colorized then
		mobj.shield_orb.colorized = true
	end

	mobj.shield_orb.target = mobj

	return true
end

function xSlinger.MobjHasShield(mobj)
	if mobj.shield_def or mobj.shield_health then
		return true
	end

	return false
end

function xSlinger.RemoveShieldFromMobj(mobj)
	if mobj.shield_orb and mobj.shield_orb.valid then
		P_RemoveMobj(mobj.shield_orb)
	end

	mobj.shield_orb = nil -- Just in case idk
	mobj.shield_def = nil
	mobj.shield_health = 0
end

addHook("ThinkFrame", function()
	for i,shield in ipairs(xSlinger.CachedShieldMobjs) do
		if not (shield and shield.valid) then
			table.remove(xSlinger.CachedShieldMobjs, i)
			continue
		end

		if shield.target and shield.target.valid then
			local scale = FRACUNIT

			if not shield.target.health or (shield.target.shield_health ~= nil and shield.target.shield_health <= 0) then
				shield.target.shield_orb = nil
				shield.target.shield_def = nil

				if shield.target.player and shield.target.player.valid then
					shield.target.player.powers[pw_shield] = 0
				end

				P_RemoveMobj(shield)
				table.remove(xSlinger.CachedShieldMobjs, i)
				continue
			end

			if shield and shield.valid then -- srb2 being bad, so another check here
				local tx = shield.target.x
				local ty = shield.target.y
				local tz = shield.target.z

				P_MoveOrigin(shield, tx, ty, tz)

				if shield.target.player and shield.target.player.valid then
					local player = shield.target.player

					shield.dontdrawforviewmobj = shield.target
					scale = FixedMul($, player.shieldscale)
				end

				shield.scale = scale
				shield.flags2 = shield.target.flags2
			end
		elseif shield and shield.valid then
			P_RemoveMobj(shield)
			table.remove(xSlinger.CachedShieldMobjs, i)
			continue
		end

		--print("shield cacheid: "..v.shield_cacheid)
	end
end)

addHook("MobjSpawn", function(mobj)
	table.insert(xSlinger.CachedShieldMobjs, mobj)
	mobj.shield_cacheid = #xSlinger.CachedShieldMobjs + 1
end, MT_XSLINGER_SHIELD)

addHook("NetVars", function(net)
	xSlinger.CachedShieldMobjs = net($)
end)

COM_AddCommand("xslinger_giveshield", function(player, shieldtype)
	if not (player.mo and player.mo.valid) then return end
	if (shieldtype == nil or tonumber(shieldtype) == nil) then return end

	if tonumber(shieldtype) <= 0 then
		CONS_Printf(player, "\x82" .. "Cleared shield!")
		xSlinger.RemoveShieldFromMobj(player.mo)
		return
	end

	if not xSlinger.GiveShieldToMobj(player.mo, tonumber(shieldtype)) then
		CONS_Printf(player, "\x85" .. "Invalid shieldtype!")
		return
	end
end, COM_ADMIN)

addHook("ShieldSpawn", function(player)
	local sh = player.powers[pw_shield]

	if convertvanilla[sh] then
		xSlinger.GiveShieldToMobj(player.mo, convertvanilla[sh])
		return true
	elseif (sh & SH_FORCE) then
		xSlinger.GiveShieldToMobj(player.mo, 10)
		return true
	end
end)