local base_hooks = {
	MapLoad = {
		__args = {
			"map";
		}
	};
	PreThinkFrame = {};
	ThinkFrame = {};
	PlayerSpawn = {
		__args = {
			"player";
		}
	};
	PlayerThink = {
		__args = {
			"player";
		}
	};
	ViewpointSwitch = {
		__args = {
			"player";
			"nextviewedplayer";
			"forced";
		}
	};
	TeamSwitch = {
		__args = {
			"player";
			"team";
			"fromspectators";
			"autobalance";
			"scramble";
		}
	};
	JumpSpecial = {
		__args = {
			"player";
		}
	};
}

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
	JumpSpecial = {"JumpFatigue"};
	ViewpointSwitch = {"Main"};
}

-- Register Hooks.
-- TODO: Merge all functions in one hook each, instead of creating a new hook for each file.
for hookname,hooktable in pairs(hook_names) do
	for i,filename in ipairs(hooktable) do
		local full_path = "hooks/"..hookname.."/"..filename

		local func = loadfile(full_path..".lua")
	
		table.insert(base_hooks[hookname], func)
	
		addHook(hookname, function(...)
			if base_hooks[hookname].__args then
				for argnum,argname in ipairs(base_hooks[hookname].__args) do
					rawset(getfenv(func), argname, select(argnum, ...))
				end
			end
			
			if gametype ~= GT_ZE2 then return end
			
			return func(...)
		end)
	end
end