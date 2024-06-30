freeslot("MT_SHOPKEEPER")
freeslot("SPR_TAK1")

mobjinfo[MT_SHOPKEEPER] = {
    doomednum = 861,
    spawnstate = S_NULL,
    spawnhealth = 1,
    radius = 32*FRACUNIT,
    height = 48*FRACUNIT,
    flags = MF_SOLID,
}

mobjinfo[MT_SHOPKEEPER].npc_name = "Shop Keeper"
mobjinfo[MT_SHOPKEEPER].npc_spawnhealth = {100,100}
mobjinfo[MT_SHOPKEEPER].disablehealthhud = true

ZE2.ShopDefinitions = {

}

-- Number References only
ZE2.Survivor_ShopList = {
	
}

function ZE2:RegisterShopItem(item_id)
	local iteminfo = ZE2:CopyItemFromID(item_id)
	local shop_def = {}
	
	shop_def.name = iteminfo.displayname
	shop_def.iteminfo = iteminfo
	shop_def.price = iteminfo.price
	
	table.insert(ZE2.ShopDefinitions, shop_def)
end

function ZE2.NumToShopDef(number)
	return ZE2.ShopDefinitions[number]
end

addHook("MapLoad", function()
	if gametype ~= GT_ZE2 then return end
	
	ZE2.Survivor_ShopList = {} -- clear
	
	local shopdef_numsleft = {}
    local picked_shopdefs = {}
	--local itemnumsdiscarded = {}
	local numitemstolist = 6 --P_RandomRange(3,6)
	local numitemstolistleft = numitemstolist
	local tries = 0
	
	for i,v in ipairs(ZE2.ShopDefinitions) do
		table.insert(shopdef_numsleft, i)
	end
	
	while numitemstolistleft > 0 do
		local rng = P_RandomRange(1,#shopdef_numsleft)
		local foundrepeat = false -- im paranoid and i found a repeat during testing
		
		/*
		for i,v in ipairs(itemnumsdiscarded) do
			if v == rng then
				foundrepeat = true
				break;
			end
		end
		*/
		
		if not foundrepeat then
			table.insert(picked_shopdefs, {
				shopdefid = rng,
				sold = false,
			})
			--table.insert(itemnumsdiscarded, rng)
			--table.remove(shopdef_numsleft, rng)
			numitemstolistleft = $ - 1
		end
		
		if tries >= 100 then
			error("Recursion Error (How did this happen??)")
			break;
		end
		
		tries = $ + 1
	end
	
	ZE2.Survivor_ShopList = picked_shopdefs
	
	/*
	for i,v in ipairs(ZE2.Survivor_ShopList) do
		print(ZE2.ShopDefinitions[v.shopdefid].name)
	end
	*/
	
	for player in players.iterate do
		player["ze2_info"].shop_selection = 1
	end
end)