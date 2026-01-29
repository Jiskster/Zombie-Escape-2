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
    local res = FRACUNIT
    
    for i = 1, b do
        res = FixedMul(res, a)
    end
    
    return res
end

local convertCharacterSelection = ZE2.convertCharacterSelection

return "CharacterSelect", function(v, player)
    local selection = ZE2.charsel_selection
    local prevselection = ZE2.charsel_prevselection
    local anim = ZE2.charsel_anim
    local setanim = ZE2.charsel_setanim

	if not (player.mo and player.mo.valid) then
		return end;
    
    if (consoleplayer and consoleplayer.valid)
    and (player ~= consoleplayer) then
        return end;

    if (ZE2.pregame_menu ~= 1) then
        return end;

    if (ZE2.round_active) then
        return end;
	
	local darkbgheight = 60
	local darkbgtrans = 5
	local darkbgshift = (darkbgtrans<<V_ALPHASHIFT)
	local darkbgcolor = 31

	v.drawFill(0, 0, 600, darkbgheight, darkbgcolor+(darkbgshift|V_SNAPTOLEFT|V_SNAPTOTOP))
	
	for i=1,4 do
		local darkbgheight2 = 3
		local darkbgtrans2 = ((darkbgtrans+i)<<V_ALPHASHIFT)
		v.drawFill(0, 60+((i-1)*darkbgheight2), 600, darkbgheight2, (darkbgcolor)+(darkbgtrans2|V_SNAPTOLEFT|V_SNAPTOTOP))
	end
	
	v.drawLevelTitle(10, 25, "Select A Character", V_SNAPTOTOP)
	
	local x = 160*FU
	local y = 100*FU
	
    local skinlist = ZE2.getSkinNums(player)

    if not #skinlist then
        return end;

	for i=-256,256 do
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
			local ese = ease.outquint(div, prevselection*FU, selection*FU)
			index = ((i*FU)-(FU)) - (ese-(FU))
		end
		
		local xc = FixedMul(index, dist)
		local yc = FixedPow(index, 2)*5
		local xxc = x + xc
		local yyc = y + yc
		local iconpatch = v.getSprite2Patch(realskin, SPR2_LIFE, false, A)
		local iconscale = FixedMul((FU*6)/4, realskindata.highresscale)
		local translation

		if #cslot >= cslot.limit then
			translation = "Grayscale"
		end

		local colormap = v.getColormap(realskin, realskindata.prefcolor, translation)
		
		if xxc > -50*FU and xxc < 400*FU then
			v.drawScaled(xxc, yyc, iconscale, iconpatch, V_SNAPTOTOP, colormap)
			v.drawString(xxc + 6*FU, yyc - 20*FU, cslot.limit - #cslot, V_SNAPTOTOP, "fixed")
		end
	end
	
	-- Selected character code.
	local CURWEAP = v.cachePatch("CURWEAP")
	local CURWEAP_SCALE = (FU*7)/4
	local CURWEAP_X = x
	local CURWEAP_Y = y
	
	if anim then
		local div = FU - FixedDiv(anim*FU, setanim*FU)
		CURWEAP_SCALE = ease.outquint(div, 2*FU, $)
	end
	
	CURWEAP_X = $ - FixedMul(CURWEAP.width*FU, CURWEAP_SCALE)/2
	CURWEAP_Y = $ - FixedMul(CURWEAP.height*FU, CURWEAP_SCALE)/2
	
	v.drawScaled(CURWEAP_X, CURWEAP_Y - 6*FU, CURWEAP_SCALE, CURWEAP, V_SNAPTOTOP)
end, "game", 2