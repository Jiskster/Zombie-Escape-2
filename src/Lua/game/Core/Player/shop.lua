local SHOP_MAX = 3

ZE2.Shop = {
	list = {}, -- items that have a chance to appear in shop (Don't Archive)
	stock = {}, -- items that are in shop right now
}

function ZE2.Shop.listItem(itemname, cost)
	local shop = ZE2.Shop
	local newlist = {
		id = itemname,
		price = cost,
	}
	
	local list = ZE2.Shop.list
	list[#list + 1] = newlist
end

function ZE2.Shop.refreshStock()
	for i,v in pairs(ZE2.Shop.stock) do
		ZE2.Shop.stock[i] = nil
	end
	
	local list = ZE2.Shop.list
	local untried = {} -- untried list
	
	for i=1,#list do
		untried[#untried + 1] = list[i]
	end
	
	for i=1,SHOP_MAX do
		local random_index = P_RandomRange(1, #untried)
		local chosen_item = untried[random_index]
		
		ZE2.Shop.stock[i] = {
			id = chosen_item.id,
			price = chosen_item.price,
		}

		table.remove(untried, random_index)
	end
end

function ZE2.RefundPlayer(player)
	for i,stockitem in ipairs(player.ze2.purchased) do
		ZE2:GivePlayerCash(player, stockitem.price)
	
		player.ze2.purchased[i] = nil
	end
end

ZE2.Shop.listItem("grenade_ring", 105)
ZE2.Shop.listItem("apple", 150)
ZE2.Shop.listItem("red_ring", 250)
ZE2.Shop.listItem("wood_fence", 350)
ZE2.Shop.listItem("accel_ring", 375)
ZE2.Shop.listItem("auto_ring", 450)
ZE2.Shop.listItem("blue_spring", 515)
ZE2.Shop.listItem("scatter_ring", 625)
ZE2.Shop.listItem("bounce_ring", 650)
ZE2.Shop.listItem("auto_turret", 735)
ZE2.Shop.listItem("flame_ring", 800)
ZE2.Shop.listItem("explosion_ring", 900)
ZE2.Shop.listItem("energy_drink", 1200)
ZE2.Shop.listItem("rail_ring", 1600)

addHook("NetVars", function(net)
	ZE2.Shop.stock = net($)
end)

addHook("MapLoad", function(map)
	ZE2.Shop.refreshStock()
end)