rawset(_G, "ze2_modname", "ze2"); -- For customhud.

local PATH = "game/Core/Player/HUD"
local path = "Drawers"
local namespace = "ZE2:"

customhud.SetupFont("STCFC", -1, 4)
customhud.SetupFont("TNYFC", -1, 4)
customhud.SetupFont("DSTCF", -1, 4)
customhud.SetupFont("DTNYF", -1, 4)

ZE2.HUD = {}

local function SetupHud(filename)
	local funcname, drawfunc, type, hudlayer = dofile(PATH .. "/" .. path .. "/" .. filename)

	drawfunc = $ or function(v, player) end

	-- Make a new function from the current function.
	-- Currently makes it so huds don't draw if it's not Zombie Escape.
	local new_drawfunc = function(v, player)
		if player and player.valid and not player["xSlinger[]"] then
			return
		end

		drawfunc(v, player)
	end

	ZE2.HUD[funcname] = {draw = new_drawfunc, draw_type = type, draw_layer = hudlayer}

	customhud.SetupItem(
		namespace .. string.upper(funcname),
		ze2_modname, ZE2.HUD[funcname].draw,
		ZE2.HUD[funcname].draw_type or "game",
		ZE2.HUD[funcname].draw_layer or 0
	)
end

local function SetupHudNoLoad(filename)
	dofile(PATH .. "/" .. path .. "/" .. filename)
end

SetupHud "HudToggle"

SetupHud "CharacterSelect"

SetupHud "Shop"

SetupHud "DamageText"

SetupHud "PlayerTags"

SetupHud "DamageFade"

SetupHud "Info"
SetupHud "HealthAndStamina"
SetupHud "RespawnTimer"
SetupHud "Intermission"
SetupHud "Tabscores"
SetupHud "Tooltips"
SetupHud "ZE2Tools"

path = "Overrides"

SetupHudNoLoad "Inventory"
