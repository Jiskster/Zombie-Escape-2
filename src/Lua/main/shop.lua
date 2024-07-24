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

ZE2.Zombie_ShopList = {

}

function ZE2:RegisterShop_ItemID(item_id)
	local iteminfo = ZE2:CopyItemFromID(item_id)
	local shop_def = {}
	
	shop_def.name = iteminfo.displayname
	shop_def.iteminfo = iteminfo
	shop_def.price = iteminfo.price
	
	table.insert(ZE2.ShopDefinitions, shop_def)
	return #ZE2.ShopDefinitions
end

function ZE2:RegisterGenericShop(name, input_table, price)
	local shop_def = input_table
	shop_def.name = name
	shop_def.price = price
	
	table.insert(ZE2.ShopDefinitions, shop_def)
	return #ZE2.ShopDefinitions
end

function ZE2.NumToShopDef(number)
	return ZE2.ShopDefinitions[number]
end

local ZMBSHOP_100BONUSHP = ZE2:RegisterGenericShop("100_Bonus_HP", {
	realname = "100 Bonus Health", -- For Zombie Shop Display
	buyfunc = function(player)
		player["ze2_info"].zombie_healthbonus = $ + 100
	end,
	for_zombies = true,
}, 25)

local ZMBSHOP_ALPHA_ZOMBIE = ZE2:RegisterGenericShop("Alpha_Zombie", {
	realname = "Alpha Zombie",
	buyfunc = function(player)
		player["ze2_info"].zombie_next_type = "alpha"
	end,
	for_zombies = true,
}, 500)

local ZMBSHOP_SIGMA_ZOMBIE = ZE2:RegisterGenericShop("Sigma_Zombie", {
	realname = "Sigma Zombie",
	buyfunc = function(player)
		player["ze2_info"].zombie_next_type = "sigma"
	end,
	for_zombies = true,
}, 1000)

ZE2.Zombie_ShopList = {
	ZMBSHOP_100BONUSHP,
	ZMBSHOP_ALPHA_ZOMBIE,
	ZMBSHOP_SIGMA_ZOMBIE
}

addHook("MapLoad", function()
	if gametype ~= GT_ZE2 then return end
	
	ZE2.Survivor_ShopList = {} -- clear
	
	local shopdef_numsleft = {}
    local picked_shopdefs = {}
	local itemnumsdiscarded = {}
	local numitemstolist = 6 --P_RandomRange(3,6)
	local numitemstolistleft = numitemstolist
	local tries = 0
	
	for i,v in ipairs(ZE2.ShopDefinitions) do
		/*
		for ii,vv in pairs(v)
			print(tostring(ii).." : "..tostring(vv))
		end
		*/
		
		if v.for_zombies then 
			continue 
		end
		
		table.insert(shopdef_numsleft, i)
	end
	
	while numitemstolistleft > 0 do
		local rng = P_RandomRange(1,#shopdef_numsleft)
		local foundrepeat = false -- im paranoid and i found a repeat during testing
		
		if not ZE2.repeatshopitems.value then
			for i,v in ipairs(itemnumsdiscarded) do
				if v == rng then
					foundrepeat = true
					break;
				end
			end
		end
		
		if not foundrepeat then
			table.insert(picked_shopdefs, {
				shopdefid = shopdef_numsleft[rng],
				sold = false,
			})
			
			if not ZE2.repeatshopitems.value then
				table.insert(itemnumsdiscarded, shopdef_numsleft[rng])
				table.remove(shopdef_numsleft, rng)
			end
			
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

-- Handle Zombie Shop
addHook("PlayerThink", function(player)
	local cmd = player.cmd
	
	if ZE2.game_ended then
		return
	end
	
	if player.playerstate == PST_DEAD then
		if player["ze2_info"].team == 2 then
			--player["ze2_info"].zombie_shop_open = true
			
			if player["ze2_info"].zombie_shop_open then
				ZE2:TryBooleanAction(player, {
					condition = cmd.forwardmove > 40,
					var = "zombie_shop_forward_pressed",
					action = function()
						if player["ze2_info"].zombie_shop_selection - 1 <= 0 then
							player["ze2_info"].zombie_shop_selection = 1
						else
							player["ze2_info"].zombie_shop_selection = $ - 1
						end
						
						S_StartSound(nil, sfx_menu1, player)
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = cmd.forwardmove < -40,
					var = "zombie_shop_backwards_pressed",
					action = function()
						if player["ze2_info"].zombie_shop_selection + 1 >= #ZE2.Zombie_ShopList then
							player["ze2_info"].zombie_shop_selection = #ZE2.Zombie_ShopList
						else
							player["ze2_info"].zombie_shop_selection = $ + 1
						end
						
						S_StartSound(nil, sfx_menu1, player)
					end
				}, true)
				
				ZE2:TryBooleanAction(player, {
					condition = cmd.buttons & BT_CUSTOM1,
					var = "zombie_shop_c1_pressed",
					action = function()
						local selection = player["ze2_info"].zombie_shop_selection
						
						if ZE2.Zombie_ShopList[selection] then
							local shopdef = ZE2.NumToShopDef(ZE2.Zombie_ShopList[selection])
						
							if shopdef then
								if shopdef.price > player["ze2_info"].blood_currency then
									S_StartSound(nil, sfx_lose, player)
								else
									player["ze2_info"].blood_currency = $ - shopdef.price
									
									if shopdef.buyfunc then
										shopdef.buyfunc(player)
									end
								
									S_StartSound(nil, sfx_s1a1, player)
								end
							end
						end
					end
				}, true)
			else
				ZE2:TryBooleanAction(player, {
					condition = cmd.buttons & BT_CUSTOM1,
					var = "zombie_shop_c1_pressed",
					action = function()
						player["ze2_info"].zombie_shop_open = true
					end
				}, true)
			end
		end
	end
end)