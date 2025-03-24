freeslot("sfx_zjump")
sfxinfo[sfx_zjump].caption = "Jump"
mobjinfo[MT_LHRT].forceknockback = 20*FRACUNIT
ZE2.JumpSprintFatigue = 17*FRACUNIT
ZE2.DefaultRubyCap = 25000;
ZE2.RubyStart = 500 -- the amount of rubies you start when you join a server

ZE2["default_ze2_info"] = {
	crouching = false,

	inventory_selection = 1,

	survivor_inventory_limit = 5,
	
	survivor_inventory = {
		ZE2:CopyItemFromID(ITEM_RED_RING)
	},

	weapondelay = 0,
	ghostmode = false,
	
	await_fire = false,
	
	reload = 0,
	
	fire_pressed = false,
	
	weaponprev_pressed = false,
	weaponnext_pressed = false,
	weaponkey_pressed = false,
	
	reload_pressed = false,
	
	vote_selection = 1,
	voted = false,
	vote_leftpressed = false,
	vote_rightpressed = false,
	
	shop_selection = 1,

	pregamemenu_type = 1, -- [1]: Character Select
	pregamemenu_lasttype = 1, -- [1]: Character Select
	pregamemenu_active = false,
	pregamemenu_intopmenu = false,
	pregamemenu_intopmenuanim = 0,
	pregamemenu_intopmenuanim_max = TICRATE/2,
	pregamemenu_leftpressed = false,
	pregamemenu_rightpressed = false, 
	pregamemenu_forwardpressed = false,
	pregamemenu_backwardspressed = false,
	pregamemenu_spinpressed = false,
	pregamemenu_jumppressed = false,
	
	charselect_selection = 1,
	charselect_prevselection = 1,
	charselect_selection_anim = 1,
	charselect_hold = 0,

	sprintmeter = 100*FU,
	isSprinting = false,
	sprintdelay = 0, -- x > 0 = sprintmeter wont increase

	team = 1,

	cash = ZE2.RubyStart,
	rubycap = ZE2.DefaultRubyCap,
	rubyqueue = 0,
	rubypickupdelay = 0,

	was_spectating = false,
	was_zombie = false,

	zombie_type = "normal",
	
	damage_fade = 0, -- tic_t
	damage_fade_max = 0,
	
	checkpoint_number = 0,
	checkpoint_catchuptics = 0, 
	
	lower_hud_offset = 0,
	special_cooldown = 0,

	zombie_shop_open = false,
	zombie_shop_selection = 1,
	zombie_shop_c1_pressed = false,
	zombie_next_type = nil,
	
	nofrictiontics = 0; 
	
	isSprung = false,
	
	damage_indicator_table = {},
	/*	damage_indicator_table
		[mobj_t] = {
			draw_x = (x),
			draw_y = (y),
			draw_z = (z),
			number = 100,
			tics_left = 35,
			damagenumbers = {list of mobjs},
			real_position = {x,y,z, scale, height, radius},
		}
	*/
	
	landfatigue = false,
	landfatigue_timer = 0,
	
	teamchat_enabled = false,
}

local width = 14
local cv_fov
local function GetFOV()
	if isdedicatedserver then 
		return 1 
	end
	
	if not cv_fov then
		cv_fov = CV_FindVar("fov")
	end

	return FixedDiv(cv_fov.value, 90*FU)
end

local function UpdateDamageNumbers(p, numbers, properties, damage)
	damage = tostring($)
	local str_len = string.len(damage)

	local scale = FixedDiv(R_PointToDist(properties.x,properties.y), properties.radius * 10)
	scale = max($, properties.scale * 2)
	scale = FixedMul($, GetFOV())
	scale = $/2

	local offset = FixedMul((str_len*width)*FU, scale) / 2
	
	local work = offset
	local angle = R_PointToAngle(properties.x,properties.y) - ANGLE_90

	/*
	do
		local test = P_SpawnMobj(
			properties.x + P_ReturnThrustX(nil, angle, work + (str_len*width*scale)),
			properties.x + P_ReturnThrustY(nil, angle, work + (str_len*width*scale)),
			properties.z + properties.height,
			MT_RAY
		)

		--try swapping the to the other side?
		if not P_CheckSight(test, p.mo) then
			angle = R_PointToAngle(properties.x,properties.y) + ANGLE_90
			work = -$
		end

		if (test and test.valid) then P_RemoveMobj(test) end
	end
	*/

	for i = 1,str_len do
		local n = string.sub(damage,i,i)
		local frame = tonumber(n)
		
		local num = numbers[i]
		if not (num and num.valid) then
			table.remove(numbers, i)
			continue
		end
		if (num.flags & MF_NOGRAVITY) then
			local offset = 0
			if properties.tics
				local animation = properties.animation
				if animation == i
				and not num.nu_anim
					num.nu_offset = 6*FU
					num.nu_anim = true
				else
					num.nu_offset = max($ - FixedDiv(6*FU, FU*3), 0)
				end
			end
			
			P_MoveOrigin(num,
				properties.x + P_ReturnThrustX(nil, angle, work),
				properties.y + P_ReturnThrustY(nil, angle, work),
				properties.z + properties.height + FixedMul((num.nu_offset or 0), scale)
			)
		end
		
		num.sprite = SPR_ZE2_DAMAGENUMBER
		num.frame = (frame)|FF_FULLBRIGHT
		num.scale = scale
		
		if num.fuse == TICRATE*2/3 then
			num.flags = $ &~MF_NOGRAVITY
			
			P_SetObjectMomZ(num, num.nu_momz)
			P_Thrust(num, angle, num.nu_thrust)
		end
		
		num.renderflags = $|RF_NOCOLORMAPS
		num.drawonlyforplayer = p
		num.dispoffset = 100
		
		work = $ + width*scale
	end

end

addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 then return end
	
	if player["ze2_info"] == nil then
		player["ze2_info"] = ZE2:Copy(ZE2["default_ze2_info"])
	end
	
	player["ze2_info"].lower_hud_offset = 0
	player["ze2_info"].special_cooldown = 0
	player["ze2_info"].effects = {}
	player["ze2_info"].damage_indicator_table = {}
end)

function ZE2:SetDamageFadeAnim(player, tics)
	player["ze2_info"].damage_fade = tics
	player["ze2_info"].damage_fade_max = tics
end

function ZE2:ChangeHealth(mobj, amount)
	if amount > mobj.maxhealth then
		mobj.health = mobj.maxhealth
	else
		mobj.health = $ + amount
	end
end

function ZE2:ChangeStamina(player, amount)
	if amount + player["ze2_info"].sprintmeter > 100*FRACUNIT then
		player["ze2_info"].sprintmeter = 100*FRACUNIT
	else
		player["ze2_info"].sprintmeter = $ + amount
	end
end

function ZE2:GivePlayerEffect(player, effect_name, effect_table, effect_time)
	if player["ze2_info"].effects and effect_name and effect_table and effect_time then
		local tbl = effect_table
		tbl.time_left = effect_time or 1-- tics
		
		player["ze2_info"].effects[effect_name] = tbl
	end
end

function ZE2:FindEffectAttributes(player, attribute)
	local tb = {}

	if player["ze2_info"].effects then
		for i,v in pairs(player["ze2_info"].effects) do
			if v[attribute] then
				table.insert(tb, v[attribute])
			end
		end
	end
	
	return tb
end

-- some stuff that player needs
ZE2.giveplayerflags = function(player)
	if gametype == GT_ZE2 then
		player.charflags = SF_NOJUMPSPIN|SF_NOJUMPDAMAGE|SF_NOSKID
		player.pflags = $ & ~PF_DIRECTIONCHAR
		
		if (player.pflags & PF_ANALOGMODE) then
			player.pflags = $ | PF_FORCESTRAFE
			player.pflags = $ & ~PF_ANALOGMODE
		else
			player.pflags = $ & ~PF_FORCESTRAFE
		end
		
		if not ZE2.round_active and player["ze2_info"].pregamemenu_active then
			if player.mo and player.mo.valid then
				player.mo.flags2 = $|MF2_DONTDRAW
			end
		end
		
		if player["ze2_info"].sprintmeter == nil then
			player["ze2_info"].sprintmeter = 100*FRACUNIT
		end
		
		if player["ze2_info"].sprintmeter < 0 then
			player["ze2_info"].sprintmeter = 0
		end

		player["ze2_info"].isSprinting = $ or false
		
		if player["ze2_info"].team == 1 then
			ZE2.SetCCtoplayer(player)
		elseif player["ze2_info"].team == 2 then
			ZE2.SetZCtoplayer(player)
		end
		
		if player["ze2_info"].effects then
			for i,v in pairs(player["ze2_info"].effects) do
				if v.normalspeed then
					player.normalspeed = v.normalspeed
				elseif v.normalspeed_multiplier then
					player.normalspeed = FixedMul($, v.normalspeed_multiplier)
				end
				
				if v.actionspd then
					player.actionspd = v.actionspd
				elseif v.actionspd_multiplier then
					player.actionspd = FixedMul($, v.actionspd_multiplier)
				end
				
				if v.charability then
					player.charability = v.charability
				end
				
				if v.time_left then
					if ZE2.Effects[i].thinker then
						ZE2.Effects[i].thinker(player, v.time_left)
					end
					
					v.time_left = $ - 1
					
					if not v.time_left then
						if ZE2.Effects[i].on_end then
							ZE2.Effects[i].on_end (player)
						end
						
						player["ze2_info"].effects[i] = nil
						continue
					end
				end
			end
		else
			player["ze2_info"].effects = {}
		end
		
		if player["ze2_info"].damage_indicator_table then
			for dmo,v in pairs(player["ze2_info"].damage_indicator_table) do
				
				if v.tics_left then
					
					if (dmo and dmo.valid) then
						v.real_position = {
							x = dmo.x,
							y = dmo.y,
							z = dmo.z,
							scale = dmo.scale,
							height = dmo.height,
							radius = dmo.radius,
							tics = v.tics_left,
							animation = v.animation,
						}
					end
					
					if (v.damagenumbers) then
						UpdateDamageNumbers(player, v.damagenumbers, v.real_position, v.number)
					end
					
					if v.tics_left & 1
						v.animation = $ + 1
					end
					
					v.tics_left = $ - 1
					if v.tics_left <= 0 then
						player["ze2_info"].damage_indicator_table[dmo] = nil
						continue
					end
				else
					player["ze2_info"].damage_indicator_table[dmo] = nil
					continue
				end
			end
		end
		
		if player["ze2_info"].landfatigue_timer then
			player["ze2_info"].landfatigue_timer = $ - 1
		end
		
		if player.mo and player.mo.valid then
			local pmo = player.mo
			
			if player["ze2_info"].landfatigue and (pmo.eflags & MFE_JUSTHITFLOOR) then
				player["ze2_info"].landfatigue = false
				player["ze2_info"].landfatigue_timer = $ + 20
			end
			
			ZE2.LimitMobjHealth(pmo)
		end
		
		if mapheaderinfo[gamemap].ze2_noabilities then
			player.pflags = $ & ~PF_GLIDING
			player.pflags = $ & ~PF_BOUNCING
			player.powers[pw_tailsfly] = 0
		end
	else 
		if leveltime < 2 then
			ZE2.RevertChars(player) 
		end
	end
end

function ZE2:DecrementSprint(player, value)
	local cc = ZE2.CharacterConfig
	local newsprintexhaust -- custom config value
	
	if cc[player.mo.skin] and cc[player.mo.skin].sprintexhaust then
		newsprintexhaust = cc[player.mo.skin].sprintexhaust
	end
	
	if player["ze2_info"].team ~= 1 then return end

	if player["ze2_info"].sprintmeter - abs(value) <= 0 then
		if newsprintexhaust ~= nil then
			player["ze2_info"].sprintdelay = abs(newsprintexhaust)
		else
			player["ze2_info"].sprintdelay = TICRATE*2 -- do default
		end
		
		player["ze2_info"].sprintmeter = 0
	else
		player["ze2_info"].sprintmeter = $ - abs(value)
	end
end

function ZE2:IncrementSprint(player, value)
	if player["ze2_info"].team ~= 1 then return end
	if player["ze2_info"].sprintdelay then return end
	
	if player["ze2_info"].sprintmeter + abs(value) >= 100*FRACUNIT then
		player["ze2_info"].sprintmeter = 100*FRACUNIT
	else
		player["ze2_info"].sprintmeter = $ + abs(value)
	end
end

-- sprint code
-- TODO: Sprinting is no longer in the game, so this thing needs to be reorganized for the new name and stuff.
ZE2.sprint_thinker = function(player)
	if not (player.mo and player.mo.valid) return end
	
	if (gametype ~= GT_ZE2) then return end
		
	local cmd = player.cmd
	
	local pmo = player.mo
	local cc = ZE2.CharacterConfig
	
	local increment = FRACUNIT/2
	local decrement = fixedfromstring("0.142")
	
	-- TODO: Make the sidemove limiting code cleaner, and modular.
	if not ZE2.sourcemovement.value
	and not player["ze2_info"].pregamemenu_active
	and not ZE2.game_ended then
		if cmd.forwardmove then
			if cmd.sidemove > 25 then
				cmd.sidemove = 25
			elseif cmd.sidemove < -25 then
				cmd.sidemove = -25
			end
		end
	end
	
	if player["ze2_info"].sprintdelay then
		if player["ze2_info"].sprintmeter then
			player["ze2_info"].sprintdelay = 0
		else
			player["ze2_info"].sprintdelay = $ - 1
		end
	elseif player["ze2_info"].sprintdelay < 0 then
		player["ze2_info"].sprintdelay = 0
	end
	
	if player["ze2_info"].team == 1 then
		if not player.climbing then
			if (player.speed/FU) > 12 then -- running
				if P_IsObjectOnGround(pmo) and not player["ze2_info"].crouching then
					--P_SpawnSkidDust(player, 20*FRACUNIT)
				end
				
				ZE2:IncrementSprint(player, increment/2)
				
				player.runspeed = 32000*FRACUNIT
			else
				if not (player.speed/FU) then -- not moving
					ZE2:IncrementSprint(player, increment*3)
				else -- moving but slower than running speed
					ZE2:IncrementSprint(player, increment)
				end
				
				player.runspeed = 32000*FRACUNIT
			end
		end
	end
	
	if cmd.buttons & BT_SPIN and player.powers[pw_tailsfly] then
		P_SetObjectMomZ(player.mo, -FRACUNIT/2, true)
	end
end

addHook("JumpSpecial", function(player)
	if gametype ~= GT_ZE2 then return end

	if player.mo and player.mo.valid and not (player.pflags & PF_THOKKED) and P_IsObjectOnGround(player.mo) then
		if (player.mo.ceilingz - player.mo.floorz) < player.height + ZE2.playerheightoffset
		and player["ze2_info"].crouching then
			return true
		end
		
		if not (player.pflags & PF_JUMPDOWN) then
			if player["ze2_info"].team == 1 then
				ZE2:DecrementSprint(player, ZE2.JumpSprintFatigue)
			end
			
			if ZE2.landingfatigue.value then
				player["ze2_info"].landfatigue = true
			end
		end
	end
end)

-- Limit character abilities. And side movement momentum for zombies
addHook("PlayerThink", function(player) 
	if gametype ~= GT_ZE2 then return end
    if player.mo and player.mo.valid then
		local cmd = player.cmd
		
        if player.climbing then
            ZE2:DecrementSprint(player, FRACUNIT)
			
			if not player["ze2_info"].sprintmeter then
				player.climbing = 0
				player.mo.state = S_PLAY_ROLL
			end
        end
		
		if player["ze2_info"].sprintmeter <= 0 then
			if (player.pflags & PF_GLIDING) then
				player.pflags = $ & ~PF_GLIDING
				player.mo.state = S_PLAY_ROLL
			end
			
			player.pflags = $ & ~PF_BOUNCING
			
			player.powers[pw_tailsfly] = 0
		end
		
		if player.powers[pw_tailsfly] then
			if not (player.speed/FU) then
				ZE2:DecrementSprint(player, FRACUNIT*3)
			else
				ZE2:DecrementSprint(player, 3*FRACUNIT/2)
			end
		end

		if player.glidetime then
			ZE2:DecrementSprint(player, (player.glidetime*FRACUNIT)/32)
		end
		
		if (player.pflags & PF_JUMPED) then
			player["ze2_info"].isJumping = true
		end
		
		if (player.mo.eflags & MFE_SPRUNG) then
			player["ze2_info"].isSprung = true
		end
		
		if P_IsObjectOnGround(player.mo) then
			if player["ze2_info"].isJumping then
				player["ze2_info"].isJumping = false
			end
			
			player["ze2_info"].isSprung = false
		end
		
		if player.pflags & PF_BOUNCING and player.mo.eflags & MFE_JUSTHITFLOOR and player.mo.health then
			player.mo.momz = 10*FRACUNIT * P_MobjFlip(player.mo)
		end 
		
		if player.mo.state == S_PLAY_BOUNCE_LANDING then
			ZE2:DecrementSprint(player, 3*FRACUNIT)
		end
    end
end)

ZE2.ResetPlayer = function(player, choosenewztype)
	if player["ze2_info"].team == 1 then
		ZE2.SetCCtoplayer(player)
		ZE2.SetCChealth(player)
		player["ze2_info"].zombie_type = "normal"
	elseif player["ze2_info"].team == 2 then
		ZE2.SetZCtoplayer(player)
		ZE2.SetZChealth(player)
		ZE2.SetZCscale(player)
		ZE2.SetZCinventory(player)
	end
end

ZE2.PlayZombieSound = function(player, being_infected)
	local infection_sounds
	
	if not being_infected then
		infection_sounds = {sfx_inf1, sfx_inf2}
	else
		infection_sounds = {sfx_inf3, sfx_inf4}
	end
	
	if player.mo and player.mo.valid then
		local soundrng = P_RandomRange(1,#infection_sounds)
		S_StartSound(player.mo,infection_sounds[soundrng])
	end
end

ZE2.ZombifyPlayer = function(player)
	player["ze2_info"].team = 2
	player["ze2_info"].zombie_type = "normal"
	
	ZE2.ResetPlayer(player)
end

ZE2.init_player = function(player)
	if gametype ~= GT_ZE2 and leveltime then return end
	
	local pmo = player.mo
	
	if player and pmo and pmo.valid then
		if (ZE2.round_active and ZE2.PlayerCount() > 1) then
			player["ze2_info"].team = 2
			player["ze2_info"].zombie_type = "normal"
			
			if ZE2.round_active and ZE2.PlayerCount() > 1 and leveltime then
				-- killedbysomething variable is to prevent players from suiciding to get a special zombie
				-- same goes for was_spectating
				if player["ze2_info"].zombie_next_type then
					player["ze2_info"].zombie_type = player["ze2_info"].zombie_next_type
					player["ze2_info"].zombie_next_type = nil
				else
					player["ze2_info"].zombie_type = "normal"
				end
				
				player["ze2_info"].killedbysomething = false
			end
			
			player["ze2_info"].zombie_shop_open = false
			
			player["ze2_info"].was_spectating = false
			
			P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
		else
			player["ze2_info"].team = 1
		end
		
		ZE2.ResetPlayer(player, true)

		if player["ze2_info"].team == 2 then 
			R_SetPlayerSkin(player, "zzombie") 
		end

		player["ze2_info"].sprintmeter = 100*FRACUNIT
	end
end

-- Zombie Spawn Sounds
addHook("PlayerSpawn", function(player)
	if ZE2.instantinfection.value then return end

	if player.mo and player.mo.valid and player["ze2_info"].team == 2 and ZE2.round_active and leveltime then
		ZE2.PlayZombieSound(player)
	end
end)

-- Jump Sound Replacement
addHook("MobjThinker", function(mobj)
	if gametype ~= GT_ZE2 then return end
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
	if nextplayer["ze2_info"].team ~= player["ze2_info"].team then
		return false
	end
end)

-- Disable special zombie types when unspectating
addHook("TeamSwitch", function(player, team, fromspectators)
	if fromspectators then
		player["ze2_info"].was_spectating = true
	
		if ZE2.round_active and not ZE2_game_ended then
			player["ze2_info"].pregamemenu_active = false
		end
	end
	
	-- NEVER have pregamemenu_active on as spectator
	if team == 0 then
		player["ze2_info"].pregamemenu_active = false
	end
end)

-- if you die you be zombie
addHook("MobjDeath", function(mobj)
	if ZE2.round_active and not ZE2_game_ended and 
	((ZE2.PlayerCount() > 1) or (mapheaderinfo[gamemap].ze2_solofail)) then
		mobj.player["ze2_info"].team = 2
	end
end,MT_PLAYER)

-- lock zombies color and prevent survivors from being zombie skin and vice versa
addHook("PlayerThink", function(player)	
	if gametype ~= GT_ZE2 or not player.mo return end
	
	local ztype = player["ze2_info"].zombie_type
	local zc = ZE2.ZombieConfig
	
	if player["ze2_info"].team == 2 and player.mo.skin ~= "zzombie" then
		R_SetPlayerSkin(player, "zzombie")
	elseif player["ze2_info"].team == 1 and player.mo.skin == "zzombie" then
		R_SetPlayerSkin(player, "sonic")
		player.mo.color = player.skincolor
	end
		
	if (player["ze2_info"].team == 2 and ztype and zc[ztype]) then 
		player.mo.color = zc[ztype].skincolor or SKINCOLOR_MOSS
	end
end)

COM_AddCommand("z_changeztype", function(player, new_ztype)
	if not (player.mo and player.mo.valid) then return end
	if player["ze2_info"].team ~= 2 then
		print("You must be a zombie to run this command.")
		return
	end
	
	if not new_ztype then
		print("z_changeztype <ztype>: changes your zombie type.")
		return
	end
	
	local zc = ZE2.ZombieConfig
	
	if zc[new_ztype] then
		player["ze2_info"].zombie_type = new_ztype
		ZE2.ResetPlayer(player)
	else
		print("Invalid ztype. "..'"'..new_ztype..'"')
	end
end, 1)

-- Alpha Zombie Rage, sort of hardcoded for the time being
addHook("PlayerThink", function(player)
	if not (player.mo and player.mo.valid) then return end
	if not (player["ze2_info"].team == 2 and player["ze2_info"].zombie_type == "alpha") then return end
	if player.playerstate ~= PST_LIVE then return end
	
	ZE2:TryBooleanAction(player, {
		condition = player.cmd.buttons & BT_CUSTOM2,
		var = "special_pressed",
		action = function()
			if not player["ze2_info"].special_cooldown then
				player["ze2_info"].special_cooldown = 25*TICRATE
				
				S_StartSound(player.mo, sfx_bstup)
				
				ZE2:GivePlayerEffect(player, "alphazombie.rage", {
					normalspeed_multiplier = 4*FU,
					actionspd_multiplier = 3*FU/2,
					damage_multiplier = 2*FU,
					charability = CA_JUMPTHOK,
				}, 3*TICRATE)
			end
		end
	}, true)
end)

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
	local cmd = player.cmd
		
	if player["ze2_info"] == nil then
		player["ze2_info"] = ZE2:Copy(ZE2["default_ze2_info"])
	end
	
	if not player["ze2_info"].zombie_inventory or not player["ze2_info"].zombie_inventory_limit then
		ZE2.SetZCinventory(player)
	end

	if player["ze2_info"].damage_fade and player["ze2_info"].damage_fade_max then
		player["ze2_info"].damage_fade = $ - 1
		
		if not player["ze2_info"].damage_fade then
			player["ze2_info"].damage_fade_max = 0
		end
	else
		player["ze2_info"].damage_fade = 0
		player["ze2_info"].damage_fade_max = 0
	end
	
	if player["ze2_info"].special_cooldown then
		player["ze2_info"].special_cooldown = $ - 1
	end
	
	if player.playerstate ~= PST_DEAD then
		if #ZE2:FetchInventory(player) > ZE2:FetchInventoryLimit(player) then
			table.remove(ZE2:FetchInventory(player),#ZE2:FetchInventory(player))
		end

		if player["ze2_info"].inventory_selection > ZE2:FetchInventoryLimit(player) then
			player["ze2_info"].inventory_selection = ZE2:FetchInventoryLimit(player)
		end
	end
	
	if player and not player.mo then return end
	
	if player["ze2_info"].nofrictiontics then
		player.mo.friction = FRACUNIT
		
		player["ze2_info"].nofrictiontics = max(0, $ - 1)
	end
	
	if player["ze2_info"].checkpoint_catchuptics then
		player["ze2_info"].checkpoint_catchuptics = $ - 1
		
		if not player["ze2_info"].checkpoint_catchuptics then
			ZE2.LatestCheckpointTeleport(player, true)
		end
	end
	
	-- decrement
	if player["ze2_info"].weapondelay then
		player["ze2_info"].weapondelay = $ - 1
	end
	
	if player["ze2_info"].reload and ZE2:FetchInventorySlot(player) then
		local skin = player.mo.skin
		local iteminfo = ZE2:FetchInventorySlot(player)
		local ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin)
		local max_ammo = ZE2:GetItemInfoIndex(iteminfo, "max_ammo", skin)
		
		player["ze2_info"].reload = $ - 1
		
		if player["ze2_info"].reload <= 0 then
			ZE2:SetItemInfoIndex(iteminfo, "ammo", max_ammo, skin)
			S_StartSound(player.mo, sfx_z_rel2)
		end
	end
	
	if not ZE2.game_ended and not player["ze2_info"].ghostmode and not ZE2.pregame_timeleft then 
		if not player["ze2_info"].pregamemenu_active then
			-- Next Weapon
			ZE2:TryBooleanAction(player, {
				condition = cmd.buttons & BT_WEAPONPREV,
				var = "weaponprev_pressed",
				action = function()
					if player["ze2_info"].inventory_selection - 1 <= 0 then
						player["ze2_info"].inventory_selection = ZE2:FetchInventoryLimit(player)
					else
						player["ze2_info"].inventory_selection = $ - 1
					end
					
					S_StartSound(nil,sfx_mnu1a,player)
					
					player["ze2_info"].reload = 0
				end
			}, true)

			-- Previous Weapon
			ZE2:TryBooleanAction(player, {
				condition = cmd.buttons & BT_WEAPONNEXT,
				var = "weaponnext_pressed",
				action = function()
					if player["ze2_info"].inventory_selection + 1 > ZE2:FetchInventoryLimit(player) then
						player["ze2_info"].inventory_selection = 1
					else
						player["ze2_info"].inventory_selection = $ + 1
					end

					S_StartSound(nil,sfx_mnu1a,player)
					
					player["ze2_info"].reload = 0
				end
			}, true)
			
			-- Number Key Weapon Swap (Pro Controls)
			if cmd.buttons & BT_WEAPONMASK then
				-- Dont do if on same slot as selected.
				if not ((cmd.buttons & BT_WEAPONMASK) == (player["ze2_info"].inventory_selection)) then 
					if cmd.buttons & BT_WEAPONMASK <= ZE2:FetchInventoryLimit(player) then
						player["ze2_info"].inventory_selection = cmd.buttons & BT_WEAPONMASK
						
						S_StartSound(nil,sfx_mnu1a,player)
						
						player["ze2_info"].reload = 0
					end
				end
			end
			
			-- Reload
			ZE2:TryBooleanAction(player, {
				condition = cmd.buttons & BT_FIRENORMAL,
				var = "reload_pressed",
				action = function()
					ZE2.DoPlayerReload(player)
				end
			}, true)
			
			-- Fire
			ZE2:TryBooleanAction(player, {
				condition = cmd.buttons & BT_ATTACK,
				var = "fire_pressed",
				action = function()
					player["ze2_info"].await_fire = true
				end
			}, true)
		end
		
		-- try shoot
		local iteminfo = ZE2:FetchInventorySlot(player)
		local skin = player.mo.skin
		
		if (cmd.buttons & BT_ATTACK) and not player["ze2_info"].weapondelay and not player["ze2_info"].reload
		and iteminfo and player.playerstate ~= PST_DEAD and not player["ze2_info"].shop_open 
		and (player["ze2_info"].await_fire or iteminfo.autouse)
		and not iteminfo.firerate_left and not (ZE2.zombie_releasetime and player["ze2_info"].team == 2) then
			local ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin)
			local max_ammo = ZE2:GetItemInfoIndex(iteminfo, "max_ammo", skin)
			local count = ZE2:GetItemInfoIndex(iteminfo, "count", skin)
			local limited = ZE2:GetItemInfoIndex(iteminfo, "limited", skin)
			local firerate = ZE2:GetItemInfoIndex(iteminfo, "firerate", skin)
			local itemdelay = ZE2:GetItemInfoIndex(iteminfo, "itemdelay", skin)
			
			-- If theres no ammo, dont fire. 
			-- (Items with no ammo property can pass this check 100%)
			if ammo ~= nil and ammo <= 0 and not player["ze2_info"].reload then
				ZE2.DoPlayerReload(player)
			else
				if ammo ~= nil and max_ammo and ammo > 0 then
					ZE2:SetItemInfoIndex(iteminfo, "ammo", ammo - 1, skin)
					ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin) -- get updated ammo
					
					-- Auto Reload
					if ammo <= 0 then
						ZE2.DoPlayerReload(player)
					end
				end
			
				ZE2.DoPlayerFire(player, iteminfo)

				player["ze2_info"].weapondelay = itemdelay
				
				if firerate then
					ZE2:SetItemInfoIndex(iteminfo, "firerate_left", firerate, skin)
				end
				
				player["ze2_info"].await_fire = false
				
				if count ~= nil and limited == true then
					if count > 0  then
						ZE2:SetItemInfoIndex(iteminfo, "count", count - 1, skin)
					end
				end
			end
		end	
		
		-- clear items below 0 count
		if ZE2:FetchInventoryLimit(player) and type(ZE2:FetchInventoryLimit(player)) == "number" then
			for i=1,ZE2:FetchInventoryLimit(player) do
				local slot = ZE2:FetchInventorySlot(player, i)
				
				if slot then
					if slot.limited and slot.count <= 0 then
						table.remove(ZE2:FetchInventory(player), i)
					end
					
					if slot.firerate_left then
						slot.firerate_left = $ - 1
					end
				end
			end
		end
	end	
	
	--source movement?
	if ZE2.sourcemovement.value and FixedHypot(player.cmd.forwardmove * 1311, player.cmd.sidemove * 1311) and not player["ze2_info"].pregamemenu_active 
	and CanPlayerMove(player) then
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

		if player["ze2_info"].sprintdelay and not P_IsObjectOnGround(pmo) then
			L_SpeedCapXY(pmo, FixedMul(max(movespd, wishspd), pmo.scale))
		elseif not P_IsObjectOnGround(pmo) then
			L_SpeedCapXY(pmo, FixedMul(max(movespd, 22*FRACUNIT), pmo.scale))
		end

		pmo.momx = $ + cx
		pmo.momy = $ + cy
	end

	player["ze2_info"].lower_hud_offset = 0
end)