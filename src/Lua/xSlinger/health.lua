function xSlinger.ChangeHealth(mobj, amount)
	if mobj.health + amount > mobj.maxhealth then
		mobj.health = mobj.maxhealth
	else
		mobj.health = $ + amount
	end
end

addHook("MobjSpawn", function(mobj)
	if mobjinfo[mobj.type].npc_name then
		if mobjinfo[mobj.type].spawnhealth and type(mobjinfo[mobj.type].npc_spawnhealth) == "table" then
			local rng_health = P_RandomRange(mobjinfo[mobj.type].npc_spawnhealth[1],mobjinfo[mobj.type].npc_spawnhealth[2])
			mobj.health = rng_health
			mobj.maxhealth = mobj.health
		else
			mobj.maxhealth = mobj.health
		end
	end

	if mobjinfo[mobj.type].disablehealthhud then
		mobj.dontshowhealth = true
	end

	mobj.shield_health = 0
	mobj.shield_efficiency = 0
end)