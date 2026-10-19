freeslot("MT_ZE2_RANDOMITEM_SPAWN")

local pool = {
	"auto_ring",
	"bounce_ring",
	"scatter_ring",
	"explosion_ring",
	"rail_ring",
	"apple",
	"energy_drink",
	"accel_ring",
	"splash_ring",
	"stone_ring",
}


-- Mapthing
mobjinfo[MT_ZE2_RANDOMITEM_SPAWN] = {
	//$Category Zombie Escape 2
	//$Name Random Item Spawn

	//$StringArg0 Item ID

	doomednum = 5601,

	spawnhealth = 1000,
	radius = 32*FU,
	height = 32*FU,
	spawnstate = S_INVISIBLE,
	deathstate = S_INVISIBLE,
	flags = MF_NOBLOCKMAP,
}

addHook("MapThingSpawn", function(mobj, mapthing)
	if not (mobj and mobj.valid) then
		return end;
	
	if P_RandomChance(FU/3) then
		local item_id = pool[P_RandomRange(1,#pool)]
		xSlinger.SpawnItemDrop(mobj, item_id, true)
	end
end, MT_ZE2_RANDOMITEM_SPAWN)