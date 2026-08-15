local INCREMENT = FRACUNIT / 2
local DECREMENT = FixedDiv(35*FU, 100*FU) 

local BOOST_DECREMENT = 10 * FRACUNIT

local SIDEMOVE_THRESHOLD = 28 -- So that players dont sideways sprint.

---@param player player_t
local function HandleSprinting(player)
	
	if player.climbing then return end

	local cmd = player.cmd
	local mobj = player.mo
	local ze2 = player.ze2
	if not mobj or not mobj.valid then return end
	if (mobj.team ~= 1) then return end
	
	local ground = P_IsObjectOnGround(mobj)
	local speed = FixedInt(abs(R_PointToDist2(0, 0, player.rmomx, player.rmomy)))
	if (speed >= 18) then
		local run = false
		if ground and ze2.isRunning and not ze2.crouching then
			player.runspeed = 1
			run = true

			ze2:ChangeStamina(-DECREMENT)
			P_SpawnSkidDust(player, 20 * FRACUNIT)
		end

		if not (player.pflags & PF_SPINNING) then
			if not run then
				ze2:ChangeStamina(INCREMENT / 2)
				player.runspeed = 32000 * FRACUNIT
			end
		else
			ze2:ChangeStamina(-DECREMENT)
			if ground then P_SpawnSkidDust(player, 20*FRACUNIT) end
		end
	else
		if ze2.isRunning then
			player.pflags = player.pflags & ~(PF_SPINNING)
			if not ze2.runstart then
				ze2.rundelay = 6
				ze2.isRunning = false
			end
		end

		if ground and (speed == 0) then -- not moving
			ze2:ChangeStamina(INCREMENT * 3)
		else -- moving but slower than running speed
			ze2:ChangeStamina(INCREMENT)
		end
		player.runspeed = 32000 * FRACUNIT
	end

	if not cmd.forwardmove or not ze2.sprintmeter or ze2.sprintdelay or (abs(cmd.sidemove) > SIDEMOVE_THRESHOLD) then -- Stop running if you meet these requirements:
		if ze2.isRunning then
			player.pflags = player.pflags & ~(PF_SPINNING)
		end
		ze2.runstart = 0
		ze2.isRunning = false
	end

	if ze2.runstart then -- "Acceleration" boost when starting to run.
		P_Thrust(mobj, mobj.angle, 1 * FU)
		if ground then
			ze2.runstart = max(0, ze2.runstart - 1)
		else
			ze2.runstart = max(0, ze2.runstart - 2)
		end
	end
	
	if ground then
		if ze2.crouching and ze2.isRunning then -- Rollin Time
			if (speed >= 12) then
				player.pflags = player.pflags | PF_SPINNING
			else
				player.pflags = player.pflags & ~(PF_SPINNING)
			end
		end

		-- Initial Running code
		if ze2.rundelay then
			ze2.rundelay = max(0, ze2.rundelay - 1)
		elseif ze2.sprintmeter then
			if (speed >= 8) and (cmd.forwardmove > 0) and (cmd.buttons & BT_CUSTOM1) 
			and not ze2.runstart and (abs(cmd.sidemove) <= SIDEMOVE_THRESHOLD) then
				if not ze2.isRunning and not ze2.crouching then -- Start sprint
					ze2:ChangeStamina(-BOOST_DECREMENT)
					S_StartSound(mobj, sfx_s3ka2)
					ze2.runstart = 9
				end
				player.drawangle = mobj.angle
				ze2.isRunning = true
			elseif not (cmd.buttons & BT_CUSTOM1) then
				if ze2.isRunning then
					ze2.rundelay = 6 -- delay when letting go
				end
				ze2.isRunning = false
			end
		end
	end
	
	if (mobj.eflags & MFE_TOUCHWATER) or (mobj.eflags & MFE_UNDERWATER) then
		player.pflags = player.pflags & ~(PF_SPINNING)
	end
end

return function()
	for player in players.iterate do
		HandleSprinting(player)
	end
end