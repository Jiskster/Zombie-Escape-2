freeslot("MT_ZE2CHECKPOINT")

mobjinfo[MT_ZE2CHECKPOINT] = {
	//$Category Zombie Escape 2
	//$Name ZE2 Checkpoint
	//$Sprite STPTA0
	//$Arg0 Checkpoint Number
	//$Arg0Default 0
	//$Arg1 Checkpoint Flags
	//$Arg1Type 12
	//$Arg1Enum {1="Survivor"; 2="Zombie";}
	//$Arg1Flags {1="Survivor"; 2="Zombie";}
	//$Arg2 Catchup Delay (Seconds)
	//$Arg2Default 25
	
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

local function ActivateCheckpoint(mobj, checkpoint)
	local isvalid = mobj.player and mobj.player.valid 
					and checkpoint and checkpoint.valid
					and checkpoint.spawnpoint
	local player = mobj.player
					
	if isvalid then
		local checkpoint_number = checkpoint.spawnpoint.args[0]
		local checkpoint_flags = checkpoint.spawnpoint.args[1]
		local checkpoint_catchup_delay = checkpoint.spawnpoint.args[2]
		local SURVIVORFLAG, ZOMBIEFLAG = 1<<0, 1<<1
		
		if checkpoint_number then
			if (checkpoint_flags & SURVIVORFLAG) and player["ze2_info"].team == 1 then
				if ZE2.LatestSurvivorCheckpoint < checkpoint_number then
					ZE2.LatestSurvivorCheckpoint = checkpoint_number
					checkpoint.state = checkpoint.info.painstate
					S_StartSound(mobj, checkpoint.info.painsound)
					
					for tplayer in players.iterate do 
						if tplayer.spectator then continue end
						if player == tplayer then continue end 
						
						if tplayer["ze2_info"] and tplayer["ze2_info"].team == 1 and tplayer["ze2_info"].checkpoint_number < checkpoint_number then
							tplayer["ze2_info"].checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
						end
					end
				end
			end
			
			if (checkpoint_flags & ZOMBIEFLAG) and player["ze2_info"].team == 2 then
				if ZE2.LatestZombieCheckpoint < checkpoint_number then
					ZE2.LatestZombieCheckpoint = checkpoint_number
					checkpoint.state = checkpoint.info.painstate
					S_StartSound(mobj, checkpoint.info.painsound)
					
					for tplayer in players.iterate do 
						if tplayer.spectator then continue end
						if player == tplayer then continue end 
						
						if tplayer["ze2_info"] and tplayer["ze2_info"].team == 2 and tplayer["ze2_info"].checkpoint_number < checkpoint_number then
							tplayer["ze2_info"].checkpoint_catchuptics = checkpoint_catchup_delay*TICRATE
						end
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
				catchup_delay = checkpoint_catchup_delay*TICRATE,
				zombie_checkpoint = not not (checkpoint_flags & ZOMBIEFLAG),
				survivor_checkpoint = not not (checkpoint_flags & SURVIVORFLAG),
			}
		end
	end
end)

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