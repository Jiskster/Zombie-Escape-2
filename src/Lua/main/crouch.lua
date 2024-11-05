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
	if gametype ~= GT_ZE2 then return end

    return (player["ze2_info"].crouching or (player.mo.ceilingz-player.mo.floorz < player.height)) and player.spinheight or player.height
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

addHook("PreThinkFrame", function()
	for player in players.iterate do
		if not (player.mo and player.mo.valid) then continue end
		if gametype ~= GT_ZE2 then continue end
		if ZE2.game_ended then continue end
		
		local cmd = player.cmd
		local pmo = player.mo
		local skin = pmo.skin

		if (cmd.buttons & BT_SPIN) then
			player["ze2_info"].crouching = true
		else
			-- if gap higher than player height 
			if (player.mo.ceilingz - player.mo.floorz) > player.height then
				if player["ze2_info"].crouching then
					if pmo.state == S_PLAY_CROUCH_ZE2 then
						if (player.speed/FU) then
							pmo.frame = A
							pmo.state = S_PLAY_WALK
						else
							pmo.frame = A
							pmo.state = S_PLAY_STND
						end
					end
				end
			
				player["ze2_info"].crouching = false
			else
				SetCrouchState(pmo)
			end
		end
		
		if P_IsObjectOnGround(player.mo) and player["ze2_info"].crouching then
			SetCrouchState(pmo)
		end
		
		cmd.buttons = $ & ~BT_SPIN
	end
end)

addHook("PlayerHeight", CrouchHeightHook)
addHook("PlayerCanEnterSpinGaps", CrouchHeightHook)