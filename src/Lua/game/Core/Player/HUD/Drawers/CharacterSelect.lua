local min = min
local max = max
local FU = FU
local V_ALPHASHIFT = V_ALPHASHIFT
local V_SNAPTOLEFT = V_SNAPTOLEFT
local V_SNAPTOTOP = V_SNAPTOTOP
local FixedDiv = FixedDiv
local FixedMul = FixedMul
local drawScaled
local drawString
local drawFill
local drawLevelTitle
local getSprite2Patch
local getColormap
local cachePatch
local select_ease = ease.outquint

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

-- tatsuru
local function FixedPow(a, b)
    local res = FU
    for i = 1, b do
        res = FixedMul(res, a)
    end

    return res
end

local convertCharacterSelection = ZE2.convertCharacterSelection
local darkbgheight = 60
local darkbgheight2 = 3
local darkbgtrans = 5
local darkbgcolor = 31
local darkbgshift = (darkbgtrans<<V_ALPHASHIFT)
local skinlist

return "CharacterSelect", function(v, player)
	local game = ZE2.Game
	
	if not multiplayer then
		return end;

	local selection = ZE2.charsel_selection
	local prevselection = ZE2.charsel_prevselection
	local anim = ZE2.charsel_anim
	local setanim = ZE2.charsel_setanim

	if drawScaled == nil then drawScaled = v.drawScaled end
	if drawString == nil then drawString = v.drawString end
	if drawFill == nil then drawFill = v.drawFill end
	if drawLevelTitle == nil then drawLevelTitle = v.drawLevelTitle end
	if getColormap == nil then getColormap = v.getColormap end
	if getSprite2Patch == nil then getSprite2Patch = v.getSprite2Patch end
	if cachePatch == nil then cachePatch = v.cachePatch end

	if not (player.mo and player.mo.valid) then
		return end;

    if not P_IsLocalPlayer(player) then
        return end;

    if not (ZE2.pregame_menu == 1 or ZE2.charsel_exit_anim) then
        return end;

    if (game.active) then
        return end;
		
	local yoffset = 0
		
	if ZE2.charsel_exit_anim then
		local div = FU - FixedDiv(abs(ZE2.charsel_exit_anim), ZE2.charsel_set_exit_anim)
		local ese = ease.outquint(div, 0, -150*FU)
		
		if ZE2.charsel_exit_anim < 0 then
			ese = ease.outquint(div, -150*FU, 0)
		end
		
		yoffset = $ + ese/FU
	end

	drawFill(0, 0 + yoffset, 600, darkbgheight, darkbgcolor+(darkbgshift|V_SNAPTOLEFT|V_SNAPTOTOP))
	for i=1,4 do
		local darkbgtrans2 = ((darkbgtrans+i)<<V_ALPHASHIFT)
		drawFill(0, 60+((i-1)*darkbgheight2)+yoffset, 600, darkbgheight2, (darkbgcolor)+(darkbgtrans2|V_SNAPTOLEFT|V_SNAPTOTOP))
	end

	drawLevelTitle(10, 25+yoffset, "Select A Character", V_SNAPTOTOP)
	local x = 160*FU
	local y = 100*FU + yoffset*FU
	
    if skinlist ~= ZE2.getSkinNums(player) then skinlist = ZE2.getSkinNums(player) end

    if not #skinlist then
        return end;

	for i=(selection-5),(selection+5) do
		local realnum = convertCharacterSelection(i, player)
		local realskindata = skins[skinlist[realnum]]
		local cslot = ZE2.CharacterSlots[realnum]
		local realskin = realskindata.name
		local dist = 80*FU

		if not cslot then
			continue end;

		-- Copy variables.
		local x = x;
		local y = y;

		local index = ((i*FU)-(FU)) - ((selection*FU)-(FU)) -- (i-1)-(selection-1)

		if anim then
			local div = FU - FixedDiv(anim*FU, setanim*FU)
			local ese = select_ease(div, prevselection*FU, selection*FU)
			index = ((i*FU)-(FU)) - (ese-(FU))
		end

		local xc = FixedMul(index, dist)
		local yc = FixedPow(index, 2)*5
		local xxc = x + xc
		local yyc = y + yc

		if not (xxc > -60*FU and xxc < 400*FU) then -- remove offscreen
			continue end;

		local iconpatch = getSprite2Patch(realskin, SPR2_LIFE, false, A)
		local iconscale = FixedMul((FU*6)/4, realskindata.highresscale)
		local translation

		if cslot.count >= cslot.max then
			translation = "Grayscale"
		end

		local colormap = getColormap(realskin, realskindata.prefcolor, translation)
		drawScaled(xxc, yyc, iconscale, iconpatch, V_SNAPTOTOP, colormap)
		drawString(xxc + 6*FU, yyc - 20*FU, cslot.max - cslot.count, V_SNAPTOTOP, "fixed")
	end

	-- Selected character code.
	local CURWEAP = v.cachePatch("CURWEAP")
	local CURWEAP_SCALE = (FU*7)/4
	local CURWEAP_X = x
	local CURWEAP_Y = y

	if anim then
		local div = FU - FixedDiv(anim*FU, setanim*FU)
		CURWEAP_SCALE = select_ease(div, 2*FU, $)
	end

	CURWEAP_X = $ - FixedMul(CURWEAP.width*FU, CURWEAP_SCALE)/2
	CURWEAP_Y = $ - FixedMul(CURWEAP.height*FU, CURWEAP_SCALE)/2

	drawScaled(CURWEAP_X, CURWEAP_Y - 6*FU, CURWEAP_SCALE, CURWEAP, V_SNAPTOTOP)
end, "game"