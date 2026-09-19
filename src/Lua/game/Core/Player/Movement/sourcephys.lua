-- I thank cobaltn't for contributing to ZE2 and adding this.

--can the player move this tic?
local function CanPlayerMove(player)
	return (player.mo and player.mo.valid
	and player.exiting == 0
	and player.mo.reactiontime == 0
	and player.playerstate == PST_LIVE
	and (player.powers[pw_carry] == 0 or player.powers[pw_carry] == 13)
	and player.powers[pw_nocontrol] == 0
	and player.climbing == 0
	and not (player.mo.state >= S_PLAY_SUPER_TRANS1 and player.mo.state <= S_PLAY_SUPER_TRANS6)
	and not P_PlayerInPain(player)
	and not (player.pflags & PF_SLIDING)
	and not (player.pflags & PF_STASIS))
end

addHook("PlayerThink", function(player)
	--source movement?
	if ZE2.cv_sourcemovement.value and FixedHypot(player.cmd.forwardmove * 1311, player.cmd.sidemove * 1311)
	and CanPlayerMove(player) then
		local cmd = player.cmd
		local pmo = player.mo
		--remove conveyor movement
		local cx = player.cmomx
		local cy = player.cmomy
		pmo.momx = $ - cx
		pmo.momy = $ - cy

		local wishang
		wishang = R_PointToAngle2(0, 0, cmd.forwardmove * FRACUNIT, cmd.sidemove * -FRACUNIT) + pmo.angle
		if (player.pflags & PF_ANALOGMODE) and not (pmo.flags2 & MF2_TWOD) then
			wishang = cmd.angleturn<<16 + R_PointToAngle2(0, 0, cmd.forwardmove * FRACUNIT, cmd.sidemove * -FRACUNIT)
		end
		if (pmo.flags2 & MF2_TWOD) then wishang = pmo.angle end
		local analog = FixedHypot(cmd.forwardmove * 1311, cmd.sidemove * 1311)

		local movedir = R_PointToAngle2(0, 0, pmo.momx, pmo.momy)
		local movespd = FixedDiv(FixedHypot(pmo.momx, pmo.momy), pmo.scale)

		local wishspd
		local angdiff
		local curspeed
		angdiff = abs(movedir - wishang)
		curspeed = FixedMul(movespd, cos(angdiff))

		local acl
		if P_IsObjectOnGround(pmo) then
			wishspd = player.normalspeed
			acl = FixedMul(FixedMul(player.acceleration * 320, movespd) + player.accelstart * 320, analog)
		else
			wishspd = 2*FRACUNIT
			acl = FixedMul(FixedMul(player.acceleration * 80, movespd) + player.accelstart * 160, analog)
		end
		if pmo.eflags & MFE_UNDERWATER then
			if P_IsObjectOnGround(pmo) then wishspd = $/2 end
			acl = 3*$/4
		end

		if pmo.standingslope and not (pmo.standingslope.flags & SL_NOPHYSICS) and abs(pmo.standingslope.zdelta) > FRACUNIT/2 then
			local thrustangle = wishang-pmo.standingslope.xydirection;

			local mul = ease.linear(abs(cos(thrustangle)), FRACUNIT, abs(cos(pmo.standingslope.zangle)))
			if pmo.standingslope.zdelta < 0 then
				if thrustangle < ANGLE_90 or thrustangle > ANGLE_270 then
					acl = FixedMul($, mul)
				end
			else
				if thrustangle > ANGLE_90 and thrustangle < ANGLE_270 then
					acl = FixedMul($, mul)
				end
			end
		end

		local addspd = min(max(wishspd - curspeed, 0), acl)

		P_Thrust(pmo, wishang, FixedMul(addspd, pmo.scale))

		if player.ze2.sprintdelay and not P_IsObjectOnGround(pmo) then
			L_SpeedCapXY(pmo, FixedMul(max(movespd, wishspd), pmo.scale))
		elseif not P_IsObjectOnGround(pmo) then
			L_SpeedCapXY(pmo, FixedMul(max(movespd, 22*FRACUNIT), pmo.scale))
		end

		pmo.momx = $ + cx
		pmo.momy = $ + cy
	end
end)