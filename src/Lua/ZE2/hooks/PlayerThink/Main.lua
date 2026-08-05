return function(player) ---@param player player_t
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
	if not ZE2.round_active and player.spectator and player.jointime <= TICRATE then
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
		if ZE2.landingfatigue.value and (pv.lastJumped) then
			local bhopped = false

			if (player.cmd.buttons & BT_JUMP) and not (player.lastbuttons & BT_JUMP) then
				bhopped = true
			end

			if (pmo.eflags & MFE_JUSTHITFLOOR) and not bhopped then
				pmo:speedCapXY(5*FU)
			end
		end

		if player.playerstate == PST_DEAD then
			if ZE2.round_active and not ZE2_game_ended and not player.ze2.respawntics then
				if player.xSlinger.team == 1 then
					player.ze2.respawntics = 10*TICRATE
					player.ze2.outofgame = true
				elseif player.xSlinger.team == 2 then
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

	ZE2.applyPlayerConfig(player)
		
	pv.lastJumped = (player.pflags & PF_JUMPED == PF_JUMPED)
end



