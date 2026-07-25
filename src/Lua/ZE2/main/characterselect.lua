-- All variables are client side
ZE2.charsel_selection = 1
ZE2.charsel_prevselection = 1

ZE2.charsel_anim = 0
ZE2.charsel_setanim = 13

-- 1: character select
-- 2: main menu
-- 3: shop
ZE2.pregame_menu = 1

local lastsidemove = 0
local lastbuttons = 0

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

addHook("PlayerCmd", function(player, cmd)
	if (player.spectator) then
		return end;

    if (ZE2.round_active) then
        return end;

    if (displayplayer and displayplayer.valid)
    and (player ~= displayplayer) then -- Don't activate when spectating someone else.
        return end;

	if ZE2.charsel_anim then
		ZE2.charsel_anim = $ - 1
	end

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
    end

	lastsidemove = cmd.sidemove
	lastbuttons = cmd.buttons

	cmd.sidemove = 0
	cmd.forwardmove = 0
	cmd.buttons = 0
end)

addHook("ThinkFrame", function()
    if gametype ~= GT_ZE2 then
        return end;

    local playercount = ZE2.PlayerCount()
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
local function unselectCharacter(player)
	if not (player and player.valid) then
		return false end;

	local selchar = player.ze2.selected_character
	local selnum = skinToNum(player, selchar)
	local selcharslot = ZE2.CharacterSlots[selnum]

	if selchar and selcharslot then
		selcharslot.count = $ - 1 -- give back character slot before getting another
	end

	return true
end

COM_AddCommand("_z_choosecharacter", function(player, skinname)
    if not (player.mo and player.mo.valid and player.mo.health) then
        return end;

    if not (skinname) then
        return end;

    if not (ZE2.SurvivorConfig[skinname]) then
        return end;

    if (ZE2.round_active) then
        return end;

    if (ZE2.pregame_menu ~= 1) then
        return end;

    if (consoleplayer and consoleplayer.valid)
    and (consoleplayer == player) then
        --ZE2.pregame_menu = 2
    end

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

		S_StartSound(nil, sfx_s3k63, player)
	else
		S_StartSound(nil, sfx_lose, player)
	end
end)

addHook("PlayerQuit", function(player)
	unselectCharacter(player)
end)

-- NOW add the players

ZE2.CharacterSlots = {}

for i,v in ipairs(ZE2.registered_skins) do
	ZE2.CharacterSlots[i] = {
		count = 0;
		max = 1;
	}
end
