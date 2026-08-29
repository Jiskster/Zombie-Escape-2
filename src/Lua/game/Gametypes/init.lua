local PATH = "game/Gametypes"

local DEFAULT_RULES = (GTR_TIMELIMIT|GTR_ALLOWEXIT|GTR_SPAWNENEMIES|GTR_CUTSCENES|GTR_SPECTATORS|GTR_DEATHMATCHSTARTS|GTR_RINGSLINGER)

local GTS = {}

function ZE2.AddGametype(name, description, rules)
	local newTOL_str = ("TOL_"..name:upper())
	local newTOL = freeslot(newTOL_str)
	G_AddGametype({
		name = name.." (ZE2)",
		identifier = name:lower(),
		typeoflevel = newTOL,
		rules = rules or DEFAULT_RULES,
		intermissiontype = int_none, -- We have ingame intermission, so we dont need an intermission type
		headerleftcolor = 152,
		headerrightcolor = 40,
		description = description,
	})

	local gt = constants["GT_"..name:upper()]
	GTS[gt] = true
	xSlinger.registerGametype(gt, {
		teams = {
			{
				name = "Survivors";
			},
			{
				name = "Zombies";
				iframes = 0;
			}
		}
	})
end

function ZE2.isGametype()
	return GTS[gametype]
end

local function LoadGametype(name)
	dofile(PATH .. "/" ..name .. "/gametype.lua")
end

LoadGametype "Escape"
LoadGametype "Plague"
LoadGametype "Swarm"

-- Stuff to happen in all ZE2 gametypes...

addHook("ViewpointSwitch", function(player, nextplayer, forced)
	if not ZE2.isGametype() then
		return
	end

	if player.spectator then
		return
	end

	if nextplayer.mo and nextplayer.mo.valid and player.mo and player.mo.valid then
		if nextplayer.mo.team ~= player.mo.team then
			return false
		end
	end
end)

addHook("SeenPlayer", function()
	if (ZE2.isGametype()) then
		return false
	end
end)

xSlinger.skin_properties["zsonic"] = {
	hurtsound = {sfx_zpa1, sfx_zpa2};
}