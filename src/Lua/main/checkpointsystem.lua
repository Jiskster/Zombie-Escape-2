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
	//$Arg2Default 25

	//$Arg3 Extra Flags
	//$Arg3ToolTip Indiscriminate Checkpoints: \nAllow any team to influence other team's catchup teleports.\n\nDisable Catchup: \nDisables the checkpoint catchup routine.\n\nDisable Auto Trigger: \nDisables the function where it auto triggers the checkpoint if you're in the same sector as it
	//$Arg3Type 12
	//$Arg3Enum {1="Indiscriminate Checkpoints"; 2="Disable Catchup"; 4="Disable Auto Trigger";}
	//$Arg3Flags {1="Indiscriminate Checkpoints"; 2="Disable Catchup"; 4="Disable Auto Trigger";}
	
	doomednum = 5600,
	spawnstate = S_INVISIBLE,
	seestate = S_INVISIBLE,
	painstate = S_INVISIBLE,
	painsound = sfx_strpst,
	spawnhealth = 1,
	reactiontime = 8,
	speed = 8,
	radius = 64*FRACUNIT,
	height = 80*FRACUNIT,
	mass = 4,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT,
}

ZE2.LatestSurvivorCheckpoint = 0
ZE2.LatestZombieCheckpoint = 0
ZE2.Checkpoints = {}

function ZE2.GetLatestCheckpoint(player)
	if player.ze2.team == 1 then
		return ZE2.LatestSurvivorCheckpoint
	elseif player.ze2.team == 2 then
		return ZE2.LatestZombieCheckpoint
	end
end

function ZE2.LatestCheckpointTeleport(player, setcheckpoint)
	if ZE2.GetLatestCheckpoint(player) and ZE2.Checkpoints[ZE2.GetLatestCheckpoint(player)] then
		local latest_checkpoint = ZE2.GetLatestCheckpoint(player)
		local info = ZE2.Checkpoints[latest_checkpoint]
		
		P_SetOrigin(player.mo, info.x*FU, info.y*FU, info.z*FU)
		P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_ZE2_TELEGFX)
		S_StartSound(player.mo, sfx_telepo) -- make sure it plays the sound
		player.mo.angle = FixedAngle(info.angle*FRACUNIT)
		
		player.mo.flags2 = $ & ~MF2_TWOD -- get out
		
		if setcheckpoint then
			player.ze2.checkpoint_number = latest_checkpoint
		end
	end
end

function ZE2.DeductCatchupTics(player, tics)
	if player.ze2.checkpoint_catchuptics <= 0 then return end
	
	if player.ze2.checkpoint_catchuptics - tics <= 0 then
		player.ze2.checkpoint_catchuptics = 0
		ZE2.LatestCheckpointTeleport(player)
	else
		player.ze2.checkpoint_catchuptics = $ - tics
	end
end

local function ActivateCheckpoint(mobj, checkpoint)
	local isvalid = mobj.player and mobj.player.valid 
					and checkpoint and checkpoint.valid
					and checkpoint.spawnpoint
	local player = mobj.player
					
	if isvalid then
		local checkpoint_number = checkpoint.spawnpoint.args[0]
		local checkpoint_flags = checkpoint.spawnpoint.args[1]
		local checkpoint_catchup_delay = checkpoint.spawnpoint.args[2]
		local checkpoint_extra_flags = checkpoint.spawnpoint.args[3]
		local SURVIVORFLAG, ZOMBIEFLAG = 1<<0, 1<<1
		
		-- Indiscriminate Checkpoints (Triggering causes all teams to start the catch up routine)
		local INDISCRIMINATE_FLAG = 1<<0 
		-- Disable catchup (Makes it so others dont have to catch up to you)
		local DISABLECATCHUP_FLAG = 1<<1
		
		if checkpoint_number then
			if (checkpoint_flags & SURVIVORFLAG) and (player.ze2.team == 1 or (checkpoint_extra_flags & INDISCRIMINATE_FLAG)) then
				if ZE2.LatestSurvivorCheckpoint < checkpoint_number then -- Is activating a newer checkpoint
					ZE2.LatestSurvivorCheckpoint = checkpoint_number
					player.ze2.checkpoint_number = ZE2.LatestSurvivorCheckpoint
					
					--checkpoint.state = checkpoint.info.painstate
					--S_StartSound(mobj, checkpoint.info.painsound)
					--print("Checkpoint Activated: "..checkpoint_number)
					
					if not (checkpoint_extra_flags & DISABLECATCHUP_FLAG) then
						for tplayer in players.iterate do 
							if tplayer.spectator then continue end
							if player == tplayer then continue end 
							
							
							if tplayer.ze2 and tplayer.ze2.team == 1 and tplayer.ze2.checkpoint_number < checkpoint_number then
								if tplayer.ze2.checkpoint_catchuptics then
									ZE2.DeductCatchupTics(player, 5*TICRATE)
									continue
								end
							
								tplayer.ze2.checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
							end
						end
					end
				elseif player.ze2.team == 1 then
					if player.ze2.checkpoint_number < checkpoint_number and checkpoint_number ~= ZE2.GetLatestCheckpoint(player) then
						ZE2.DeductCatchupTics(player, 5*TICRATE)
						--print("Not same checkpoint number, deducting tics")
					elseif checkpoint_number == ZE2.GetLatestCheckpoint(player) then
						player.ze2.checkpoint_catchuptics = 0
						player.ze2.checkpoint_number = ZE2.GetLatestCheckpoint(player)
						--print("Equal checkpoints")
					end
				end
			end
			
			if (checkpoint_flags & ZOMBIEFLAG) and (player.ze2.team == 2 or (checkpoint_extra_flags & INDISCRIMINATE_FLAG)) then
				if ZE2.LatestZombieCheckpoint < checkpoint_number then
					ZE2.LatestZombieCheckpoint = checkpoint_number
					player.ze2.checkpoint_number = ZE2.LatestZombieCheckpoint
					
					--checkpoint.state = checkpoint.info.painstate
					--S_StartSound(mobj, checkpoint.info.painsound)
					--print("Checkpoint Activated: "..checkpoint_number)
					
					if not (checkpoint_extra_flags & DISABLECATCHUP_FLAG) then
						for tplayer in players.iterate do 
							if tplayer.spectator then continue end
							if player == tplayer then continue end 
							
							if tplayer.ze2 and tplayer.ze2.team == 2 and tplayer.ze2.checkpoint_number < checkpoint_number then
								if tplayer.ze2.checkpoint_catchuptics then
									ZE2.DeductCatchupTics(player, 5*TICRATE)
									continue
								end
								
								tplayer.ze2.checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
							end
						end
					end
				elseif player.ze2.team == 2 then
					if player.ze2.checkpoint_number < checkpoint_number and checkpoint_number ~= ZE2.GetLatestCheckpoint(player) then
						player.ze2.checkpoint_number = checkpoint_number
						ZE2.DeductCatchupTics(player, 5*TICRATE)
						--print("Not same checkpoint number, deducting tics")
					elseif checkpoint_number == ZE2.GetLatestCheckpoint(player) then
						player.ze2.checkpoint_catchuptics = 0
						player.ze2.checkpoint_number = ZE2.GetLatestCheckpoint(player)
						--print("Equal checkpoints")
					end
				end
			end
		end
	end
end 

addHook("MapLoad", function()
	ZE2.Checkpoints = {}
	ZE2.LatestSurvivorCheckpoint = 0
	ZE2.LatestZombieCheckpoint = 0
	
	if gametype ~= GT_ZE2 then return end
	
	local checkpoint_doomednum = mobjinfo[MT_ZE2CHECKPOINT].doomednum
	
	for thing in mapthings.iterate do 
		local checkpoint_number = thing.args[0]
		local checkpoint_flags = thing.args[1]
		local checkpoint_catchup_delay = thing.args[2]
		local checkpoint_extra_flags = thing.args[3]
		
		local SURVIVORFLAG, ZOMBIEFLAG = 1<<0, 1<<1
		
		-- Disable Auto Trigger (Disables the function where it auto triggers the checkpoint if you're in the same sector as it)
		local DISABLEAUTOTRIGGER = 1<<2
		
		if checkpoint_number and thing.type == checkpoint_doomednum then
			ZE2.Checkpoints[checkpoint_number] = {
				x = thing.x,
				y = thing.y,
				z = P_FloorzAtPos(thing.x*FU, thing.y*FU, thing.z*FU, mobjinfo[MT_ZE2CHECKPOINT].height)/FU,
				angle = thing.angle,
				subsector = R_PointInSubsectorOrNil(thing.x*FU, thing.y*FU),
				mobj = thing.mobj,
				thing = thing,
				tag = thing.tag,
				catchup_delay = checkpoint_catchup_delay*TICRATE,
				zombie_checkpoint = (checkpoint_flags & ZOMBIEFLAG) > 0,
				survivor_checkpoint = (checkpoint_flags & SURVIVORFLAG) > 0,
				disable_autotrigger = (checkpoint_extra_flags & DISABLEAUTOTRIGGER) > 0,
			}
		end
	end
end)

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

-- Main checkpoint thinker.
addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	if not #ZE2.Checkpoints then return end
	
	for player in players.iterate do
		local pmo = player.mo
		
		if pmo and pmo.valid then
			for checkpoint_num,checkpoint in pairs(ZE2.Checkpoints) do
				if checkpoint.subsector and checkpoint.subsector.valid 
				and checkpoint.subsector.sector and checkpoint.subsector.sector.valid
				and checkpoint.mobj and checkpoint.mobj.valid then
					if pmo.subsector.sector == checkpoint.subsector.sector
					and not checkpoint.disable_autotrigger then
						local sector = checkpoint.subsector.sector
						local cmo = checkpoint.mobj
						
						local zrange = getMobjZSectorRange(cmo, sector)
						
						-- use our floor and height caps
						if pmo.z < zrange.ceiling and pmo.z + pmo.height > zrange.floor then
							ActivateCheckpoint(pmo, checkpoint.mobj)
						end
					end
					
					if checkpoint.tag then
						for sector in sectors.tagged(checkpoint.tag) do
							if sector and sector.valid 
							and pmo.subsector and pmo.subsector.valid 
							and pmo.subsector.sector and pmo.subsector.sector.valid
							and pmo.subsector.sector == sector then
								local zrange = getMobjZSectorRange(pmo, sector)
								
								if pmo.z < zrange.ceiling and pmo.z + pmo.height > zrange.floor then
									ActivateCheckpoint(pmo, checkpoint.mobj)
								end
							end
						end
					end
				end
			end
		end
	end
end)

-- TODO: Remove this whole hook in Gamma 3
addHook("LinedefExecute", function(line, mobj, sector)
	local checkpoint_doomednum = mobjinfo[MT_ZE2CHECKPOINT].doomednum
	
	if mobj and mobj.valid and mobj.player and mobj.player.valid then
		if line.tag then
			local foundcheckpoint
			
			for mapthing in mapthings.tagged(line.tag) do
				if mapthing.type ~= checkpoint_doomednum then continue end
				
				foundcheckpoint = mapthing
				--print("Found Checkpoint")
				break;
			end
			
			if foundcheckpoint and foundcheckpoint.mobj and foundcheckpoint.mobj.valid then
				--print("Valid checkpoint mobj")
				ActivateCheckpoint(mobj, foundcheckpoint.mobj)
			end
		end
	end
end, "ZE2CHECKPOINT")

addHook("PlayerSpawn", function(player)
	if not leveltime then return end
	if gametype ~= GT_ZE2 then return end
	
	if player.mo and player.mo.valid then
		ZE2.LatestCheckpointTeleport(player, true)
	end
end)