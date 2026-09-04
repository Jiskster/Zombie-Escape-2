-- All variables under here are client side
ZE2.charsel_selection = 1
ZE2.charsel_prevselection = 1

ZE2.charsel_anim = 0
ZE2.charsel_setanim = 13

ZE2.charsel_exit_anim = 0
ZE2.charsel_set_exit_anim = 16

ZE2.shop_selection = 1

ZE2.shop_enter_anim = 0
ZE2.shop_set_enter_anim = 16

ZE2.shop_anim = 0
ZE2.shop_set_anim = 2

ZE2.shop_oncontinue = false

-- 1: character select
-- 2: shop

ZE2.pregame_menu = 1

local lastforwardmove = 0
local lastsidemove = 0
local lastbuttons = 0

-- Now ignore what I said.

-- This var is synced.
ZE2.CharacterSlots = {}

-- https://github.com/Rapidgame7/srb2utils/blob/main/1_Usable/amperlib/amperlib.lua
local function valWrap(n, min, max) -- Wrap value if it surpasses either bounds
	if n == nil then error("#1 nil", 2) end
	if min == nil then error("#2 nil", 2) end
	if max == nil then error("#3 nil", 2) end
	if min > max then
		min,max = max,min
	end
	local dist = abs(min - max)+1
	while n > max do n = n - dist end
	while n < min do n = n + dist end
	return n
end

local function convertCharacterSelection(selection, player)
    local skinlist = ZE2.getSkinNums(player)
	local maxchars = #skinlist
	local wr = valWrap(selection, 1, maxchars)

	return wr
end

ZE2.convertCharacterSelection = convertCharacterSelection

local function skinToNum(player, skin)
    local skinlist = ZE2.getSkinNames(player)

    for i,name in ipairs(skinlist) do
        if name == skin then
            return i
        end
    end
end

local function nullCmd(cmd)
	lastforwardmove = cmd.forwardmove
	lastsidemove = cmd.sidemove
	lastbuttons = cmd.buttons

	cmd.sidemove = 0
	cmd.forwardmove = 0
	cmd.buttons = 0
end

addHook("PlayerCmd", function(player, cmd)
	local game = ZE2.Game

	if not multiplayer then
		return
	end
	
	if (player.spectator) then
		return end;

    if (game.active) then
        return end;

    if (displayplayer and displayplayer.valid)
    and (player ~= displayplayer) then -- Don't activate when spectating someone else.
		nullCmd(cmd)
		return
	end

	if ZE2.charsel_anim then
		ZE2.charsel_anim = $ - 1
	end
	
	if ZE2.charsel_exit_anim > 0 then
		ZE2.charsel_exit_anim = $ - 1
	elseif ZE2.charsel_exit_anim < 0 then
		ZE2.charsel_exit_anim = $ + 1
	end
	
	if ZE2.shop_enter_anim > 0 then
		ZE2.shop_enter_anim = $ - 1
	elseif ZE2.shop_enter_anim < 0 then
		ZE2.shop_enter_anim = $ + 1
	end
	
	if ZE2.shop_anim then
		ZE2.shop_anim = $ - 1
	end
	
	-- TODO: Simplify this part
    if (ZE2.pregame_menu == 1) then
        if (not lastsidemove) and (cmd.sidemove) then
            if (cmd.sidemove < 0) then
                ZE2.charsel_prevselection = ZE2.charsel_selection

                ZE2.charsel_selection = $ - 1
                ZE2.charsel_selection = valWrap($, INT32_MIN, INT32_MAX)

                ZE2.charsel_anim = ZE2.charsel_setanim
                S_StartSound(nil, sfx_s3kb7, player)
            elseif (cmd.sidemove > 0) then
                ZE2.charsel_prevselection = ZE2.charsel_selection

                ZE2.charsel_selection = $ + 1
                ZE2.charsel_selection = valWrap($, INT32_MIN, INT32_MAX)

                ZE2.charsel_anim = ZE2.charsel_setanim
                S_StartSound(nil, sfx_s3kb7, player)
            end
        end

        if not (lastbuttons & BT_JUMP) and (cmd.buttons & BT_JUMP) then
            local charselection = convertCharacterSelection(ZE2.charsel_selection, player)
            local skinlist = ZE2.getSkinNums(player)
            local skindata = skins[skinlist[charselection]]
            local skinname = skindata.name

            COM_BufAddText(player, "_z_choosecharacter "..skinname)
        end
    elseif (ZE2.pregame_menu == 2) then
		if not ZE2.shop_oncontinue then
			if (not lastsidemove) and (cmd.sidemove) then
				local shop = ZE2.Shop
				if (cmd.sidemove < 0) then
					ZE2.shop_selection = $ - 1
					ZE2.shop_selection = valWrap($, 1, #shop.stock)

					S_StartSound(nil, sfx_menu1, player)
					
					ZE2.shop_anim = ZE2.shop_set_anim
				elseif (cmd.sidemove > 0) then
					ZE2.shop_selection = $ + 1
					ZE2.shop_selection = valWrap($, 1, #shop.stock)

					S_StartSound(nil, sfx_menu1, player)
					
					ZE2.shop_anim = ZE2.shop_set_anim
				end
			end
			
			if (not lastforwardmove) and (cmd.forwardmove < 0) then
				ZE2.shop_oncontinue = true
				ZE2.shop_anim = ZE2.shop_set_anim
				S_StartSound(nil, sfx_menu1, player)
			end
			
			if not (lastbuttons & BT_SPIN) and (cmd.buttons & BT_SPIN) then
				S_StartSound(nil, sfx_adderr, player)
				ZE2.charsel_exit_anim = -ZE2.charsel_set_exit_anim
				ZE2.shop_enter_anim = -ZE2.shop_set_enter_anim 
				ZE2.pregame_menu = 1
				
				COM_BufAddText(player, "_z_unselectcharacter 1")
			elseif not (lastbuttons & BT_JUMP) and (cmd.buttons & BT_JUMP) then
				COM_BufAddText(player, "_z_shopbuy "..ZE2.shop_selection)
			end
		elseif ZE2.shop_oncontinue then
			if (not lastforwardmove) and (cmd.forwardmove > 0) then
				ZE2.shop_oncontinue = false
				ZE2.shop_anim = ZE2.shop_set_anim
				S_StartSound(nil, sfx_menu1, player)
			end
			
			if not (lastbuttons & BT_JUMP) and (cmd.buttons & BT_JUMP) then
				S_StartSound(nil, sfx_drill1, player)
				ZE2.shop_enter_anim = -ZE2.shop_set_enter_anim
				ZE2.pregame_menu = 3
			end
		end
	elseif (ZE2.pregame_menu == 3) then
		if not (lastbuttons & BT_SPIN) and (cmd.buttons & BT_SPIN) then
			S_StartSound(nil, sfx_adderr, player)
			ZE2.shop_enter_anim = ZE2.shop_set_enter_anim 
			ZE2.pregame_menu = 2
		end
	end

	nullCmd(cmd)
end)

addHook("ThinkFrame", function()
    if not multiplayer then
        return end;

    local playercount = ZE2.CountPlayers("ingame")
    local slotspacecount = 0

    for sknum,tb in ipairs(ZE2.CharacterSlots) do
        slotspacecount = $ + (tb.max)
    end

    while playercount > slotspacecount do
        local rngskin = P_RandomRange(1,#ZE2.CharacterSlots)

        ZE2.CharacterSlots[rngskin].max = $ + 1

        -- Reset slotspacecount and recalculate
        slotspacecount = 0
        for sknum,tb in ipairs(ZE2.CharacterSlots) do
            slotspacecount = $ + (tb.max)
        end
    end
end)

-- Make this a global if you need it.
local function unselectCharacter(player, refund)
	if not (player and player.valid) then
		return false end;

	local selchar = player.ze2.selected_character
	local selnum = skinToNum(player, selchar)
	local selcharslot = ZE2.CharacterSlots[selnum]

	if selchar and selcharslot then
		selcharslot.count = $ - 1 -- give back character slot before getting another
		player.ze2.selected_character = nil
	end

	if refund then
		ZE2.RefundPlayer(player)
	end

	return true
end

COM_AddCommand("_z_choosecharacter", function(player, skinname)
	local game = ZE2.Game
	
    if not (player.mo and player.mo.valid and player.mo.health) then
        return end;

    if not (skinname) then
        return end;

    if not (ZE2.SurvivorConfig[skinname]) then
        return end;

    if (game.active) then
        return end;

    local skinnum = skinToNum(player, skinname)
    local chslot = ZE2.CharacterSlots[skinnum]

	if chslot.count < chslot.max then
		if not unselectCharacter(player) then
			return
		end

		chslot.count = $ + 1 -- take character slot
		ZE2.switchCharacter(player, skinname)
		player.ze2.selected_character = skinname
		ZE2.setConfigInventory(player, skinname)
		ZE2.resetPlayerHealth(player, skinname)

		if P_IsLocalPlayer(player) then
			ZE2.charsel_exit_anim = ZE2.charsel_set_exit_anim
			ZE2.shop_enter_anim = ZE2.shop_set_enter_anim 
			ZE2.pregame_menu = 2
		end

		S_StartSound(nil, sfx_s3k63, player)
	else
		S_StartSound(nil, sfx_lose, player)
	end
end)

COM_AddCommand("_z_unselectcharacter", function(player, refund)
	local game = ZE2.Game
	
    if not (player.mo and player.mo.valid and player.mo.health) then
        return end;
		
    if (game.active) then
        return end;
	
	unselectCharacter(player, refund)
end)

COM_AddCommand("_z_shopbuy", function(player, stocknum)
	local game = ZE2.Game
	
	if not (player.mo and player.mo.valid and player.mo.health) then
        return end;
		
    if (game.active) then
        return end;
		
	if not (tonumber(stocknum)) then
		return end;
		
	local shop = ZE2.Shop
	local stockitem = shop.stock[tonumber(stocknum)] 
	if stockitem then
		local ze2 = player.ze2
		local xS = player.xSlinger
		
		if stockitem.price <= ze2.cash then
			ze2.cash = $ - stockitem.price
			
			table.insert(ze2.purchased, {
				id = stockitem.id,
				price = stockitem.price,
			})
			
			xS:give_item(stockitem.id)
			S_StartSound(nil, sfx_addfil, player)
		else -- you broke as fuck
			S_StartSound(nil, sfx_lose, player)
		end
		
		if P_IsLocalPlayer(player) then
			ZE2.shop_anim = ZE2.shop_set_anim
		end
	end
end)

addHook("PlayerQuit", function(player)
	unselectCharacter(player)
end)

addHook("MapChange", function()
	ZE2.CharacterSlots = {}

	for i,v in ipairs(ZE2.registered_skins) do
		ZE2.CharacterSlots[i] = {
			count = 0;
			max = 1;
		}
	end

	ZE2.charsel_selection = 1;
	ZE2.charsel_prevselection = 1;
	ZE2.pregame_menu = 1;
	
	ZE2.charsel_exit_anim = 0;
	
	ZE2.shop_enter_anim = 0;
	ZE2.shop_selection = 1;
	ZE2.shop_anim = 0;
	ZE2.shop_oncontinue = false;
end)

addHook("NetVars", function(net)
    ZE2.CharacterSlots = net($)
end)
