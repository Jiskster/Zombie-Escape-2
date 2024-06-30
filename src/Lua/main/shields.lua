-- NOTE: mobj_t.shield_def shouldn't be edited. It's a reference.

ZE2.CachedShieldMobjs = {}

-- Don't Synch
ZE2.ShieldDefinitions = {
	[1] = {
		name = "Pity",
		health = 75,
		state = S_PITY1,
		color = SKINCOLOR_MOSS,
	}
}

freeslot("MT_ZE2_SHIELD")

mobjinfo[MT_ZE2_SHIELD] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	spawnhealth = 1000,
	radius = 64*FRACUNIT,
	height = 64*FRACUNIT,
	dispoffset = 4,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_SCENERY,
}

function ZE2:GiveShieldToMobj(mobj, shieldid)
	if not ZE2.ShieldDefinitions[shieldid] then return false end
	
	mobj.shield_def = ZE2.ShieldDefinitions[shieldid]
	
	if mobj.shield_def.health then
		mobj.shield_health = mobj.shield_def.health
	end
	
	mobj.shield_orb = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_ZE2_SHIELD)
	
	if mobj.shield_def.state then
		mobj.shield_orb.state = mobj.shield_def.state
	end
	
	mobj.shield_orb.target = mobj
	
	return true
end

function ZE2:RemoveShieldFromMobj(mobj)
	if mobj.shield_orb and mobj.shield_orb.valid then
		P_RemoveMobj(mobj.shield_orb)
		mobj.shield_orb = nil -- Just in case idk
	end
	
	mobj.shield_def = nil
	mobj.sheild_health = 0
end

addHook("MapLoad", function()
	ZE2.CachedShieldMobjs = {}
end)

addHook("ThinkFrame", function()
	for i,v in pairs(ZE2.CachedShieldMobjs) do
		if not (v and v.valid) then
			table.remove(ZE2.CachedShieldMobjs, i)
			continue
		end
		
		--print("shield cacheid: "..v.shield_cacheid)
	end
end)

addHook("MobjThinker", function(shield)
	if not (shield and shield.valid) then return end

	if shield.target and shield.target.valid then
		local scale = FRACUNIT
		
		if not shield.target.health or (shield.target.shield_health ~= nil and shield.target.shield_health <= 0) then
			shield.target.shield_orb = nil
			shield.target.shield_def = nil
			
			P_RemoveMobj(shield)
		end
		
		if shield and shield.valid then -- srb2 being bad, so another check here
			local tx = shield.target.x
			local ty = shield.target.y
			local tz = shield.target.z
			
			P_MoveOrigin(shield, tx, ty, tz)
				
			if shield.target.player and shield.target.player.valid then
				local player = shield.target.player
				
				scale = FixedMul($, player.shieldscale)
			end
			
			shield.scale = scale
			shield.flags2 = shield.target.flags2
		end
	end
end, MT_ZE2_SHIELD)

addHook("MobjSpawn", function(mobj)
	table.insert(ZE2.CachedShieldMobjs, mobj)
	mobj.shield_cacheid = #ZE2.CachedShieldMobjs
end, MT_ZE2_SHIELD)