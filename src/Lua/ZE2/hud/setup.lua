local path = "hud/drawers"

customhud.SetupFont("STCFC", -1, 4);
customhud.SetupFont("TNYFC", -1, 4);
customhud.SetupFont("DSTCF", -1, 4);
customhud.SetupFont("DTNYF", -1, 4);

local function SetupHud(filename)
	local funcname, drawfunc, type, hudlayer = dofile("ZE2/"..path.."/"..filename)

	-- Make a new function from the current function.
	-- Currently makes it so huds don't draw if it's not Zombie Escape.
	local new_drawfunc = function(v, player)
		if gametype ~= GT_ZE2 then return end

		drawfunc(v, player)
	end

	ZE2.HUD[funcname] = {draw = new_drawfunc, draw_type = type, draw_layer = hudlayer}

	customhud.SetupItem(
		"ZE2:"..string.upper(funcname),
		ze2_modname, ZE2.HUD[funcname].draw,
		ZE2.HUD[funcname].draw_type or "game",
		ZE2.HUD[funcname].draw_layer or 0
	)
end

SetupHud "HudToggle"

SetupHud "CharacterSelect"

SetupHud "PlayerTags"

SetupHud "DamageFade"

SetupHud "PreGame"
SetupHud "Info"
SetupHud "RespawnTimer"
SetupHud "Intermission"
SetupHud "Tabscores"
SetupHud "Tooltips"
SetupHud "ZE2Tools"
