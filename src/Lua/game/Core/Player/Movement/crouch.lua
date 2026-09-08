ZE2.PlayerHeight = 64*FRACUNIT
ZE2.PlayerSpinHeight = 32*FRACUNIT

freeslot("SPR2_ZECH")
freeslot("S_PLAY_CROUCH_ZE2")

spr2defaults[SPR2_ZECH] = SPR2_ROLL

states[S_PLAY_CROUCH_ZE2] = {
    sprite = SPR_PLAY,
    frame = SPR2_ZECH|FF_ANIMATE|A,
    tics = -1,
    nextstate = S_PLAY_ROLL
}

local function CrouchHeightHook(player)
    return (player.ze2.crouching or player.mo.ceilingz-player.mo.floorz < ZE2.PlayerHeight)
	and (ZE2.PlayerSpinHeight)-- spin height
	or (ZE2.PlayerHeight) -- height
end

local function clamp(v, mx, mn)
	return max(min(v,mn), mx)
end

local function SetCrouchState(mobj)
	local skin = mobj.skin

	/*
	if mobj.frame > skins[skin].sprites[SPR2_ROLL].numframes then
		mobj.frame = A
	end
	*/
	mobj.state = S_PLAY_CROUCH_ZE2
end

local function crouchcondition(player)
	local game = ZE2.Game
	if not (player.mo and player.mo.valid) then return false end

	if multiplayer then
		if (game.state == ZE2.GS_PREGAME) then return false end
		if (game.releasetime and player.mo.team == 2) then return false end
	end

	return true
end

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local stateset = false
		if not crouchcondition(player) then
			continue
		end

		local cmd = player.cmd
		local pmo = player.mo
		local skin = pmo.skin

		if (cmd.buttons & BT_SPIN) then
			local limit = 5*FU

			if not player.ze2.crouching then
				if ZE2.sourcemovement.value and not (P_IsObjectOnGround(player.mo) or (player.mo.eflags & MFE_JUSTHITFLOOR)) then
					player.mo.z = clamp($ + FixedMul(player.height - player.spinheight, pmo.scale) * P_MobjFlip(pmo), pmo.floorz, pmo.ceilingz-P_GetPlayerSpinHeight(player))
				end

				-- mama luigi
				if (P_IsObjectOnGround(player.mo) or (player.mo.eflags & MFE_JUSTHITFLOOR)) and player.speed > 10*FU and not player.ze2.isRunning then
					L_SpeedCapXY(player.mo, limit) -- Halt ground movement
				end

				player.ze2.crouching = true
			else
				-- mama luigi
				if P_IsObjectOnGround(player.mo) and (player.mo.eflags & MFE_JUSTHITFLOOR) and not player.ze2.isRunning then
					L_SpeedCapXY(player.mo, limit)
				end

				if not stateset then
					stateset = true
					SetCrouchState(pmo)
				end
			end
		else
			-- if gap higher than player height
			if (player.mo.ceilingz - player.mo.floorz) > ZE2.PlayerSpinHeight then
				if player.ze2.crouching then
					if P_IsObjectOnGround(player.mo) or (player.mo.eflags & MFE_JUSTHITFLOOR) then
						if pmo.state == S_PLAY_CROUCH_ZE2 then
							if (player.speed/FU) then
								pmo.frame = A
								pmo.state = S_PLAY_WALK
							else
								pmo.frame = A
								pmo.state = S_PLAY_STND
							end
						end
					else
						pmo.frame = A
						pmo.state = S_PLAY_JUMP

						if ZE2.sourcemovement.value then player.mo.z = clamp($ - FixedMul(player.height - player.spinheight, pmo.scale) * P_MobjFlip(pmo), pmo.floorz, pmo.ceilingz-P_GetPlayerHeight(player)+FixedMul(8*FU, pmo.scale)) end
					end

					player.pflags = $ & ~PF_SPINNING
				end

				player.ze2.crouching = false
			else
				if player.ze2.crouching then
					if not stateset then
						stateset = true
						SetCrouchState(pmo)
					end
				end
			end
		end

		if (P_IsObjectOnGround(player.mo) or ZE2.sourcemovement.value) and player.ze2.crouching then
			if not stateset then
				stateset = true
				SetCrouchState(pmo)
			end
		end

		cmd.buttons = $ & ~BT_SPIN
	end
end)

--camera movement and fix for a visual bug when jumping or landing

--these states will be immediately be replaced with S_PLAY_CROUCH_ZE2 if your crouching
local switchablestates = {
	[S_PLAY_STND] = true,
	[S_PLAY_WAIT] = true,
	[S_PLAY_WALK] = true,
	[S_PLAY_RUN] = true,
	[S_PLAY_JUMP] = true,
	[S_PLAY_SPRING] = true,
	[S_PLAY_FALL] = true,
	[S_PLAY_EDGE] = true
}

local clientgametics = 0
local crouchlerp = 0

addHook("PlayerCmd", function(player, cmd)
	if not leveltime then
		clientgametics = 0
	else
		clientgametics = $ + 1
	end
end)

addHook("PostThinkFrame", function()
	local game = ZE2.Game

	for player in players.iterate do
		if not (player.mo and player.mo.valid) then continue end
		if (game.state == ZE2.GS_PREGAME) and multiplayer then continue end

		if player.ze2.crouching and switchablestates[player.mo.state] then
			if not (player.mo.state == S_PLAY_CROUCH_ZE2) then
				SetCrouchState(player.mo)
			end
		end

		if player == displayplayer then
			if player.ze2.crouching then
				crouchlerp = min($+FRACUNIT/7, FRACUNIT)
			else
				crouchlerp = max($-FRACUNIT/4, 0)
			end

			/*
			local newheight = player.mo.z + player.viewheight - ease.inoutquad(crouchlerp, 0, FixedMul(player.height - player.spinheight, player.mo.scale))

			if crouchlerp then
				player.viewz = min($,newheight)
			end
			*/

			local curheight = player.mo.height
			local newheight = player.mo.z+(41*curheight)/48
			if P_IsObjectOnGround(player.mo) then
				local angle = ((8191 / 20 * clientgametics) & 8191) << 19

				local adjust = FixedMul(player.bob / 2, sin(angle))
				newheight = newheight + adjust
			end
			player.viewz = newheight
		end
	end
end)

addHook("PlayerHeight", CrouchHeightHook)
addHook("PlayerCanEnterSpinGaps", CrouchHeightHook)