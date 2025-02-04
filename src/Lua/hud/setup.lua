local path = "hud/drawers"

customhud.SetupFont("STCFC", -1, 4);
customhud.SetupFont("TNYFC", -1, 4);
customhud.SetupFont("DSTCF", -1, 4);
customhud.SetupFont("DTNYF", -1, 4);

local function SetupHud(filename)
	local funcname, drawfunc, type, hudlayer = dofile(path.."/"..filename)
	
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

--gametype ~= GT_ZE2

/*
customhud.SetupItem("ze2_pregame", ze2_modname, ZE2.pregamehud, "game", 0)
customhud.SetupItem("ze2_characterselect", ze2_modname, ZE2.characterselecthud, "game", 0)

customhud.SetupItem("ze2_mapinfo", ze2_modname, ZE2.mapinfohud, "game", 0)

customhud.SetupItem("ze2_nametags", ze2_modname, ZE2.nametagshud, "game", 0)

customhud.SetupItem("ze2_damageindicator", ze2_modname, ZE2.damageindicatorhud, "game", 4)

customhud.SetupItem("ze2_damagefade", ze2_modname, ZE2.damagefadehud, "game", 0)

customhud.SetupItem("ze2_info", ze2_modname, ZE2.infohud, "game", 0)

customhud.SetupItem("ze2_toggle", ze2_modname, ZE2.togglehud, "game", 0)
customhud.SetupItem("ze2_intermissionhud", ze2_modname, ZE2.intermissionhud, "game", 0)
customhud.SetupItem("ze2_shop", ze2_modname, ZE2.shophud, "game", 0)
customhud.SetupItem("ze2_zombieshop", ze2_modname, ZE2.zombie_shophud, "game", 0)
customhud.SetupItem("ze2_inventory", ze2_modname, ZE2.inventoryhud, "game", 0)
customhud.SetupItem("ze2_scores", ze2_modname, ZE2.tabscores, "scores", 0)

customhud.SetupItem("ze2_debug", ze2_modname, ZE2.debughud, "game", 1)
*/

SetupHud "HudToggle"

SetupHud "PreGame"
SetupHud "CharacterSelect"
SetupHud "MapInfoAnimation"
SetupHud "NameTags"
SetupHud "DamageIndicator"
SetupHud "DamageFade"
SetupHud "Info"
SetupHud "Intermission"
SetupHud "Shop"
SetupHud "ZombieShop"
SetupHud "Inventory"
SetupHud "Tabscores"
--SetupHud "Debug"
