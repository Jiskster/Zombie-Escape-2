/*
Credits for MotdSpork and his Modern Sonic mod that inspired me to make this script.
I based this script on their code and reused the sound resources.
*/

--Edited by GLide KS for minecraft map

freeslot(
//Minecraft
"sfx_migr1", "sfx_migr2", "sfx_migr3", "sfx_migr4", "sfx_migr5", "sfx_migr6",
"sfx_mico1", "sfx_mico2", "sfx_mico3", "sfx_mico4", "sfx_mico5", "sfx_mico6",
"sfx_midi1", "sfx_midi2", "sfx_midi3", "sfx_midi4",
"sfx_misn1", "sfx_misn2", "sfx_misn3", "sfx_misn4",
"sfx_micl1", "sfx_micl2", "sfx_micl3", "sfx_micl4",
"sfx_misa1", "sfx_misa2", "sfx_misa3", "sfx_misa4", "sfx_misa5",
"sfx_miwh1", "sfx_miwh2", "sfx_miwh3", "sfx_miwh4", "sfx_miwh5", "sfx_miwh6",
"sfx_miwl1", "sfx_miwl2", "sfx_miwl3", "sfx_miwl4", "sfx_miwl5", "sfx_miwl6",
"sfx_miwa1", "sfx_miwa2", "sfx_miwa3", "sfx_miwa4",
"sfx_mila1", "sfx_mila2", "sfx_mila3", "sfx_mila4"
)

if not SoundListInfo then
	rawset(_G, "SoundListInfo", {})
end

if not PlayerAnimInfo then
	rawset(_G, "PlayerAnimInfo", {})
end

local soundinfolist = {
	["minecraft"] = {
		["grass"] = {
		  ["steps"] = {sfx_migr1, sfx_migr2, sfx_migr3, sfx_migr4, sfx_migr5, sfx_migr6},
		  ["land"] = {sfx_migr1, sfx_migr2, sfx_migr3, sfx_migr4, sfx_migr5, sfx_migr6}
		},
		["metal_heavy"] = {
		  ["steps"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6},
		  ["land"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6}
		},
		["metal_light"] = {
		  ["steps"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6},
		  ["land"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6}
		},
		["dirt"] = {
		  ["steps"] = {sfx_midi1, sfx_midi2, sfx_midi3, sfx_midi4},
		  ["land"] = {sfx_midi1, sfx_midi2, sfx_midi3, sfx_midi4}
		},
		["snow"] = {
		  ["steps"] = {sfx_misn1, sfx_misn2, sfx_misn3, sfx_misn4},
		  ["land"] = {sfx_misn1, sfx_misn2, sfx_misn3, sfx_misn4}
		},
		["cloth"] = {
		  ["steps"] = {sfx_micl1, sfx_micl2, sfx_micl3, sfx_micl4},
		  ["land"] = {sfx_micl1, sfx_micl2, sfx_micl3, sfx_micl4}
		},
		["sand"] = {
		  ["steps"] = {sfx_misa1, sfx_misa2, sfx_misa3, sfx_misa4, sfx_misa5},
		  ["land"] = {sfx_misa1, sfx_misa2, sfx_misa3, sfx_misa4, sfx_misa5}
		},
		["wood_heavy"] = {
		  ["steps"] = {sfx_miwh1, sfx_miwh2, sfx_miwh3, sfx_miwh4, sfx_miwh5, sfx_miwh6},
		  ["land"] = {sfx_miwh1, sfx_miwh2, sfx_miwh3, sfx_miwh4, sfx_miwh5, sfx_miwh6}
		},
		["wood_light"] = {
		  ["steps"] = {sfx_miwl1, sfx_miwl2, sfx_miwl3, sfx_miwl4, sfx_miwl5, sfx_miwl6},
		  ["land"] = {sfx_miwl1, sfx_miwl2, sfx_miwl3, sfx_miwl4, sfx_miwl5, sfx_miwl6}
		},
		["concrete"] = {
		  ["steps"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6},
		  ["land"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6}
		},
		["water"] = {
		  ["steps"] = {sfx_miwa1, sfx_miwa2, sfx_miwa3, sfx_miwa4},
		  ["land"] = {sfx_miwa1, sfx_miwa2, sfx_miwa3, sfx_miwa4}
		},
		["lava"] = {
		  ["steps"] = {sfx_mila1, sfx_mila2, sfx_mila3, sfx_mila4},
		  ["land"] = {sfx_mila1, sfx_mila2, sfx_mila3, sfx_mila4}
		},
		["glass"] = {
		  ["steps"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6},
		  ["land"] = {sfx_mico1, sfx_mico2, sfx_mico3, sfx_mico4, sfx_mico5, sfx_mico6}
		}
	}
}

for soundlist, soundinfo in pairs(soundinfolist) do
	SoundListInfo[soundlist] = soundinfo
end

local flatsounds = {
	["MCCBLWL"] = "concrete",
	["MCCHSFL"] = "wood_light",
	["MCCOAL"] = "concrete",
	["MCDIRT"] = "dirt",
	["MCDMD"] = "concrete",
	["MCGLASS"] = "glass",
	["MCGLD"] = "concrete",
	["MCGLWST"] = "glass",
	["MCGRFL"] = "grass",
	["MCIRN"] = "concrete",
	["MCLVS"] = "grass",
	["MCOBSD"] = "concrete",
	["MCOWDFL"] = "wood_heavy",
	["MCSNDFL"] = "sand",
	["MCSTMWL"] = "concrete",
	["MCSTNWL"] = "concrete",
	["MCNTRCK"] = "concrete",
	["MCPLNWL"] = "wood_heavy"
}

local playeraniminfo = {
	["runFrames"] = {0, 2},
	["dashFrames"] = {-1},
	["walkFrames"] = {3, 7},
	["waitFrames"] = {0},
	["milnekickFrames"] = {0, 4},
	["run"] = true,
	["dash"] = false,
	["walk"] = true,
	["idle"] = true,
	["wait"] = false,
	["milnekick"] = true,
	["superRun"] = false,
	["superDash"] = false,
	["superWalk"] = true,
	["superIdle"] = true,
	["superWait"] = false
}

for skin, animinfo in pairs(playeraniminfo) do
	PlayerAnimInfo[skin] = animinfo
end

local function valid(mo)
	return mo and mo.valid
end

local function reset(player)
	if player.mo and player.mo.valid then
		player.lastframe = 0
		player.lastanim = nil
		player.playsound = false
		player.wasfalling = false
		player.variablesset = true
		player.groundtexture = nil
		player.lastgroundtexture = nil

		local soundListData = SoundListInfo["minecraft"]
		player.soundList = soundListData
	end
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function getGroundTexture(mo)
    local result = nil

    if mo.eflags & MFE_VERTICALFLIP then
		if mo.ceilingrover then
			result = mo.ceilingrover.bottompic
        elseif mo.standingslope and mo.standingslope == mo.subsector.sector.c_slope then
            result = mo.subsector.sector.ceilingpic
        elseif mo.ceilingz == mo.subsector.sector.ceilingheight then
            result = mo.subsector.sector.ceilingpic
		end
    else
        if mo.floorrover then
            result = mo.floorrover.toppic
		elseif mo.standingslope and mo.standingslope == mo.subsector.sector.f_slope then
            result = mo.subsector.sector.floorpic
        elseif mo.floorz == mo.subsector.sector.floorheight then
			result = mo.subsector.sector.floorpic
        end
	end

	return result
end

addHook("PlayerThink", function(player)
	if gamemap ~= 08 then return end
	if player.mo and player.mo.state ~= S_PLAY_DEAD then
		local panimInfo = PlayerAnimInfo
		--if panimInfo ~= nil
			if player.variablesset == nil then
				reset(player)
			end
			player.groundtexture = getGroundTexture(player.mo)
			if player.groundtexture == nil and player.lastgroundtexture then
				player.groundtexture = player.lastgroundtexture
			end
			local material
			local soundType
			player.playsound = false
			if P_IsObjectOnGround(player.mo) then
				if not(player.wasfalling) then
					if player.skidtime == 16 then
						player.playsound = true
						soundType = "skid"
					elseif not (player.powers[pw_carry]) then
						if player.milnecarry then
							if player.mo.state == S_PLAY_WALK then
								player.playsound = panimInfo["run"] and (player.powers[pw_super] == 0 or panimInfo["superRun"]) and (has_value(panimInfo["runFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["runFrames"], player.mo.frame))
							elseif player.mo.state == S_PLAY_FLY or player.mo.state == S_PLAY_SWIM then
								player.playsound = panimInfo["walk"] and (player.powers[pw_super] == 0 or panimInfo["superWalk"]) and (has_value(panimInfo["walkFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["walkFrames"], player.mo.frame))
							elseif player.mo.state == S_PLAY_GLIDE_LANDING then
								player.playsound = panimInfo["idle"] and (player.powers[pw_super] == 0 or panimInfo["superIdle"]) and player.lastanim ~= player.panim
							end
						else
							if player.mo.state == S_PLAY_RUN then
								player.playsound = panimInfo["run"] and (player.powers[pw_super] == 0 or panimInfo["superRun"]) and (has_value(panimInfo["runFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["runFrames"], player.mo.frame))
							elseif player.mo.state == S_PLAY_DASH then
								player.playsound = panimInfo["dash"] and (player.powers[pw_super] == 0 or panimInfo["superDash"]) and (has_value(panimInfo["dashFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["dashFrames"], player.mo.frame))
							elseif player.mo.state == S_PLAY_WALK then
								player.playsound = panimInfo["walk"] and (player.powers[pw_super] == 0 or panimInfo["superWalk"]) and (has_value(panimInfo["walkFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["walkFrames"], player.mo.frame))
							elseif player.mo.state == S_PLAY_STND or player.mo.state == S_PLAY_EDGE then
								player.playsound = panimInfo["idle"] and (player.powers[pw_super] == 0 or panimInfo["superIdle"]) and player.lastanim ~= player.panim
							elseif player.mo.state == S_PLAY_WAIT then
								player.playsound = panimInfo["wait"] and (player.powers[pw_super] == 0 or panimInfo["superWait"])  and (has_value(panimInfo["waitFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["waitFrames"], player.mo.frame))
							elseif player.milnekick and player.mo.state == S_MILNE_KICK then
								player.playsound = panimInfo["milnekick"] and (has_value(panimInfo["milnekickFrames"], player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo["milnekickFrames"], player.mo.frame))
							end
						end

						soundType = "steps"
						player.playsound = player.playsound and player.lastframe ~= player.mo.frame
						player.lastframe = player.mo.frame
						player.lastanim = player.panim
					end
				else
					player.wasfalling = false
					player.playsound = true
					soundType = "land"
				end
			else
				player.wasfalling = true
			end

			if player.playsound then
				if not (player.mo.eflags & MFE_GOOWATER) then
					if player.groundtexture then
						material = flatsounds[player.groundtexture]
					else
						material = "concrete"
					end
					if material ~= nil then
						player.lastgroundtexture = player.groundtexture
						local sounds = player.soundList[material][soundType]
						if sounds ~= nil then
							S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
						end
					end
				end
				if (player.mo.eflags & MFE_TOUCHLAVA) then
					local sounds = player.soundList["lava"][soundType]
					if sounds ~= nil then
						S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
					end
				elseif (player.mo.eflags & MFE_UNDERWATER) or (player.mo.eflags & MFE_TOUCHWATER) or (player.mo.eflags & MFE_GOOWATER) then
					local sounds = player.soundList["water"][soundType]
					if sounds ~= nil then
						S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
					end
				end
			end
	end
end)