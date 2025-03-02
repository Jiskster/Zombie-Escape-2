freeslot("MT_ZE2CHECKPOINT")

mobjinfo[MT_ZE2CHECKPOINT] = {
	//$Category Zombie Escape 2
	//$Name ZE2 Checkpoint
	//$Sprite TGFXA0 
	
	//$Arg0 Checkpoint Number
	//$Arg0Default 0
	
	//$Arg1 Checkpoint Flags
	//$Arg1Type 12
	//$Arg1Enum {1="Survivor"; 2="Zombie";}
	//$Arg1Flags {1="Survivor"; 2="Zombie";}
	
	//$Arg2 Catchup Delay (Seconds)
	//$Arg2Default 25

	//$Arg3 Extra Flags
	//$Arg3ToolTip Indiscriminate Checkpoints: \nAllow any team to influence other team's catchup teleports.
	//$Arg3Type 12
	//$Arg3Enum {1="Indiscriminate Checkpoints"; 2="Disable Catchup";}
	//$Arg3Flags {1="Indiscriminate Checkpoints"; 2="Disable Catchup";}
	
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
	if player["ze2_info"].team == 1 then
		return ZE2.LatestSurvivorCheckpoint
	elseif player["ze2_info"].team == 2 then
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
			player["ze2_info"].checkpoint_number = latest_checkpoint
		end
	end
end

function ZE2.DeductCatchupTics(player, tics)
	if player["ze2_info"].checkpoint_catchuptics <= 0 then return end
	
	if player["ze2_info"].checkpoint_catchuptics - tics <= 0 then
		player["ze2_info"].checkpoint_catchuptics = 0
		ZE2.LatestCheckpointTeleport(player)
	else
		player["ze2_info"].checkpoint_catchuptics = $ - tics
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
		local INDISCRIMINATE_FLAG = 1<<0 --Indiscriminate Checkpoints
		local DISABLECATCHUP_FLAG = 1<<1 --Disable catchup (Makes it so others dont have to catch up to you)
		
		if checkpoint_number then
			if (checkpoint_flags & SURVIVORFLAG) and (player["ze2_info"].team == 1 or (checkpoint_extra_flags & INDISCRIMINATE_FLAG)) then
				if ZE2.LatestSurvivorCheckpoint < checkpoint_number then -- Is activating a newer checkpoint
					ZE2.LatestSurvivorCheckpoint = checkpoint_number
					player["ze2_info"].checkpoint_number = ZE2.LatestSurvivorCheckpoint
					
					checkpoint.state = checkpoint.info.painstate
					S_StartSound(mobj, checkpoint.info.painsound)
					print("Checkpoint Activated: "..checkpoint_number)
					
					if not (checkpoint_extra_flags & DISABLECATCHUP_FLAG) then
						for tplayer in players.iterate do 
							if tplayer.spectator then continue end
							if player == tplayer then continue end 
							
							
							if tplayer["ze2_info"] and tplayer["ze2_info"].team == 1 and tplayer["ze2_info"].checkpoint_number < checkpoint_number then
								if tplayer["ze2_info"].checkpoint_catchuptics then
									ZE2.DeductCatchupTics(player, 5*TICRATE)
									continue
								end
							
								tplayer["ze2_info"].checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
							end
						end
					end
				elseif player["ze2_info"].team == 1 then
					if player["ze2_info"].checkpoint_number < checkpoint_number and checkpoint_number ~= ZE2.GetLatestCheckpoint(player) then
						ZE2.DeductCatchupTics(player, 5*TICRATE)
						--print("Not same checkpoint number, deducting tics")
					elseif checkpoint_number == ZE2.GetLatestCheckpoint(player) then
						player["ze2_info"].checkpoint_catchuptics = 0
						player["ze2_info"].checkpoint_number = ZE2.GetLatestCheckpoint(player)
						--print("Equal checkpoints")
					end
				end
			end
			
			if (checkpoint_flags & ZOMBIEFLAG) and (player["ze2_info"].team == 2 or (checkpoint_extra_flags & INDISCRIMINATE_FLAG)) then
				if ZE2.LatestZombieCheckpoint < checkpoint_number then
					ZE2.LatestZombieCheckpoint = checkpoint_number
					player["ze2_info"].checkpoint_number = ZE2.LatestZombieCheckpoint
					
					checkpoint.state = checkpoint.info.painstate
					S_StartSound(mobj, checkpoint.info.painsound)
					print("Checkpoint Activated: "..checkpoint_number)
					
					if not (checkpoint_extra_flags & DISABLECATCHUP_FLAG) then
						for tplayer in players.iterate do 
							if tplayer.spectator then continue end
							if player == tplayer then continue end 
							
							if tplayer["ze2_info"] and tplayer["ze2_info"].team == 2 and tplayer["ze2_info"].checkpoint_number < checkpoint_number then
								if tplayer["ze2_info"].checkpoint_catchuptics then
									ZE2.DeductCatchupTics(player, 5*TICRATE)
									continue
								end
								
								tplayer["ze2_info"].checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
							end
						end
					end
				elseif player["ze2_info"].team == 2 then
					if player["ze2_info"].checkpoint_number < checkpoint_number and checkpoint_number ~= ZE2.GetLatestCheckpoint(player) then
						player["ze2_info"].checkpoint_number = checkpoint_number
						ZE2.DeductCatchupTics(player, 5*TICRATE)
						--print("Not same checkpoint number, deducting tics")
					elseif checkpoint_number == ZE2.GetLatestCheckpoint(player) then
						player["ze2_info"].checkpoint_catchuptics = 0
						player["ze2_info"].checkpoint_number = ZE2.GetLatestCheckpoint(player)
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
		local SURVIVORFLAG, ZOMBIEFLAG = 1<<0, 1<<1
		
		if checkpoint_number and thing.type == checkpoint_doomednum then
			ZE2.Checkpoints[checkpoint_number] = {
				x = thing.x,
				y = thing.y,
				z = P_FloorzAtPos(thing.x*FU, thing.y*FU, thing.z*FU, mobjinfo[MT_ZE2CHECKPOINT].height)/FU,
				angle = thing.angle,
				subsector = R_PointInSubsectorOrNil(thing.x*FU, thing.y*FU),
				mobj = thing.mobj,
				thing = thing,
				catchup_delay = checkpoint_catchup_delay*TICRATE,
				zombie_checkpoint = not not (checkpoint_flags & ZOMBIEFLAG),
				survivor_checkpoint = not not (checkpoint_flags & SURVIVORFLAG),
			}
		end
	end
end)

addHook("ThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	if not #ZE2.Checkpoints then return end
	
	for player in players.iterate do
		local pmo = player.mo
		
		if pmo and pmo.valid then
			for checkpoint_num,checkpoint in pairs(ZE2.Checkpoints) do
				print("A: "..P_FloorzAtPos(pmo.x, pmo.y, pmo.z, pmo.height))
				print("B: "..checkpoint.z)
				if checkpoint.subsector ~= nil 
				and pmo.subsector == checkpoint.subsector 
				and P_FloorzAtPos(pmo.x, pmo.y, pmo.z, pmo.height) == checkpoint.z
				and checkpoint.mobj and checkpoint.mobj.valid then
					ActivateCheckpoint(player, checkpoint.mobj)
				end
			end
		end
	end
end)

/*
--minor TODO: Fix Iterating many times in the same checkpoint
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
*/

addHook("PlayerSpawn", function(player)
	if not leveltime then return end
	if gametype ~= GT_ZE2 then return end
	
	if player.mo and player.mo.valid then
		ZE2.LatestCheckpointTeleport(player, true)
	end
end)