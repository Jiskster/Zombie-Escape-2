local base_hooks = {}

local hook_order = {
	"MapLoad",
	"PlayerSpawn",
	"TeamSwitch",
	"PreThinkFrame",
	"ThinkFrame",
	"PlayerThink",
	"JumpSpecial",
	"ViewpointSwitch",
	"PlayerCmd",
	"NetVars",
}

local hook_names = {
	MapLoad = {"InitRound"};
	PlayerSpawn = {
		"InitPlayer";
		"ZombieSpawn";
		"LatestCheckpoint";
	};
	TeamSwitch = {"MidgameJoin"};
	PreThinkFrame = {"Movement"};
	ThinkFrame = {"WinHandler", "Intermission"};
	PlayerThink = {
		"Main";
		"ReplaceJumpSound";
		"Countdowns";
		"DamageIndicator";
		"DamageFade";
		"SourceMovement";
		"Skin&ColorLock";
		"AlphaZombie";
		"NoclipSpectators";
	};
	JumpSpecial = {"JumpFatigue"};
	ViewpointSwitch = {"Main"};
	PlayerCmd = {"MidgameJoin"};
	NetVars = {"Main"};
}

-- Register Hooks.
for i=1,#hook_order do
	local hookname = hook_order[i]
	local hook_table = hook_names[hookname]
	for ii=1, #hook_table do
		local filename = hook_table[ii]
		local full_path = "ZE2/hooks/"..hookname.."/"..filename

		local func = dofile(full_path..".lua")

		if hookname and not base_hooks[hookname] then
			base_hooks[hookname] = {}
		end

		table.insert(base_hooks[hookname], func)

		addHook(hookname, function(...)
			if gametype ~= GT_ZE2 then return end

			return func(...)
		end)
	end
end