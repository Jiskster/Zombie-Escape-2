-- Fang's Cork Bullet
mobjinfo[MT_CORK].forcedamage = 10
mobjinfo[MT_CORK].forceknockback = 20*FU

-- Amy's Hammer Hearts
mobjinfo[MT_LHRT].forcedamage = 3
mobjinfo[MT_LHRT].forceknockback = 8*FU

ZE2.LimitMobjHealth = function(mobj)
	if mobj and mobj.valid then
		if mobj.health and mobj.maxhealth then
			if mobj.health > mobj.maxhealth then
				mobj.health = mobj.maxhealth
			end
		end
	end
end

function ZE2.KillMobj(mo, inf, src, damagetype)
	if mo.player and mo.player.valid then
		local player = mo.player 
		local ztype = player.ztype
		
		if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
			local killaward = ZE2.ZombieConfig[ztype].killaward
			A_RubyDrop(mo, killaward)
		end
	end
	
	P_KillMobj(mo, inf, src, damagetype)
end

-- Always return false
addHook("ShouldDamage", function(mo, inf, src, dmg, damagetype)
	if (gametype ~= GT_ZE2) return end
	if ZE2.game_ended then return false end
	
	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)
	
	local knockback = 0
	local verticalknockback = 0
	local relativeknockback = false
	
	if inf and inf.player and mo and mo.player then
		if mo.player.zteam == inf.player.zteam then
			return false
		end
	end
	
	if src and src.player and mo and mo.player then
		if mo.player.zteam == src.player.zteam then
			return false
		end
	end
	
	-- Don't damage objects that are the same team.
	if mo.mobjteam and inf.mobjteam and mo.mobjteam == inf.mobjteam then
		return false
	end

	if mo.player then
		if mo.player.powers[pw_flashing] then
			return false
		end
		
		mo.player.shop_open = false
		mo.player.shop_anim = 0
	end
	
	if inf then
		if inf and inf.info.forcedamage then
			dmg = inf.info.forcedamage
		end
		
		if inf.info.forceknockback then
			knockback = inf.info.forceknockback
		end
		
		-- Knocks back angle between two objects instead of pushing backwards of attacker object
		if inf.info.relativeknockback then
			relativeknockback = true
		end
		
		if inf.info.forceverticalknockback then
			verticalknockback = inf.info.forceverticalknockback
		end
		
		if inf.forcedamage ~= nil then
			dmg = inf.forcedamage
		end
		
		if inf.forceknockback ~= nil then
			knockback = inf.forceknockback
		end
		
		if inf.iteminfo and ZE2.ItemPresets[inf.iteminfo.item_id] and ZE2.ItemPresets[inf.iteminfo.item_id].onhit and (inf.target or src) then
			if inf.target then
				ZE2.ItemPresets[inf.iteminfo.item_id].onhit(inf.target, mo, inf)
			elseif src then
				ZE2.ItemPresets[inf.iteminfo.item_id].onhit(src, mo, inf)
			end
		end
	end
	
	if (inf and inf.player) then 
		P_AddPlayerScore(inf.player, dmg)
	elseif (src and src.player) then 
		P_AddPlayerScore(src.player, dmg) 
	end
	
	-- DIE NOW
	if mo.health - dmg <= 0 or deathdamagetype then
		ZE2.KillMobj(mo, inf, src, damagetype)
		return false
	end
	
	if mo.player then
		if mo.player.zteam == 1 then
			mo.player.powers[pw_flashing] = ZE2.survinvtics.value
			P_FlashPal(mo.player, PAL_NUKE, 2)
			S_StartSound(mo, sfx_s3kb9)
			
			if inf and inf.valid then
				if not relativeknockback then
					P_Thrust(mo, inf.angle, knockback)
				else
					local r_angle = R_PointToAngle2(mo.x, mo.y, inf.x, inf.y)
					
					P_Thrust(mo, r_angle - ANGLE_180, knockback)
				end
				
				if verticalknockback then
					P_SetObjectMomZ(mo, verticalknockback, true)
				end
			end
		elseif mo.player.zteam == 2 then
			local zombie_hurtsounds = {
				sfx_zpa1,
				sfx_zpa2,
			}
			local chosen_hurtsound = zombie_hurtsounds[P_RandomRange(1,2)]
			
			if not relativeknockback then
				P_Thrust(mo, inf.angle, knockback)
			else
				local r_angle = R_PointToAngle2(mo.x, mo.y, inf.x, inf.y)
				
				P_Thrust(mo, r_angle - ANGLE_180, knockback)
			end
		
			if verticalknockback then
				P_SetObjectMomZ(mo, verticalknockback, true)
			end
			
			S_StartSound(mo, chosen_hurtsound)
		end
	elseif mobjinfo[mo.type].npc_name then
		if (not mo.target) and (inf or src.player) then --enemies wake up if you hit them from behind
			mo.target = src
			mo.state = mo.info.seestate
		end

		if mobjinfo[mo.type].painsound and mobjinfo[mo.type].painsound ~= sfx_None then
			S_StartSound(mo,mobjinfo[mo.type].painsound)
		end
		
		if inf and inf.valid then
			P_Thrust(mo, inf.angle, knockback)
		end
	end

	if mo.rubiesholding and (mo.rubiesholding - (mo.rubiesholding/3)) > 0 then
		 A_RubyDrop(mo, mo.rubiesholding/3)
		 mo.rubiesholding = $ - mo.rubiesholding/3
	end
	
	mo.health = $ - dmg -- fake damage i guess
	
	return false
end)

--ram into players as zombie
/*
addHook("MobjMoveCollide", function(thing,tmthing)
	if (gametype ~= GT_ZE2) return end
	if (ZE2.game_ended) then return end
	if L_ZCollide(thing,tmthing) and tmthing.player and tmthing.player.zteam == 2 and thing.player
	and thing.player.zteam ~= 2 then
		local speed1 = FixedHypot(FixedHypot(tmthing.momx, tmthing.momy), tmthing.momz)
		local speed2 = FixedHypot(FixedHypot(thing.momx, thing.momy), thing.momz)
		
		if speed1 > speed2 and tmthing.player and tmthing.player.valid
		and not tmthing.player.powers[pw_flashing] then
			P_DamageMobj(thing, tmthing, tmthing, 15)
		end
	end
end)
*/

addHook("MobjSpawn", function(mobj)
	if gametype ~= GT_ZE2 then return end
	if mobjinfo[mobj.type].npc_name then
		if mobjinfo[mobj.type].spawnhealth and type(mobjinfo[mobj.type].npc_spawnhealth) == "table" then
			local rng_health = P_RandomRange(mobjinfo[mobj.type].npc_spawnhealth[1],mobjinfo[mobj.type].npc_spawnhealth[2])
			mobj.health = rng_health
			mobj.maxhealth = mobj.health
		else
			mobj.maxhealth = mobj.health
		end
	end
end)

function ZE2.DoPlayerFire(player, iteminfo)
	local ring
	
	if not ZE2.ItemPresets[iteminfo.item_id] then
		return
	end
	
	if ZE2.game_ended or player.choosing then 
		return
	end

	if iteminfo.object then
		ring = P_SPMAngle(player.mo, iteminfo.object, player.mo.angle, 1, iteminfo.flags2)
	end
	
	if ZE2.ItemPresets[iteminfo.item_id].ontrigger and ZE2.ItemPresets[iteminfo.item_id].ontrigger(player,iteminfo) == true then
		return
	end
	
	if ZE2.ItemPresets[iteminfo.item_id].shake then
		local shake = ZE2.ItemPresets[iteminfo.item_id].shake
		if splitscreen or player == displayplayer then
			P_StartQuake(shake * FRACUNIT, 7)
		end
	end
	
	if iteminfo.sound then
		S_StartSound(player.mo, iteminfo.sound)
	end

	if ring then
		ring.shotbyplayer = true
		
		ring.mobjteam = tonumber(player.zteam)
		
		if iteminfo.color ~= nil then
			ring.color = iteminfo.color
		end 
		
		if iteminfo.fuse ~= nil then
			ring.fuse = iteminfo.fuse
		end
		
		if iteminfo.damage ~= nil then
			ring.forcedamage = iteminfo.damage
		end
		
		if iteminfo.knockback ~= nil then
			ring.forceknockback = iteminfo.knockback
		end

		if ZE2.ItemPresets[iteminfo.item_id].onspawn then
			ZE2.ItemPresets[iteminfo.item_id].onspawn(ring.target,ring,iteminfo)
		end
		
		local temp_iteminfo = ZE2:Copy(iteminfo)

		-- destroy functions on fire just in case
		temp_iteminfo.onspawn = nil
		temp_iteminfo.ontrigger = nil
		temp_iteminfo.onhit = nil

		ring.iteminfo = temp_iteminfo
	end
end

function ZE2.DoPlayerReload(player)
	local iteminfo = ZE2:FetchInventorySlot(player)
	if iteminfo and iteminfo.reload_time and not player["ze2_info"].reload then
		if iteminfo.ammo ~= iteminfo.max_ammo then
			player["ze2_info"].reload = iteminfo.reload_time or 2*TICRATE
			S_StartSound(player.mo, sfx_z_rel1)
		end
	end
end

addHook("PreThinkFrame", function()
	if gametype ~= GT_ZE2 then return end
	for player in players.iterate do
		local cmd = player.cmd
		player["ze2_info"] = $ or {
			inventory_selection = 1,

			survivor_inventory_limit = 5,
			
			survivor_inventory = {
				ZE2:CopyItemFromID(ITEM_RED_RING)
			},

			weapondelay = 0,
			ghostmode = false,
			
			await_fire = false,
			
			reload = 0,
			
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
		}
		
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
			if not player.choosing then
				if (cmd.buttons & BT_WEAPONPREV) and not (player.lastbuttons & BT_WEAPONPREV)  then
					if player["ze2_info"].inventory_selection - 1 <= 0 then
						player["ze2_info"].inventory_selection = ZE2:FetchInventoryLimit(player)
					else
						player["ze2_info"].inventory_selection = $ - 1
					end
					
					S_StartSound(nil,sfx_mnu1a,player)
					
					player["ze2_info"].reload = 0
				end
			
				if (cmd.buttons & BT_WEAPONNEXT) and not (player.lastbuttons & BT_WEAPONNEXT) then				
					if player["ze2_info"].inventory_selection + 1 > ZE2:FetchInventoryLimit(player) then
						player["ze2_info"].inventory_selection = 1
					else
						player["ze2_info"].inventory_selection = $ + 1
					end

					S_StartSound(nil,sfx_mnu1a,player)
					
					player["ze2_info"].reload = 0
				end
				
				if (cmd.buttons & BT_FIRENORMAL) and not (player.lastbuttons & BT_FIRENORMAL)  then
					ZE2.DoPlayerReload(player)
				end
				
				if (cmd.buttons & BT_ATTACK) then
					if not player["ze2_info"].pressed_fire then
						player["ze2_info"].await_fire = true
					end
					player["ze2_info"].pressed_fire = true
				else
					player["ze2_info"].pressed_fire = false	
				end
			end
			
			-- try shoot
			if (cmd.buttons & BT_ATTACK) and not player["ze2_info"].weapondelay and not player["ze2_info"].reload
			and ZE2:FetchInventorySlot(player) and player.playerstate ~= PST_DEAD and not player.shop_open 
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

addHook("MobjThinker", function(mobj)
	if mobj and mobj.valid and mobj.iteminfo and ZE2.ItemPresets[mobj.iteminfo.item_id] 
	and ZE2.ItemPresets[mobj.iteminfo.item_id].thinker and mobj.target then
		ZE2.ItemPresets[mobj.iteminfo.item_id].thinker(mobj.target,mobj)
	end
end)

-- allow weapons to pop monitors
addHook("MobjMoveCollide", function(tmthing, thing)
	if tmthing and tmthing.valid and thing and thing.valid then
		if tmthing.shotbyplayer and thing.flags & MF_MONITOR then
			P_KillMobj(thing, tmthing, tmthing.target)
			S_StartSound(tmthing, sfx_pop)
			P_RemoveMobj(thing)
		end
	end
end)

-- amy heart healing
addHook("MobjMoveCollide", function(heart, victim)
	if heart and heart.valid and victim and victim.valid then
		local imo = heart.target
		if imo and imo.valid and imo.player and imo.player.valid then
			if victim.player and victim.player.valid then
				local inf_player = imo.player
				local victim_player = victim.player 
				
				if (inf_player.zteam == victim_player.zteam) 
				and not (imo == victim) and L_ZCollide(heart,victim) then
					if victim.health + 3 > victim.maxhealth then
						victim.health = victim.maxhealth
					else
						victim.health = $ + 3
					end
					
					local pinkghost = P_SpawnGhostMobj(victim)
					pinkghost.color = SKINCOLOR_ROSY
					
					return true
				end
				heart.shotbyplayer = true
			end
		end
	end
end, MT_LHRT)

-- dont let teammates and teamate's weapons collide with your weapon 
addHook("MobjMoveCollide", function(tmthing, thing)
	if tmthing and tmthing.valid and thing and thing.valid then
		if (tmthing.target and tmthing.flags & MF_MISSILE and tmthing.target.player and thing.player) then
			local team = thing.player.zteam or thing.target.player.zteam
			if tmthing.target.player.zteam == team then
				return false
			end
		end
	end
end)

addHook("SeenPlayer", function(player)
	if gametype == GT_ZE2 then
		return false
	end
end)

addHook("MobjSpawn", function(mobj)
	if mobjinfo[mobj.type].disablehealthhud then
		mobj.dontshowhealth = true
	end
end)