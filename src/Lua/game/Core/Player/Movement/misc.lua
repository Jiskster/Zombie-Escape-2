---@param player player_t
local function ReplaceJumpSound(player)
	local pmo = player.mo

	if pmo and pmo.valid then
		local sound = skins[pmo.skin].soundsid[SKSJUMP] or sfx_jump
		if S_SoundPlaying(pmo, sound) then
			S_StopSoundByID(pmo, sound)
			S_StartSound(pmo, sfx_zjump)
		end
	end
end

---@param player player_t
---@param direction integer
local function CycleSpectator(player, direction)
	local MAXPLAYERS = 31
	player.ze2.spectator_cycle = (player.ze2.spectator_cycle + direction) % MAXPLAYERS

	local attempts = 64
	while true do
		attempts = attempts - 1
		if (attempts <= 0) then break end

		local selected = players[player.ze2.spectator_cycle]
		if not selected or not selected.valid or selected.spectator or not selected.mo or not selected.mo.valid then
			player.ze2.spectator_cycle = player.ze2.spectator_cycle + direction
			if (player.ze2.spectator_cycle > MAXPLAYERS) then
				player.ze2.spectator_cycle = 0
			elseif (player.ze2.spectator_cycle < 0) then
				player.ze2.spectator_cycle = MAXPLAYERS
			end
			continue
		end

		P_SetOrigin(player.realmo, selected.mo.x, selected.mo.y, selected.mo.z)
		player.realmo.angle = selected.mo.angle
		break
	end
end

---@param player player_t
local function SpectatorHandle(player)
	if not player.realmo or not player.realmo.valid then return end
	if not player.spectator then return end
	if (player.playerstate ~= PST_LIVE) then return end

	if (player.cmd.buttons & BT_CUSTOM2) and not (player.lastbuttons & BT_CUSTOM2) then
		CycleSpectator(player, 1)
	end

	if (player.cmd.buttons & BT_CUSTOM1) and not (player.lastbuttons & BT_CUSTOM1) then
		CycleSpectator(player, -1)
	end

    player.realmo.flags = player.realmo.flags | (MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING)
end

addHook("PlayerThink", function(player) ---@param player player_t
	SpectatorHandle(player)
	ReplaceJumpSound(player)

	local game = ZE2.Game
	local pv = player.ze2
	local pmo = player.mo

	player.charflags = SF_NOJUMPSPIN|SF_NOJUMPDAMAGE|SF_NOSKID -- Remove Vanilla Flags
	player.pflags = $ & ~PF_DIRECTIONCHAR

	if (player.pflags & PF_ANALOGMODE) then
		player.pflags = $ | PF_FORCESTRAFE
		player.pflags = $ & ~PF_ANALOGMODE
	else
		player.pflags = $ & ~PF_FORCESTRAFE
	end

	-- If player joined the server before the game starts
	if not game.active and player.spectator and player.jointime <= TICRATE then
		player.spectator = false
		player.playerstate = PST_REBORN
		ZE2.ResetPlayer(player, 1, true, true) -- Change to survivor and reset inventory
	end

	if pv.injoinqueue and not player.spectator then
		pv.injoinqueue = false
	end

	if pv.sprintmeter < 0 then
		pv.sprintmeter = 0
	end

	if pmo and pmo.valid then
		if pmo.team == 2 then
			player.powers[pw_underwater] = 0
		end

		local spd = FixedHypot(pmo.momx, pmo.momy)

		if (player.pflags & PF_JUMPED) then
			pv.isJumping = true
		end

		if (pmo.eflags & MFE_SPRUNG) then
			pv.isSprung = true
		end

		if P_IsObjectOnGround(pmo) or (pmo.eflags & MFE_JUSTHITFLOOR) then
			if pv.isJumping then
				pv.isJumping = false
			end

			pv.isSprung = false
		end

		--lastJumped is shitty ik but i cant think of a good way to do this
		--WITHOUT having to make a new variable in the ze2 table
		if ZE2.cv_landingfatigue.value and (pv.lastJumped) then
			local bhopped = false

			if (player.cmd.buttons & BT_JUMP) and not (player.lastbuttons & BT_JUMP) then
				bhopped = true
			end

			if (pmo.eflags & MFE_JUSTHITFLOOR) and not bhopped then
				pmo:speedCapXY(5*FU)
			end
		end

		if player.playerstate == PST_DEAD then
			if game.active and not game.ended and not player.ze2.respawntics then
				if pmo.team == 1 then
					player.ze2.respawntics = 10*TICRATE
					player.ze2.outofgame = true
				elseif pmo.team == 2 then
					player.ze2.respawntics = 15*TICRATE
				end
			end
		end

		-- remove burning effect when underwater
		if (pmo.eflags & MFE_TOUCHWATER) or (pmo.eflags & MFE_UNDERWATER) then
			local found = pmo:search_effect("burning")
			if (#found ~= 0) then
				pmo:remove_effect("burning")
			end
		end
	end

	pv.lastJumped = (player.pflags & PF_JUMPED == PF_JUMPED)
end)



