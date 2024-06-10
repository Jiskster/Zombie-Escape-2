freeslot("sfx_zjump")
sfxinfo[sfx_zjump].caption = "Jump"
mobjinfo[MT_LHRT].forceknockback = 20*FRACUNIT
ZE2.JumpSprintFatigue = 15*FRACUNIT
ZE2.DefaultRubyCap = 250;

ZE2["default_ze2_info"] = {
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
	
	reload_pressed = false,
	
	vote_selection = 1,
	voted = false,
	vote_leftpressed = false,
	vote_rightpressed = false,
	
	shop_selection = 1,
	shop_leftpressed = false,
	shop_rightpressed = false,
	shop_selectpressed = false,
	shop_exitpressed = false,
	shop_confirmscreen = false,
	shop_open = false,
	shop_anim = 0,

	charselect_choosing = false,
	charselect_selection = 1,
	charselect_prevselection = 1,
	charselect_selection_anim = 1,
	charselect_leftpressed = false,
	charselect_rightpressed = false, 

	sprintmeter = 100*FU,
	isSprinting = false,

	team = 1,

	rubies = 0,
	rubycap = ZE2.DefaultRubyCap,
	rubyqueue = 0,
	rubypickupdelay = 0,

	was_spectating = false,
	was_zombie = false,

	zombie_type = "normal",
}

addHook("PlayerSpawn", function(player)
	if gametype ~= GT_ZE2 then return end
	
	if player["ze2_info"] == nil then
		player["ze2_info"] = ZE2:Copy(ZE2["default_ze2_info"])
	end
end)

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

-- some stuff that player needs
ZE2.giveplayerflags = function(player)
	if gametype == GT_ZE2 then
		player.charflags = SF_NOJUMPSPIN|SF_NOJUMPDAMAGE|SF_NOSKID
		player.pflags = $ & ~PF_DIRECTIONCHAR
		player.pflags = $ & ~PF_ANALOGMODE 
		
		if not ZE2.round_active and player["ze2_info"].charselect_choosing then
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
	if player["ze2_info"].sprintmeter - abs(value) <= 0 then
		player["ze2_info"].sprintmeter = 0
	else
		player["ze2_info"].sprintmeter = $ - abs(value)
	end
end

function ZE2:IncrementSprint(player, value)
	if player["ze2_info"].sprintmeter + abs(value) >= 100*FRACUNIT then
		player["ze2_info"].sprintmeter = 100*FRACUNIT
	else
		player["ze2_info"].sprintmeter = $ + abs(value)
	end
end

-- sprint code
ZE2.sprint_thinker = function(player)
	if not (player.mo and player.mo.valid) return end
		
	local cmd = player.cmd
	
	local pmo = player.mo
	local cc = ZE2.CharacterConfig
	
	local increment = FRACUNIT/4
	local decrement = FRACUNIT/3
	
	if player["ze2_info"].team == 1 then
		if P_GetPlayerControlDirection(player) == 1 and (cmd.buttons & BT_SPIN) then
			
			ZE2:DecrementSprint(player, decrement)
			
			player["ze2_info"].isSprinting = true

			-- Running Animation
			if player["ze2_info"].sprintmeter == 0 then
				player.runspeed = 32000*FRACUNIT
			else
				player.runspeed = 5*FRACUNIT
				if player.speed >= 5*FRACUNIT and P_IsObjectOnGround(pmo) then
					P_SpawnSkidDust(player, 20*FRACUNIT)
				end
			end
		else
			ZE2:IncrementSprint(player, increment)
			
			player["ze2_info"].isSprinting = false
			
			-- Force Walking Animation
			player.runspeed = 32000*FRACUNIT
		end
	else
		player["ze2_info"].isSprinting = false
	end
	
	cmd.buttons = $ & ~BT_SPIN
end

addHook("JumpSpecial", function(player)
	if player.mo and player.mo.valid and player["ze2_info"].isSprinting and P_IsObjectOnGround(player.mo) then
		if player["ze2_info"].sprintmeter - ZE2.JumpSprintFatigue <= 0 then
			player["ze2_info"].sprintmeter = 0
			return true
		else
			player["ze2_info"].sprintmeter = $ - ZE2.JumpSprintFatigue
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
	if gametype ~= GT_ZE2 then return end
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

ZE2.init_player = function(player)
	if gametype ~= GT_ZE2 and leveltime then return end
	
	local pmo = player.mo
	
	if player and pmo and pmo.valid then
		if (ZE2.round_active and ZE2.PlayerCount() > 1) then
			player["ze2_info"].team = 2
			player["ze2_info"].zombie_type = "normal"
			if ZE2.round_active and ZE2.PlayerCount() > 1 and leveltime then
				if P_RandomChance(FRACUNIT/5) and not player["ze2_info"].was_spectating then
					player["ze2_info"].zombie_type = "alpha"
				end
			end
			
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
	local spawnsounds = {sfx_inf1,sfx_inf2}
	if player.mo and player.mo.valid and player["ze2_info"].team == 2 and ZE2.round_active and leveltime then
		local soundrng = P_RandomRange(1,#spawnsounds)
		S_StartSound(player.mo,spawnsounds[soundrng])
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
			player["ze2_info"].charselect_choosing = false
		end
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

addHook("PreThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	for player in players.iterate do
		local cmd = player.cmd
		
		if player["ze2_info"] == nil then
			player["ze2_info"] = ZE2:Copy(ZE2["default_ze2_info"])
		end
		
		if not player["ze2_info"].zombie_inventory or not player["ze2_info"].zombie_inventory_limit then
			ZE2.SetZCinventory(player)
		end
		
		if player.playerstate ~= PST_DEAD then
			if #ZE2:FetchInventory(player) > ZE2:FetchInventoryLimit(player) then
				table.remove(ZE2:FetchInventory(player),#ZE2:FetchInventory(player))
			end

			if player["ze2_info"].inventory_selection > ZE2:FetchInventoryLimit(player) then
				player["ze2_info"].inventory_selection = ZE2:FetchInventoryLimit(player)
			end
		end
		
		if player and not player.mo then continue end
		
		-- decrement
		if player["ze2_info"].weapondelay then
			player["ze2_info"].weapondelay = $ - 1
		end
		
		if player["ze2_info"].reload and ZE2:FetchInventorySlot(player) then
			local iteminfo = ZE2:FetchInventorySlot(player)
			
			player["ze2_info"].reload = $ - 1
			
			if player["ze2_info"].reload <= 0 then
				iteminfo.ammo = iteminfo.max_ammo
				S_StartSound(player.mo, sfx_z_rel2)
			end
		end
		
		if not ZE2.game_ended and not player["ze2_info"].ghostmode then 
			if not player["ze2_info"].charselect_choosing then
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
			if (cmd.buttons & BT_ATTACK) and not player["ze2_info"].weapondelay and not player["ze2_info"].reload
			and ZE2:FetchInventorySlot(player) and player.playerstate ~= PST_DEAD and not player["ze2_info"].shop_open 
			and (player["ze2_info"].await_fire or ZE2:FetchInventorySlot(player).autouse) then	
				local iteminfo = ZE2:FetchInventorySlot(player)
				
				-- If theres no ammo, dont fire. 
				-- (Items with no ammo property can pass this check 100%)
				if not (iteminfo.ammo ~= nil and iteminfo.ammo == 0) then
					ZE2.DoPlayerFire(player, iteminfo)

					player["ze2_info"].weapondelay = iteminfo.firerate
					
					player["ze2_info"].await_fire = false
					
					if iteminfo.count ~= nil and iteminfo.limited == true then
						if iteminfo.count > 0  then
							iteminfo.count = $ - 1
						end
					end
				end
				
				if iteminfo.ammo ~= nil then
					if iteminfo.ammo > 0 then
						iteminfo.ammo = $ - 1
					end
					
					-- Auto Reload
					if iteminfo.ammo <= 0 and not player["ze2_info"].reload then
						ZE2.DoPlayerReload(player)
					end
				end
			end	
			
			-- clear items below 0 count
			if ZE2:FetchInventoryLimit(player) and type(ZE2:FetchInventoryLimit(player)) == "number" then
				for i=1,ZE2:FetchInventoryLimit(player) do
					if ZE2:FetchInventory(player)[i] then
						if ZE2:FetchInventory(player)[i].limited and ZE2:FetchInventory(player)[i].count <= 0 then
							table.remove(ZE2:FetchInventory(player),i)
						end
					end
				end
			end
		end
	end
end)