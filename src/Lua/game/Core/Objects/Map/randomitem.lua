freeslot("MT_ZE2_RANDOMITEM_SPAWN")

ZE2.RandomItemPool = {
	"red_ring",
	"auto_ring",
	"bounce_ring",
	"scatter_ring",
	"explosion_ring",
	"rail_ring",
	"apple",
	"wood_fence",
	"energy_drink",
	"accel_ring",
	"splash_ring",
	"stone_ring",
	"flame_ring",
	"volt_ring",
	"steel_fence",
}


-- Mapthing
mobjinfo[MT_ZE2_RANDOMITEM_SPAWN] = {
	//$Category Zombie Escape 2
	//$Name Random Item Spawn
	//$sprite TVMYC0

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
	
	if P_RandomChance(FU/2) then
		local item_id = ZE2.RandomItemPool[P_RandomRange(1,#ZE2.RandomItemPool)]
		local drop = xSlinger.SpawnItemDrop(mobj, item_id, true)
		local iteminfo = drop.iteminfo
		local count = iteminfo:get("count")
		local maxcount = iteminfo:get("maxcount")
		if (count ~= -1) and (maxcount ~= -1) then
			local newcount = P_RandomRange(1, maxcount)
			iteminfo:set("count", newcount)
		end
	end
end, MT_ZE2_RANDOMITEM_SPAWN)

addHook("NetVars", function(net)
	ZE2.RandomItemPool = net($)
end)