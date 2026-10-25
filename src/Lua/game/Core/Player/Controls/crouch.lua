ZE2.PlayerHeight = 64 * FRACUNIT
ZE2.PlayerSpinHeight = 32 * FRACUNIT

freeslot("SPR2_ZECH")
freeslot("S_PLAY_CROUCH_ZE2")

spr2defaults[SPR2_ZECH] = SPR2_ROLL

states[S_PLAY_CROUCH_ZE2] = {
    sprite = SPR_PLAY,
    frame = SPR2_ZECH|FF_ANIMATE|A,
    tics = -1,
    nextstate = S_PLAY_ROLL
}

local function FitGapHook(player)
	return (player.ze2.crouching == true)
end

local function HeightHook(player)
	if player.ze2.crouching then
		return ZE2.PlayerSpinHeight
	else
		return ZE2.PlayerHeight
	end
end

local function clamp(v, mx, mn)
	return max(min(v,mn), mx)
end

local function SetCrouchState(mobj)
	mobj.state = S_PLAY_CROUCH_ZE2
end

local function crouchcondition(player)
	local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
	if not (player.mo and player.mo.valid) then return false end
	-- Don't crouch when you're dead, you look weird, and not necessarily because of the crouching.
	if not (player.mo.health) then return false end

	if multiplayer then
		if (game.state == ZE2.GS_PREGAME and not settings.move_during_pregame) then return false end
		if (game.zombie_release_time and player.mo.team == 2) then return false end
	end
	return true
end

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local stateset = false
		if not crouchcondition(player) then continue end

		local cmd = player.cmd
		local pmo = player.mo
		if (cmd.buttons & BT_SPIN) then
			if not player.ze2.crouching then
				-- left over source movement code that could be reused.
				-- player.mo.z = clamp($ + FixedMul(player.height - player.spinheight, pmo.scale) * P_MobjFlip(pmo), pmo.floorz, pmo.ceilingz-P_GetPlayerSpinHeight(player))
				
				player.ze2.crouching = true
			else
				if not stateset then
					stateset = true
					SetCrouchState(pmo)
				end
			end
		else -- if gap higher than player height
			if (player.mo.ceilingz - player.mo.floorz) > ZE2.PlayerHeight then
				if player.ze2.crouching then
					if P_IsObjectOnGround(player.mo) or (player.mo.eflags & MFE_JUSTHITFLOOR) then
						if pmo.state == S_PLAY_CROUCH_ZE2 then
							if (player.speed / FU) then
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
						
						-- left over source movement code that could be reused.
						-- player.mo.z = clamp(player.mo.z - FixedMul(player.height - player.spinheight, pmo.scale) * P_MobjFlip(pmo), pmo.floorz, pmo.ceilingz - P_GetPlayerHeight(player) + FixedMul(8 * FU, pmo.scale))
					end
					player.pflags = player.pflags & ~(PF_SPINNING)
				end
				player.ze2.crouching = false
			else
				player.ze2.crouching = true

				if not stateset then
					stateset = true
					SetCrouchState(pmo)
				end
			end
		end

		if (P_IsObjectOnGround(player.mo) and player.ze2.crouching) then
			if not stateset then
				stateset = true
				SetCrouchState(pmo)
			end
		end
		cmd.buttons = cmd.buttons & ~(BT_SPIN)
	end
end)

-- camera movement and fix for a visual bug when jumping or landing
-- these states will be immediately be replaced with S_PLAY_CROUCH_ZE2 if your crouching
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

addHook("ThinkFrame", function()
	for player in players.iterate do
		if not (player.mo and player.mo.valid) then continue end

		if player.ze2.crouching and switchablestates[player.mo.state] then
			if (player.mo.state ~= S_PLAY_CROUCH_ZE2) then
				SetCrouchState(player.mo)
			end
		end

		if player.ze2.crouching then
			player.height = ZE2.PlayerSpinHeight
		else
			player.height = ZE2.PlayerHeight
		end

		if (player == displayplayer) then
			if player.ze2.crouching then
				player.viewheight = (41 * ZE2.PlayerSpinHeight) / 48
			else
				player.viewheight = (41 * player.height) / 48
			end
		end
	end
end)

addHook("PlayerCanEnterSpinGaps", FitGapHook)
addHook("PlayerHeight", HeightHook)