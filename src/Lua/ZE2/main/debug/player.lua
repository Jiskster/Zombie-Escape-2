addHook("MapLoad", function()
	for p in players.iterate do
		p.checkpointfound = 0
		p.checkpoint_number = 0
		p.noclip = false
		p.newspeed = nil
		p.ze2skinname = nil
	end
end)

local function CheckpointTeleport(p, nextprev)
	if #ZE2.Checkpoints then

		if nextprev == 1 then
			if p.checkpoint_number == #ZE2.Checkpoints then p.checkpoint_number = 1
			else p.checkpoint_number = $+1
			end
		elseif nextprev == -1 then
			if not p.checkpoint_number or p.checkpoint_number == 1 then p.checkpoint_number = #ZE2.Checkpoints
			else p.checkpoint_number = $-1
			end
		end

		local info = ZE2.Checkpoints[p.checkpoint_number]
		P_SetOrigin(p.mo, info.x*FU, info.y*FU, info.z*FU)
		P_SpawnMobj(p.mo.x, p.mo.y, p.mo.z, MT_ZE2_TELEGFX)
		S_StartSound(p.mo, sfx_telepo) -- make sure it plays the sound
		p.mo.angle = FixedAngle(info.angle*FRACUNIT)

		p.mo.flags2 = $ & ~MF2_TWOD -- get out
		CONS_Printf(p, "\130Teleported to checkpoint number \128"..p.checkpoint_number)
	end
end

local tp_checkpoint = function(p)
	if not ZE2 then return end
	if not ZE2.cv_debug.value then return end
	if not (p and p.mo) then return end
	if p.checkpoint_number == nil then p.checkpoint_number = 0 end
	if not (IsPlayerAdmin(p) or p == server) then return end
	local cmd = p.cmd
	if (cmd.buttons & BT_CUSTOM2) and not (p.lastbuttons & BT_CUSTOM2) then
		--go to previous checkpoint
		CheckpointTeleport(p, -1)
	elseif (cmd.buttons & BT_CUSTOM3) and not (p.lastbuttons & BT_CUSTOM3) then
		--go to next checkpoint
		CheckpointTeleport(p, 1)
	end
end
addHook("PlayerThink", tp_checkpoint)

--Get the checkpoint the player is touching with searchblockmap
--This only works if the checkpoint doesn't have the noblockmap flag
--Is there a better way to do this?
local function GetCheckpoint(p, range)
	local me = p.mo
	if not (me and me.valid) then return end

	local fakerange = (range > 126*FU) and 256*FU or 126*FU
	searchBlockmap("objects", function(ref, found)
		if found == me then return end
		if not (found and found.valid) then return end
		if not (found.info.doomednum == 5600 or found.type == MT_ZE2CHECKPOINT) then return end
		if not L_ZCollide(me,found) then return end

		me.player.checkpointfound = found.spawnpoint.args[0]
	end,
	me,
	me.x-fakerange, me.x+fakerange,
	me.y-fakerange, me.y+fakerange)
end

--Start searching for checkpoints every tic only if the show checkpoints option is enabled
addHook("PlayerThink", function(p)
	if not (ZE2.cv_debug.value and ZE2.debug.checkpoints_show) then return end
	if not (p.mo and p.mo.valid) then return end
	GetCheckpoint(p, 200*FU)
end)