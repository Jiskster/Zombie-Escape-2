local cmd_prefix = "zd_"

///////// ZE2 Tools by GLide KS /////////

local function AddDebug_CMD(cmdname, func)
    COM_AddCommand(cmd_prefix..cmdname, function(...)
        if not ZE2.cv_debug.value then
            CV_Set(ZE2.cv_debug, 1)
        end
        func(...)
    end, COM_ADMIN)
end

ZE2.tools = { --Default values
    nocd = false,
    checkpoints_show = false
}

function ZE2.debugprint(str)
    if not ZE2.cv_debug.value then
        return
    end

    print(str)
end

addHook("NetVars", function(net)
	ZE2.tools = net($)
end)

--Pregame countdown to zero

local function skip_pregame()
    if gamestate != GS_LEVEL then return end
    local game = ZE2.Game

    if game.state == ZE2.GS_PREGAME then
		game.state_tics = -1
	end
end

AddDebug_CMD("nocd", function(p, arg)
    local yes = (arg == "true" or arg == "yes" or arg == "1" or arg == "on")
    local no = (arg == "false" or arg == "no" or arg == "0" or arg == "off")

	if yes then --if true, always skip the pregame on map load
		ZE2.tools.nocd = true
		skip_pregame()
	elseif no then --if false, doesn't skip the pregame anymore
		ZE2.tools.nocd = false
	else -- If no argument, skips the current pregame countdown
		skip_pregame()
	end
end)

addHook("MapLoad", function() --directly skip pregame countdown on map load if zd_nocd is true
	if ZE2.tools.nocd then skip_pregame() end
end)

addHook("ThinkFrame", function() -- Skip the zombie release time as well if any.
    if not ZE2.tools.nocd then return end
    if gamestate != GS_LEVEL then return end
    local game = ZE2.Game

    if game.zombie_release_time then
        game.zombie_release_time = 0
    end
end)

--Teleport to checkpoint
local function CheckpointTeleport(p, nextprev)
	if not #ZE2.Checkpoints then return end
    if p.mo.debug_checkpoint == nil then p.mo.debug_checkpoint = 0 end

    if (nextprev == 1 and p.mo.debug_checkpoint == #ZE2.Checkpoints)
    or (nextprev == -1 and (not p.mo.debug_checkpoint or p.mo.debug_checkpoint == 1)) then
        p.mo.debug_checkpoint = (nextprev == 1 and 1) or #ZE2.Checkpoints
    else
        p.mo.debug_checkpoint = (nextprev == 1 and $+1) or $-1
    end

	ZE2.CheckPointTeleport(p, p.mo.debug_checkpoint)
    CONS_Printf(p, "\130Teleported to checkpoint number \128"..p.mo.debug_checkpoint)
end

AddDebug_CMD("nextcheckpoint", function(p)
	if (p.mo and p.mo.valid) then CheckpointTeleport(p, 1) end
end)

AddDebug_CMD("prevcheckpoint", function(p)
	if (p.mo and p.mo.valid) then CheckpointTeleport(p, -1) end
end)

--Noclip command
AddDebug_CMD("noclip", function(p)
	if not (p.mo and p.mo.valid) then return end

    if p.mo.noclip then p.mo.noclip = false else p.mo.noclip = true end

    local noclip = p.mo.noclip
    local flags = PF_NOCLIP|PF_GODMODE
    local status_text = (noclip and "enabled") or "disabled"
    local status_color = (noclip and "\131") or "\133"

    p.mo.alpha = (noclip and FU/2) or FU --make the player half visible
    if noclip then p.pflags = $ | flags else p.pflags = $ &~flags end --god mode and noclip
    S_StartSound(p.mo, (noclip and sfx_s3k92) or sfx_s1a2) --play a sound because why not

    CONS_Printf(p, status_color.."Noclip "..status_text)
end)

--Skip map timers
AddDebug_CMD("skiptimers", function()
    if not ZE2.ActiveMapTimers then return end

    for i,timer in ipairs(ZE2.ActiveMapTimers) do if timer.time then timer.time = 0 end end
end)

-- Become a Zombie!
AddDebug_CMD("zombifyme", function(p, zombietype)
    if not (p.mo and p.mo.valid and p.mo.health) then return end
    if not p.mo.team == 2 then return end

    ZE2.ZombifyPlayer(p, zombietype or nil)
end)

-- Become a survivor and switch to a skin!
AddDebug_CMD("skin", function(p, surv_skin)
    if not (p.mo and p.mo.valid and p.mo.health) then return end
    local skin = surv_skin or p.ze2.selected_character or "sonic"

    if not ZE2.SurvivorConfig[skin] then -- Must be a survivor skin defined in ZE2
        CONS_Printf(p, "The given skin is not valid or is not defined as a survivor for Zombie Escape 2.")
        return
    end

    if p.mo.team == 2 then
        ZE2.ResetPlayer(p, 1, true) -- Necessary if the player is a Zombie.
    end

    p.ze2.selected_character = skin
    ZE2.switchCharacter(p, skin)
	ZE2.setConfigInventory(p, skin)
	ZE2.resetPlayerHealth(p, skin)
end)

-- Mind control from Lucario tools - Used for testing with bots
AddDebug_CMD("mindcontrol", function(player, target)
    if (target == nil) or (tonumber(target) == nil) then
        player.controlling = nil
        CONS_Printf(player, "\x83" .. "Controlling off")
        return
    end

    target = max(min(31, target), 0)
    target = players[target]
    if not target or not target.valid then return end

    player.controlling = target
    CONS_Printf(player, "\x83" .. "Controlling player #" .. #target .. " - " .. target.name)
end)

addHook("PreThinkFrame", function()
    if not ZE2.cv_debug.value then return end

    for player in players.iterate do
		if not player.controlling then continue end
		if not player.controlling.valid then
			player.controlling = nil
			continue
		end
		player.powers[pw_nocontrol] = 2

		player.controlling.cmd.forwardmove = player.cmd.forwardmove
		player.controlling.cmd.sidemove = player.cmd.sidemove
		player.controlling.cmd.angleturn = player.cmd.angleturn
		player.controlling.cmd.aiming = player.cmd.aiming
		player.controlling.cmd.buttons = player.cmd.buttons
		player.cmd.buttons = 0

		if (player == consoleplayer) then
			displayplayer = player.controlling
		end
	end
end)