freeslot("MT_ZE2CHECKPOINT")

mobjinfo[MT_ZE2CHECKPOINT] = {
	//$Category Zombie Escape 2
	//$Name ZE2 Checkpoint
	//$Sprite TGFXA0

	//$Arg0 Checkpoint Number
	//$Arg0Default 1

	//$Arg1 Checkpoint Flags
	//$Arg1Type 12
	//$Arg1Enum {1="Survivor"; 2="Zombie";}
	//$Arg1Flags {1="Survivor"; 2="Zombie";}

	//$Arg2 Catchup Delay (Seconds)
	//$Arg2Default 15

	//$Arg3 Extra Flags
	//$Arg3ToolTip Indiscriminate Checkpoints: \nAllow any team to influence other team's catchup teleports.\n\nDisable Catchup: \nDisables the checkpoint catchup routine.\n\nDisable Auto Trigger: \nDisables the function where it auto triggers the checkpoint if you're in the same sector as it
	//$Arg3Type 12
	//$Arg3Enum {1="Indiscriminate Checkpoints"; 2="Disable Catchup"; 4="Disable Auto Trigger";}
	//$Arg3Flags {1="Indiscriminate Checkpoints"; 2="Disable Catchup"; 4="Disable Auto Trigger";}

	//$Arg4 Zombie Catchup Delay (Offset)
	//$Arg4Default 2

	doomednum = 5600,
	spawnhealth = 1000,
	radius = 64*FRACUNIT,
	height = 80*FRACUNIT,
	
	flags = MF_NOBLOCKMAP|MF_NOCLIPTHING,
}

local function ResetCheckpoints()
	ZE2.LatestSurvivorCheckpoint = 0
	ZE2.LatestZombieCheckpoint = 0
	ZE2.Checkpoints = {}
	ZE2.highest_checkpoint = 0
end; ResetCheckpoints()

-- leave this hook up here for readability
addHook("NetVars", function(net)
	ZE2.LatestSurvivorCheckpoint = net($)
	ZE2.LatestZombieCheckpoint = net($)
	ZE2.Checkpoints = net($)
	ZE2.highest_checkpoint = net($)
end)

---@param player player_t
function ZE2.GetLatestCheckpoint(player)
	if not (player.mo and player.mo.valid) then
		return end;

	if player.mo.team == 1 then
		return ZE2.LatestSurvivorCheckpoint
	else 
		return ZE2.LatestZombieCheckpoint
	end
end

---@param player player_t
---@param setcheckpoint boolean
function ZE2.LatestCheckpointTeleport(player)
	local game = ZE2.Game
	
	if not (game.active) then
		return end;
	
	if not (player.mo and player.mo.valid) then
		return end;
	
	if not (leveltime) then
		return end;

	local check = ZE2.GetLatestCheckpoint(player)
	
	if not (check and ZE2.Checkpoints[check]) then
		return end;

	local info = ZE2.Checkpoints[check]

	P_SetOrigin(player.mo, info.x*FU, info.y*FU, info.z*FU)
	P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_ZE2_TELEGFX)
	player.mo.angle = FixedAngle(info.angle*FRACUNIT)
	player.ze2.checkpoint_number = check
	player.mo.momx = $/3
	player.mo.momy = $/3
end

---@param mobj mobj_t Player Object
---@param checkpoint table Checkpoint Table
---@param cmobj mobj_t Checkpoint Object
local function ActivateCheckpoint(mobj, checkpoint, cmobj)
	local isvalid = mobj.player and mobj.player.valid
					and cmobj and cmobj.valid

	local player = mobj.player
	
	if not (isvalid) then
		return
	end

	local indiscriminate = checkpoint.indiscriminate
	local checkpoint_num = checkpoint.number
	local disable_catchup = checkpoint.disable_catchup
	local catchup_timer = checkpoint.catchup_delay
	local zombie_catchup_offset = checkpoint.zombie_catchup_offset
	local isTeam = (mobj.team == 1 and checkpoint.survivor_checkpoint)
				or (mobj.team == 2 and checkpoint.zombie_checkpoint)

	if not (indiscriminate or isTeam) then
		return
	end

	if (player.ze2.checkpoint_number >= checkpoint_num) then
		return
	end

	-- starpost animation/sound
	S_StartSound(cmobj, sfx_strpst)
	cmobj.state = S_STARPOST_STARTSPIN

	-- set player checkpoint
	player.ze2.checkpoint_number = checkpoint_num

	local isCaughtUp = (mobj.team == 1 and checkpoint_num >= ZE2.LatestSurvivorCheckpoint)
					or (mobj.team == 2 and checkpoint_num >= ZE2.LatestZombieCheckpoint)
	if isCaughtUp then
		ZE2.debugprint(player.name .. " caught up to checkpoint num " .. checkpoint_num)
		player.ze2.checkpoint_timer = 0
	end

	-- set global checkpoints
	if (checkpoint.survivor_checkpoint) and (indiscriminate or mobj.team == 1) then
		if ZE2.LatestSurvivorCheckpoint < checkpoint_num then
			ZE2.LatestSurvivorCheckpoint = checkpoint_num
			ZE2.debugprint("new survivor checkpoint: "..checkpoint_num)
		end
	end
	
	if (checkpoint.zombie_checkpoint) and (indiscriminate or mobj.team == 2) then
		if ZE2.LatestZombieCheckpoint < checkpoint_num then
			ZE2.LatestZombieCheckpoint = checkpoint_num
			ZE2.debugprint("new zombie checkpoint: "..checkpoint_num)
		end
	end

	if (disable_catchup) or (not catchup_timer) then
		return
	end
	
	local catchup_offset = 0

	-- set catchup timers for other players
	for ctp in players.iterate do
		if (ctp.spectator) then
			ctp.ze2.checkpoint_timer = 0
			continue
		end

		if (ctp == player) then continue end

		local ctpmo = ctp.mo

		if not (ctpmo and ctpmo.valid and ctpmo.health) then continue end

		local isCatchupTeam = (ctpmo.team == 1 and checkpoint.survivor_checkpoint) 
							or (ctpmo.team == 2 and checkpoint.zombie_checkpoint)

		if isCatchupTeam and ctp.ze2.checkpoint_number < checkpoint_num then
			local newtime = catchup_timer + catchup_offset
			if ctpmo.team == 2 then
				newtime = $ + zombie_catchup_offset
			end

			ctp.ze2.checkpoint_timer = newtime
			catchup_offset = $ + 3
		end
	end
end

---@param mobj mobj_t
---@param sector sector_t
local function getMobjZSectorRange(mobj, sector)
	local output = {
		ceiling = sector.ceilingheight,
		floor = sector.floorheight,
	}

	for fof in sector.ffloors() do
		if mobj.z + mobj.height < fof.bottomheight then -- if below fof
			output.ceiling = min($, fof.bottomheight) -- cap it
		end

		if mobj.z > fof.topheight then -- if above fof
			output.floor = max($, fof.topheight) -- cap it
		end
	end

	return output
end

---@param mobj mobj_t the mobj of the player
local function checkpointCheck(mobj)
	local checkpoints = ZE2.Checkpoints

	for checkpoint_num=1, ZE2.highest_checkpoint do
		local checkpoint = checkpoints[checkpoint_num]
		
		if not checkpoints[checkpoint_num] then
			continue
		end
		
		if checkpoint.mobj and checkpoint.mobj.valid then -- is checkpoint valid
			if mobj.subsector.sector == checkpoint.subsector.sector -- if checkpoint sector is player sector
			and not checkpoint.disable_autotrigger then
				local sector = checkpoint.subsector.sector
				local cmo = checkpoint.mobj

				local zrange = getMobjZSectorRange(cmo, sector)

				-- use our floor and height caps
				if mobj.z < zrange.ceiling and mobj.z + mobj.height > zrange.floor then
					ActivateCheckpoint(mobj, checkpoint, checkpoint.mobj)
				end
			end

			if checkpoint.tag then
				for sector in sectors.tagged(checkpoint.tag) do
					if mobj.subsector.sector == sector then
						local zrange = getMobjZSectorRange(mobj, sector)

						if mobj.z < zrange.ceiling and mobj.z + mobj.height > zrange.floor then
							ActivateCheckpoint(mobj, checkpoint, checkpoint.mobj)
						end
					end
				end
			end
		end
	end
end

---@param mobj mobj_t the mobj of the checkpoint
local function aboutToTeleportVFX(mobj, color)
	local wind = P_SpawnMobj(mobj.x, mobj.y, mobj.z + (mobj.height*3)/2, MT_BOXSPARKLE)
	wind.frame = wind.frame | FF_FULLBRIGHT
	wind.renderflags = wind.renderflags | RF_FULLBRIGHT
	
	-- color
	wind.color = color or SKINCOLOR_WHITE
	wind.colorized = true
	
	-- trans people
	wind.alpha = FU/4 + P_RandomRange(1, FU/2)
	
	-- momentum
	wind.momx = P_RandomRange(-6,6)*FU
	wind.momy = P_RandomRange(-6,6)*FU
	P_SetObjectMomZ(wind, P_RandomRange(-3, 3) * FU)
end

addHook("MapThingSpawn", function(mobj, thing)
	local checkpoint_number = thing.args[0] -- number
	local checkpoint_flags = thing.args[1] -- flags
	local checkpoint_catchup_delay = thing.args[2] --number
	local checkpoint_extra_flags = thing.args[3] -- flags
	local checkpoint_zombie_catchup_offset = thing.args[4] -- number

	-- Flags [Args 1]

	local SURVIVORFLAG, ZOMBIEFLAG = 1<<0, 1<<1 -- flags

	-- Extra Flags [Args 3]

	-- Indiscriminate Checkpoints (Triggering causes all teams to start the catch up routine)
	local INDISCRIMINATE_FLAG = 1<<0
	-- Disable catchup (Makes it so others dont have to catch up to you)
	local DISABLECATCHUP_FLAG = 1<<1
	-- Disable Auto Trigger (Disables the function where it auto triggers the checkpoint if you're in the same sector as it)
	local DISABLEAUTOTRIGGER_FLAG = 1<<2

	if not (checkpoint_number) then
		print("\x85".."ERROR: ".."\x80".."Invalid Checkpoint At "..thing.x.." "..thing.y.." "..thing.z.. " [mapthing number: "..#thing.."]")
		return true 
	end

	ZE2.debugprint("\x83".."NOTICE: ".."\x80".."New checkpoint ["..checkpoint_number.."]")

	ZE2.Checkpoints[checkpoint_number] = {
		x = thing.x,
		y = thing.y,
		z = P_FloorzAtPos(thing.x*FU, thing.y*FU, thing.z*FU, mobjinfo[MT_ZE2CHECKPOINT].height)/FU,
		angle = thing.angle,
		subsector = R_PointInSubsectorOrNil(thing.x*FU, thing.y*FU),
		mobj = mobj,
		thing = thing,
		tag = thing.tag,

		-- Args 0 [Checkpoint Number]

		number = checkpoint_number, -- int

		-- Args 1 [Team Flags]

		zombie_checkpoint = (checkpoint_flags & ZOMBIEFLAG) > 0, -- flag 0
		survivor_checkpoint = (checkpoint_flags & SURVIVORFLAG) > 0, -- flag 1

		-- Args 2 [Catch Up Delay]

		catchup_delay = checkpoint_catchup_delay*TICRATE, -- int [tics*TICRATE]

		-- Args 3 [Extra Flags]

		indiscriminate = (checkpoint_extra_flags & INDISCRIMINATE_FLAG) > 0, -- flag 0
		disable_catchup = (checkpoint_extra_flags & DISABLECATCHUP_FLAG) > 0, -- flag 1
		disable_autotrigger = (checkpoint_extra_flags & DISABLEAUTOTRIGGER_FLAG) > 0, -- flag 2

		-- Args 4 [Zombie Catchup Offset]

		zombie_catchup_offset = (checkpoint_zombie_catchup_offset or 0)*TICRATE, -- int [tics*TICRATE]
	}

	mobj.state = S_STARPOST_IDLE -- i have no clue why spawnstate for this state isnt working, so here.
	P_SetScale(mobj, FRACUNIT, true)
end, MT_ZE2CHECKPOINT)

addHook("MapChange", function()
	ResetCheckpoints()
end)

-- on mapload: reset variables, and calculate highest checkpoint number
addHook("MapLoad", function()
	-- set highest checkpoint number so ZE2.Checkpoints can be iterated from 1 to ZE2.highest_checkpoint
	-- this is to keep logic deterministic i hope
	for checkpoint_num, checkpoint in pairs(ZE2.Checkpoints) do
		if checkpoint_num > ZE2.highest_checkpoint then
			ZE2.highest_checkpoint = checkpoint_num
		end
	end
end)

-- Main checkpoint thinker.
addHook("PlayerThink", function(player)	
	if not #ZE2.Checkpoints then 
		return end;

	local mobj = player.mo

	if not (mobj and mobj.valid) then
		return end;

	if player.ze2.checkpoint_timer then
		player.ze2.checkpoint_timer = $ - 1
		
		if not (player.ze2.checkpoint_timer % 15) then
			local latest_checkpoint_number = 0
			local color = mobj.team == 1 and SKINCOLOR_BLUE or SKINCOLOR_RED
			
			if (mobj.team == 1) then
				latest_checkpoint_number = ZE2.LatestSurvivorCheckpoint
			else
				latest_checkpoint_number = ZE2.LatestZombieCheckpoint
			end
			
			local checkpoint = ZE2.Checkpoints[latest_checkpoint_number]
			local cmobj = checkpoint.mobj
			
			if checkpoint and cmobj and cmobj.valid then
				aboutToTeleportVFX(cmobj, color)
			end
		end

		if not player.ze2.checkpoint_timer then
			ZE2.LatestCheckpointTeleport(player)
			ZE2.debugprint(player.name .. " initiated catch up.")
		end
	end

	checkpointCheck(mobj)
end)

-- name one person that uses this... this is barely even tested...
addHook("LinedefExecute", function(line, mobj, sector)
	local checkpoint_doomednum = mobjinfo[MT_ZE2CHECKPOINT].doomednum

	if mobj and mobj.valid and mobj.player and mobj.player.valid then
		if line.tag then
			local foundcheckpoint

			for mapthing in mapthings.tagged(line.tag) do
				if mapthing.type ~= checkpoint_doomednum then continue end

				foundcheckpoint = mapthing
				break;
			end

			if foundcheckpoint and foundcheckpoint.mobj and foundcheckpoint.mobj.valid then
				ActivateCheckpoint(mobj, foundcheckpoint.mobj)
			end
		end
	end
end, "ZE2CHECKPOINT")

-- teleport to latest checkpoint on spawn
addHook("PlayerSpawn", function(player)
	if not ZE2.isGametype() then return end

	ZE2.LatestCheckpointTeleport(player)
end, MT_PLAYER)