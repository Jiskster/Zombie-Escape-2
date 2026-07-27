local cmd_prefix = "zd_"

COM_AddCommand(cmd_prefix.."refreshitems", function ()
    for p in players.iterate do
        if not p.ze2 then continue end
        local inventory = p.ze2.survivor_inventory
        if inventory then
            for i=1,#inventory do
                if inventory[i] then
                    inventory[i] = ZE2:CopyItemFromID(inventory[i].item_id)
                end
            end
        end
    end
end, 1)

///////// ZE2 Tools by GLide KS /////////

ZE2.tools = { --Default values
    nocd = false,
    checkpoints_show = false
}

addHook("NetVars", function(net)
	ZE2.tools = net($)
end)

--Pregame countdown to zero
COM_AddCommand(cmd_prefix.."nocd", function(p, arg)
    if not ZE2.cv_debug.value then return end

    local yes = (arg == "true" or arg == "yes" or arg == "1" or arg == "on")
    local no = (arg == "false" or arg == "no" or arg == "0" or arg == "off")

	if yes then --if true, always skip the pregame on map load
		ZE2.tools.nocd = true
		if ZE2.pregame_timeleft then
			ZE2.pregame_timeleft = 0
		end
	elseif no then --if false, doesn't skip the pregame anymore
		ZE2.tools.nocd = false
	elseif ZE2.pregame_timeleft then --if no argument, skips the current pregame countdown
		ZE2.pregame_timeleft = 0
	end
end, COM_ADMIN)

addHook("MapLoad", function() --directly skip pregame countdown on map load if zd_nocd is true
	if not ZE2.cv_debug.value then return end
	if ZE2.tools.nocd and ZE2.pregame_timeleft then ZE2.pregame_timeleft = 0 end
end)

--Teleport to checkpoint
local function CheckpointTeleport(p, nextprev)
	if not #ZE2.Checkpoints then return end
    if p.mo.checkpoint_number == nil then p.mo.checkpoint_number = 0 end

    if (nextprev == 1 and p.mo.checkpoint_number == #ZE2.Checkpoints)
    or (nextprev == -1 and (not p.mo.checkpoint_number or p.mo.checkpoint_number == 1)) then
        p.mo.checkpoint_number = (nextprev == 1 and 1) or #ZE2.Checkpoints
    else
        p.mo.checkpoint_number = (nextprev == 1 and $+1) or $-1
    end

    --Copied from catchup teleport
    local info = ZE2.Checkpoints[p.mo.checkpoint_number]
    P_SetOrigin(p.mo, info.x*FU, info.y*FU, info.z*FU)
    P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_ZE2_TELEGFX)
    S_StartSound(p.mo, sfx_telepo) -- make sure it plays the sound
    p.mo.angle = FixedAngle(info.angle*FRACUNIT)
    p.mo.flags2 = $ & ~MF2_TWOD -- get out

    CONS_Printf(p, "\130Teleported to checkpoint number \128"..p.mo.checkpoint_number)
end

COM_AddCommand(cmd_prefix.."nextcheckpoint", function(p)
	if (ZE2.cv_debug.value and p.mo) then CheckpointTeleport(p, 1) end
end, COM_ADMIN)

COM_AddCommand(cmd_prefix.."prevcheckpoint", function(p)
	if (ZE2.cv_debug.value and p.mo) then CheckpointTeleport(p, -1) end
end, COM_ADMIN)

--Show/Hide Checkpoints
addHook("MobjSpawn", function(mo)
    local show = (ZE2.tools.checkpoints_show and SPR_TGFX) or SPR_NULL
	if mo.sprite ~= show then mo.sprite = show end
end, MT_ZE2CHECKPOINT)

COM_AddCommand(cmd_prefix.."showcheckpoints", function(p)
	if not (ZE2.cv_debug.value) then return end

    if ZE2.tools.checkpoints_show then ZE2.tools.checkpoints_show = false
    else ZE2.tools.checkpoints_show = true end

    local show = (ZE2.tools.checkpoints_show and SPR_TGFX) or SPR_NULL
    local status_text = (ZE2.tools.checkpoints_show and "enabled") or "disabled"
    local status_color = (ZE2.tools.checkpoints_show and "\131") or "\133"

	for mo in mobjs.iterate() do
        if mo.type == MT_ZE2CHECKPOINT and mo.sprite ~= show then mo.sprite = show end
    end

	print(status_color.."Checkpoints visibility has been "..status_text)
end, COM_ADMIN)

--Noclip command
COM_AddCommand(cmd_prefix.."noclip", function(p)
	if not (ZE2.cv_debug.value and p.mo) then return end

    if p.mo.noclip then p.mo.noclip = false else p.mo.noclip = true end

    local noclip = p.mo.noclip
    local flags = PF_NOCLIP|PF_GODMODE
    local status_text = (noclip and "enabled") or "disabled"
    local status_color = (noclip and "\131") or "\133"

    p.mo.alpha = (noclip and FU/2) or FU --make the player half visible
    if noclip then p.pflags = $ | flags else p.pflags = $ &~flags end --god mode and noclip
    S_StartSound(p.mo, (noclip and sfx_s3k92) or sfx_s1a2) --play a sound because why not

    CONS_Printf(p, status_color.."Noclip "..status_text)
end, COM_ADMIN)

--Skip map timers
COM_AddCommand(cmd_prefix.."skiptimers", function()
    if not ZE2.cv_debug.value then return end
    if not ZE2.ActiveMapTimers then return end

    for i,timer in pairs(ZE2.ActiveMapTimers) do if timer.time then timer.time = 0 end end
end, COM_ADMIN)