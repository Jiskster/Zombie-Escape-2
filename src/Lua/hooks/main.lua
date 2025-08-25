local base_hooks = {}

local hook_names = {
	MapLoad = {"InitRound"};
	PlayerSpawn = {
		"InitPlayer";
		"ZombieSpawn"; 
		"ResetVars";
		"LatestCheckpoint";
	};
	TeamSwitch = {"Main"};
	PreThinkFrame = {"Sprint"};
	ThinkFrame = {"WinHandler", "Intermission", "Knockback"};
	PlayerThink = {
		"Main";
		"ReplaceJumpSound";
		"Countdowns";
		"ItemSystem";
		"DamageIndicator";
		"EffectHandler";
		"DamageFade";
		"SourceMovement";
		"Skin&ColorLock";
		"AlphaZombie";
	};
	ShouldDamage = {"DamageSystem"};
	JumpSpecial = {"JumpFatigue"};
	ViewpointSwitch = {"Main"};
}

-- Register Hooks.
-- TODO: Merge all functions in one hook each, instead of creating a new hook for each file.
for hookname,hooktable in pairs(hook_names) do
	for i,filename in ipairs(hooktable) do
		local full_path = "hooks/"..hookname.."/"..filename

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