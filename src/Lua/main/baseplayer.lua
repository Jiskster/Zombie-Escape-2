freeslot("sfx_zjump")
sfxinfo[sfx_zjump].caption = "Jump"
mobjinfo[MT_LHRT].forceknockback = 20*FRACUNIT
SRBZ.JumpSprintFatigue = 5*FRACUNIT

-- some stuff that player needs
SRBZ.giveplayerflags = function(player)
	if gametype == GT_SRBZ then
		player.charflags = SF_NOJUMPSPIN|SF_NOJUMPDAMAGE|SF_NOSKID
		player.pflags = $ & ~PF_DIRECTIONCHAR
		player.pflags = $ & ~PF_ANALOGMODE 
		
		if player.sprintmeter == nil then
			player.sprintmeter = 100*FRACUNIT
		end
		
		if player.sprintmeter < 0 then
			player.sprintmeter = 0
		end
		player.isSprinting = $ or false
		
		if player.zteam == 1 then
			SRBZ.SetCCtoplayer(player)
		elseif player.zteam == 2 then
			SRBZ.SetZCtoplayer(player)
		end
		
		if mapheaderinfo[gamemap].srbz_noabilities then
			player.pflags = $ & ~PF_GLIDING
			player.pflags = $ & ~PF_BOUNCING
			player.powers[pw_tailsfly] = 0
		end
	else 
		if leveltime < 2 then
			SRBZ.RevertChars(player) 
		end
	end
end

function SRBZ:DecrementSprint(player, value)
	if player.sprintmeter - abs(value) <= 0 then
		player.sprintmeter = 0
	else
		player.sprintmeter = $ - abs(value)
	end
end

function SRBZ:IncrementSprint(player, value)
	if player.sprintmeter + abs(value) >= 100*FRACUNIT then
		player.sprintmeter = 100*FRACUNIT
	else
		player.sprintmeter = $ + abs(value)
	end
end

-- sprint code
SRBZ.sprint_thinker = function(player)
	if not (player.mo and player.mo.valid) return end
		
	local cmd = player.cmd
	
	local pmo = player.mo
	local cc = SRBZ.CharacterConfig
	
	local increment = FRACUNIT/4
	local decrement = FRACUNIT/3
	
	if player.zteam == 1 then
		if P_GetPlayerControlDirection(player) == 1 and (cmd.buttons & BT_SPIN) then
			
			SRBZ:DecrementSprint(player, decrement)
			
			player.isSprinting = true

			-- Running Animation
			if player.sprintmeter == 0 then
				player.runspeed = 32000*FRACUNIT
			else
				player.runspeed = 5*FRACUNIT
				if player.speed >= 5*FRACUNIT and P_IsObjectOnGround(pmo) then
					P_SpawnSkidDust(player, 20*FRACUNIT)
				end
			end
		else
			SRBZ:IncrementSprint(player, increment)
			
			player.isSprinting = false
			
			-- Force Walking Animation
			player.runspeed = 32000*FRACUNIT
		end
	else
		player.isSprinting = false
	end
	
	cmd.buttons = $ & ~BT_SPIN
end

addHook("JumpSpecial", function(player)
	if player.mo and player.mo.valid and player.isSprinting and P_IsObjectOnGround(player.mo) then
		if player.sprintmeter - SRBZ.JumpSprintFatigue <= 0 then
			player.sprintmeter = 0
			return true
		else
			player.sprintmeter = $ - SRBZ.JumpSprintFatigue
		end
	end
end)

-- we hate griefers
addHook("LinedefExecute", function(line, mobj, sector)
	if mobj and mobj.valid and mobj.player and mobj.player.valid then
		local player = mobj.player
		
		player.pflags = $ & ~PF_GLIDING
		player.pflags = $ & ~PF_BOUNCING
		player.powers[pw_tailsfly] = 0
	end
end, "NOABILITY")

-- Limit for climbing characters.
addHook("PlayerThink", function(player) 
	if gametype ~= GT_SRBZ then return end
    if player.mo and player.mo.valid then
        player.x_climbtime = $ or 0 
        if player.climbing then
            player.x_climbtime = $ + 1
        elseif player.x_climbtime then
            player.x_climbtime = $ - 1  
            player.pflags = $ | PF_THOKKED
        end

        if player.x_climbtime > 2*TICRATE + TICRATE/2 then
            player.climbing = 0
        end
    end
end)

SRBZ.ResetPlayer = function(player, choosenewztype)
	if player.zteam == 1 then
		SRBZ.SetCCtoplayer(player)
		SRBZ.SetCChealth(player)
		player.ztype = nil
	elseif player.zteam == 2 then
		SRBZ.SetZCtoplayer(player)
		SRBZ.SetZChealth(player)
		SRBZ.SetZCscale(player)
		SRBZ.SetZCinventory(player)
	end
end

SRBZ.init_player = function(player)
	if gametype ~= GT_SRBZ and leveltime then return end
	
	local pmo = player.mo
	
	if player and pmo and pmo.valid then
		if (SRBZ.round_active and SRBZ.PlayerCount() > 1) then
			player.zteam = 2
			player.ztype = "normal"
			if SRBZ.round_active and SRBZ.PlayerCount() > 1 and leveltime then
				if P_RandomChance(FRACUNIT/5) and not player.z_was_spectating then
					player.ztype = "alpha"
				end
			end
			player.z_was_spectating = false
		else
			player.zteam = 1
		end
		
		SRBZ.ResetPlayer(player, true)

		if player.zteam == 2 then 
			R_SetPlayerSkin(player, "zzombie") 
		end

		player.sprintmeter = 100*FRACUNIT
	end
end

-- Zombie Spawn Sounds
addHook("PlayerSpawn", function(player)
	local spawnsounds = {sfx_inf1,sfx_inf2}
	if player.mo and player.mo.valid and player.zteam == 2 and SRBZ.round_active and leveltime then
		local soundrng = P_RandomRange(1,#spawnsounds)
		S_StartSound(player.mo,spawnsounds[soundrng])
	end
end)

-- Jump Sound Replacement
addHook("MobjThinker", function(mobj)
	if gametype ~= GT_SRBZ then return end
	if S_SoundPlaying(mobj, sfx_jump) then
		S_StopSoundByID(mobj, sfx_jump)
		S_StartSound(mobj, sfx_zjump)
	end
end, MT_PLAYER)

-- Prevent people of different teams from spectating eachother
addHook("ViewpointSwitch", function(player, nextplayer)
	if player.spectator then
		return
	end
	if nextplayer.zteam ~= player.zteam then
		return false
	end
end)

-- Disable special zombie types when unspectating
addHook("TeamSwitch", function(player, team, fromspectators)
	if fromspectators then
		player.z_was_spectating = true
	end
end)

-- if you die you be zombie
addHook("MobjDeath", function(mobj)
	if SRBZ.round_active and not SRBZ_game_ended and 
	((SRBZ.PlayerCount() > 1) or (mapheaderinfo[gamemap].srbz_solofail)) then
		mobj.player.zteam = 2
	end
end,MT_PLAYER)

-- lock zombies color and prevent survivors from being zombie skin and vice versa
addHook("PlayerThink", function(player)	
	if gametype ~= GT_SRBZ or not player.mo return end
	
	local ztype = player.ztype
	local zc = SRBZ.ZombieConfig
	
	if player.zteam == 2 and player.mo.skin ~= "zzombie" then
		R_SetPlayerSkin(player, "zzombie")
	elseif player.zteam == 1 and player.mo.skin == "zzombie" then
		R_SetPlayerSkin(player, "sonic")
		player.mo.color = player.skincolor
	end
		
	if (player.zteam == 2 and ztype and zc[ztype]) then 
		player.mo.color = zc[ztype].skincolor or SKINCOLOR_MOSS
	end
end)

COM_AddCommand("z_changeztype", function(player, new_ztype)
	if not (player.mo and player.mo.valid) then return end
	if player.zteam ~= 2 then
		print("You must be a zombie to run this command.")
		return
	end
	
	if not new_ztype then
		print("z_changeztype <ztype>: changes your zombie type.")
		return
	end
	
	local zc = SRBZ.ZombieConfig
	
	if zc[new_ztype] then
		player.ztype = new_ztype
		SRBZ.ResetPlayer(player)
	else
		print("Invalid ztype. "..'"'..new_ztype..'"')
	end
end, 1)