freeslot("MT_SHOPKEEPER")
freeslot("SPR_TAK1")

mobjinfo[MT_SHOPKEEPER] = {
    doomednum = 861,
    spawnstate = S_PLAY_STND,
    spawnhealth = 1,
    radius = 32*FRACUNIT,
    height = 48*FRACUNIT,
    flags = MF_SOLID,
}

mobjinfo[MT_SHOPKEEPER].npc_name = "Shop Keeper"
mobjinfo[MT_SHOPKEEPER].npc_spawnhealth = {100,100}
mobjinfo[MT_SHOPKEEPER].disablehealthhud = true

ZE2.ShopkeeperList={
    {
        ["name"]="Sonic", --Shopkeeper's name, this string is also shown when you come close to him
        ["skin"]="sonic", --mobj_t.skin
        ["color"]=SKINCOLOR_BLUE, --mobj_t.color
        ["phrases"]={ --phrases, these supposed to appear when you do shoping
            "Escaping from Zombies, huh?",
            "Hope these items will help", --I suck at making quotes
            "Remember, never step back!"
        }
    },
    {
        ["name"]="Tail-less",
        ["skin"]="tails",
        ["color"]=SKINCOLOR_ORANGE,
        ["phrases"]={
            "Yes, I am the Tail-less fox",
            "Awwww... I am afraid of Zomibes...",
            "Let's look what I have..."
        }
    },
    {
        ["name"]="Knuckles",
        ["skin"]="knuckles",
        ["color"]=SKINCOLOR_RED,
        ["phrases"]={
            "I feel some strange energy around...",
            "Take any of these, they will help you",
            "Found these goodies on my treasure hunting..."
        }
    },
    {
        ["name"]="Amy",
        ["skin"]="amy",
        ["color"]=SKINCOLOR_ROSY,
        ["phrases"]={
            "Have no fear. Amy Rose is here!",
            "These items will definetly help you",
            "I wonder what happened to my darling Sonic..."
        }
    },
    {
        ["name"]="Fang",
        ["skin"]="fang",
        ["color"]=SKINCOLOR_LAVENDER,
        ["phrases"]={
            "Naghhhhh...! I hate these Zombies!",
            "Good defence never hurts",
            "Undeads will beg for mercy with these items"
        }
    },
    {
        ["name"]="Metal Sonic",
        ["skin"]="metalsonic",
        ["color"]=SKINCOLOR_COBALT,
        ["phrases"]={
            "*CLIENT DETECTED. ACTIVATING SHOP*",
            "*ENTERING SELLING MODE*",
            "*I AM THE REAL SONIC!*"
        }
    },
    {
        ["name"]="W",
        ["skin"]="sonic",
        ["color"]=SKINCOLOR_WHITE,
        ["phrases"]={
            "Hey! Welcome to my shop!",
            "W?",
            "Some idiot made phrases for me, they have to be replaced..."
        }
    },
    {
        ["name"]="Bob",
        ["skin"]="fang",
        ["color"]=SKINCOLOR_YELLOW,
        ["phrases"]={
            "Ahoy stranger!",
            "Take any of these and get out of this place!",
            "I hope you have enough rupies to take something with you..."
        }
    },
	{
        ["name"]="Takis",
        ["skin"]="sonic",
        ["color"]=SKINCOLOR_FOREST,
        ["phrases"]={
			"Cheap items for high prices.",
			"I'm not gonna say the line!",
			"It's Sale Hour!",
			"The zombies will be back!??!"
        },
		["forcesprite"] = SPR_TAK1,
    }
}

addHook("MobjCollide", function(mo,pmo)
	if not pmo.player or pmo.skin == "zzombie" or not L_ZCollide(mo,pmo) then
        return
    end
    if not pmo.player.shop_open and not pmo.player.shop_delay then
        pmo.player.shop_open = true
        mo.phrase=P_RandomKey(#mo.phrases)+1 --random phrase to be shown on the screen
        pmo.player.shop_person = mo
        pmo.player["ze2_info"].shop_selection = 1
    end
end, MT_SHOPKEEPER)

addHook("MobjThinker", function(mobj)
	if mobj.shopid and ZE2.ShopkeeperList[mobj.shopid]["forcesprite"] then
		mobj.sprite = ZE2.ShopkeeperList[mobj.shopid]["forcesprite"]
		mobj.tics = 2500000 -- dont be cringe
	end
end, MT_SHOPKEEPER)

addHook("MobjSpawn", function(mobj)
    mobj.state = S_PLAY_STND

    local rand = P_RandomRange(1,#ZE2.ShopkeeperList)

	mobj.shopid = rand
    mobj.alias=ZE2.ShopkeeperList[rand]["name"]
    mobj.skin=ZE2.ShopkeeperList[rand]["skin"]
    mobj.color=ZE2.ShopkeeperList[rand]["color"]
    mobj.phrases=ZE2.ShopkeeperList[rand]["phrases"]

    mobj.shop = {}
    local itemlist = {}
	for i=1,#ZE2.ItemPresets do
		if ZE2.ItemPresets[i] and ZE2.ItemPresets[i].price then
			table.insert(itemlist, i)
		end
	end
    for i=1,P_RandomRange(3,6) do
        local rng = P_RandomRange(1,#itemlist) 
        local choseitem = itemlist[rng]
        local item = ZE2:CopyItemFromID(choseitem)

        table.remove(itemlist,rng) -- no repeating items

        --local offset = P_SignedRandom()>>4 --unused idea I guess?
        --for tt=1,i do -- more rng?
        --    offset = P_SignedRandom()>>4
        --end
        mobj.shop[i] = {}
        mobj.shop[i][1] = item.price 
        mobj.shop[i][2] = item
    end
end,MT_SHOPKEEPER)

addHook("PlayerThink", function(player)
    if player.mo and player.mo.valid then
        if player.shop_person and player.shop_person.shop then
            local itemchoosing = player.shop_person.shop[player["ze2_info"].shop_selection][2]

            if not itemchoosing and player["ze2_info"].shop_confirmscreen then
                player["ze2_info"].shop_confirmscreen = false
                S_StartSound(nil, sfx_notadd, player)
            end
        end
        if not player.shop_open then
            player.shop_open = false
        end
        if not player.shop_anim then
            player.shop_anim = 0
        end

        if player.shop_open and player.shop_anim <= (35 + 35/2) then
            player.shop_anim = $ + 1
        elseif not player.shop_open and player.shop_anim then
            player.shop_anim = $ - 1
        end

        if ZE2.game_ended or player.zteam == 2 then
            player.shop_anim = 0
            player.shop_open = false
        end

        if player.shop_anim == 0 then
            player.shop_person = nil
        end
    end
end)

addHook("PreThinkFrame", do
    for player in players.iterate do
        if player.mo and player.mo.valid and player["ze2_info"] then
            local cmd = player.cmd

			--var = function(set)
            if player.shop_open and not player.shop_delay and player.shop_person then
				-- Left Press
				ZE2:TryBooleanAction(player, {
					condition = (cmd.sidemove < -40) and (not player["ze2_info"].shop_confirmscreen),
					var = "shop_leftpressed",
					action = function()
						S_StartSound(nil, sfx_s3kb7, player)
						
                        if (player["ze2_info"].shop_selection - 1 <= 0) then 
							player["ze2_info"].shop_selection = #player.shop_person.shop
                        else 
							player["ze2_info"].shop_selection = $ - 1 
						end
					end,
				}, true)
				
				-- Right Press
				ZE2:TryBooleanAction(player, {
					condition = (cmd.sidemove > 40) and (not player["ze2_info"].shop_confirmscreen),
					var = "shop_rightpressed",
					action = function()
                        S_StartSound(nil, sfx_s3kb7, player)
						
                        if player["ze2_info"].shop_selection + 1 > #player.shop_person.shop then
                            player["ze2_info"].shop_selection = 1
                        else
                           player["ze2_info"].shop_selection = $ + 1
                        end
					end,
				}, true)

				-- Close Shop / Exit Confirm Screen
				ZE2:TryBooleanAction(player, {
					condition = cmd.buttons & BT_SPIN,
					var = "shop_exitpressed",
					action = function()
                        if player["ze2_info"].shop_confirmscreen then 
							-- Exit Confirm Screen
                            player["ze2_info"].shop_confirmscreen = false
                            S_StartSound(nil, sfx_notadd, player)
                        else
							-- Exit Shop Entirely
                            player.shop_open = false
                            player.shop_delay = TICRATE*2   
                        end
					end,
				}, true)
				
				-- Enter Confirm Screen / Buy Item
				ZE2:TryBooleanAction(player, {
					condition = (
						(cmd.buttons & BT_JUMP) 
						and player.shop_person.shop 
						and player.shop_person.shop[player["ze2_info"].shop_selection][2]
					),
					var = "shop_selectpressed",
					action = function()
						local hasrequiredrubies = player.rubies >= player.shop_person.shop[player["ze2_info"].shop_selection][1]

                        if hasrequiredrubies and not player["ze2_info"].shop_confirmscreen then
                            S_StartSound(nil, sfx_s3kb8, player)
                            player["ze2_info"].shop_confirmscreen = true
                        elseif player["ze2_info"].shop_confirmscreen and hasrequiredrubies then 
							-- actually buy
                            player.rubies = $ - player.shop_person.shop[player["ze2_info"].shop_selection][1]
							
                            -- copied from ZE2:FetchInventory()
                            if player["ze2_info"].survivor_inventory and player.zteam == 1 then
                                if ZE2:IsInventoryFull(player) or (player.cmd.buttons & BT_CUSTOM1) then
                                    player["ze2_info"].survivor_inventory[player["ze2_info"].inventory_selection] =  player.shop_person.shop[player["ze2_info"].shop_selection][2]
                                else
                                    table.insert(player["ze2_info"].survivor_inventory, player.shop_person.shop[player["ze2_info"].shop_selection][2])
                                end
                            elseif player["ze2_info"].zombie_inventory and player.zteam == 2 then
                                if ZE2:IsInventoryFull(player) or (player.cmd.buttons & BT_CUSTOM1) then
                                    player["ze2_info"].zombie_inventory[player["ze2_info"].inventory_selection] = player.shop_person.shop[player["ze2_info"].shop_selection][2]
                                else
                                    table.insert(player["ze2_info"].zombie_inventory, player.shop_person.shop[player["ze2_info"].shop_selection][2])
                                end
                            else
								error("Could not fetch inventory.",2) 
							end
							
                            S_StartSound(nil, sfx_s3kb8, player)
                            player["ze2_info"].shop_confirmscreen = false
                            player.shop_person.shop[player["ze2_info"].shop_selection][2] = nil
                        else
							S_StartSound(nil, sfx_lose, player)
						end
					end,
				}, true)
				
				cmd.buttons = 0
				cmd.forwardmove = 0
				cmd.sidemove = 0
            end
			
            if player.shop_delay then
                player.shop_delay = $ - 1
            end
        end
    end
end)

addHook("PlayerSpawn", function(p)
    p.shop_open = false
    p.shop_anim = 0
end)