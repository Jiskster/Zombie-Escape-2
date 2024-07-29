-- Amy's Hammer Hearts
mobjinfo[MT_LHRT].forcedamage = 3
mobjinfo[MT_LHRT].forceknockback = 8*FU

-- ze2_info only
function ZE2:TryBooleanAction(player, _table, strict)
	if not _table then
		if strict == true then
			error("Table expected")
		end
		return false
	end
	
	if _table.var == nil then
		if strict == true then
			error("Var expected")
		end
		
		return false
	end
	
	if (_table.condition) then
		if not player["ze2_info"][_table.var] then
			if _table.action then
				_table.action()
			end
		end
		
		player["ze2_info"][_table.var] = true
	else
		player["ze2_info"][_table.var] = false
	end
	
	return true
end

function ZE2.LimitMobjHealth(mobj)
	if mobj and mobj.valid then
		if mobj.health and mobj.maxhealth then
			if mobj.health > mobj.maxhealth then
				mobj.health = mobj.maxhealth
			end
		end
	end
end

function ZE2.KillMobj(mo, inf, src, damagetype, killedbysomething)
	local killing = true

	if mo.player and mo.player.valid then
		local player = mo.player 
		local ztype = player["ze2_info"].zombie_type
		local team = player["ze2_info"].team
		local ruby_award = 45
		local killer -- will be valid if player
		
		if inf and inf.player and inf.player.valid then
			killer = inf
		elseif src and src.player and src.player.valid then
			killer = src
		end
		
		if team == 1 then
			if killer then
				if ZE2.instantinfection.value then
					killing = false
					
					ZE2.ZombifyPlayer(player)
					ZE2.PlayZombieSound(player, true)
					player["ze2_info"].weapondelay = 3*TICRATE -- To prevent a chain effect when defending.
				end
			
				ZE2:QueuePlayerRubies(killer.player, ruby_award)
				print("\x84"..player.name.." \x83\has been infected by \x85"..killer.player.name)
				killer.player["ze2_info"].blood_currency = $ + 30
				
				CONS_Printf(killer.player, "\x85+"..ruby_award.." rubies gained from infecting a survivor!")
			end
		elseif team == 2 then
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward
				A_RubyDrop(mo, killaward)
			end
			
			if killer then
				player["ze2_info"].blood_currency = $ + 100
			end
		end
		
		player["ze2_info"].killedbysomething = killedbysomething
	end
	
	if killing then
		P_KillMobj(mo, inf, src, damagetype)
	end
end

function ZE2:AddDamageIndicator(player, victim_mobj, damage)
	if not player["ze2_info"].damage_indicator_table[victim_mobj] then
		player["ze2_info"].damage_indicator_table[victim_mobj] = {
			tics_left = TICRATE*2,
			number = damage,
			draw_x = victim_mobj.x,
			draw_y = victim_mobj.y,
			draw_z = victim_mobj.z + (victim_mobj.height*2),
		}
	else
		if player["ze2_info"].damage_indicator_table[victim_mobj].tics_left then
			player["ze2_info"].damage_indicator_table[victim_mobj].tics_left = TICRATE*2
		end
		
		if player["ze2_info"].damage_indicator_table[victim_mobj].number then
			player["ze2_info"].damage_indicator_table[victim_mobj].number = $ + damage
		end
		
		player["ze2_info"].damage_indicator_table[victim_mobj].draw_x = victim_mobj.x
		player["ze2_info"].damage_indicator_table[victim_mobj].draw_y = victim_mobj.y
		player["ze2_info"].damage_indicator_table[victim_mobj].draw_z = victim_mobj.z + (victim_mobj.height*2)
	end
end

-- Always return false
addHook("ShouldDamage", function(mo, inf, src, dmg, damagetype)
	if (gametype ~= GT_ZE2) return end
	if ZE2.game_ended then return false end
	
	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)
	
	local knockback = 0
	local verticalknockback = 0
	local relativeknockback = false
	local inflictor_player -- player_t
	local attacker -- mobj_t
	
	if inf and inf.valid and (inf.flags & MF_MISSILE) then
		P_ExplodeMissile(inf)
	end
	
	if inf and inf.player and mo and mo.player then
		if mo.player["ze2_info"].team == inf.player["ze2_info"].team then
			return false
		end
	end--player["ze2_info"].damage_indicator_table
	
	if inf and inf.valid and inf.player then
		inflictor_player = inf.player
		attacker = inf
	elseif src and src.valid and src.player then
		inflictor_player = src.player
		attacker = src
	end
	
	if src and src.player and mo and mo.player then
		if mo.player["ze2_info"].team == src.player["ze2_info"].team then
			return false
		end
	end
	
	-- Don't damage objects that are the same team.
	if inf and mobj and inf.valid and mobj.valid then
		if mo.mobjteam and inf.mobjteam and mo.mobjteam == inf.mobjteam then
			return false
		end
	end
	
	if mo.player then
		if mo.player.powers[pw_flashing] then
			return false
		end
		
		mo.player["ze2_info"].shop_open = false
		mo.player["ze2_info"].shop_anim = 0
		
		if inflictor_player and (ZE2.zombie_releasetime and mo.player["ze2_info"].team == 2) then
			return false
		end
	end
	
	if inf then
		if inf.iteminfo then
			local srcskin
			
			if src and src.valid and src.player then
				srcskin = src.skin
			end
			
			local iteminfo = ZE2:Copy(inf.iteminfo)
			local item_damage = ZE2:GetItemInfoIndex(iteminfo, "damage", srcskin)
			local item_knockback = ZE2:GetItemInfoIndex(iteminfo, "knockback", srcskin)
			
			if item_damage then
				dmg = item_damage
			end
			
			if item_knockback then
				knockback = item_knockback
			end
		end
		
		if inf.info.forcedamage then
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
	if not mo.shield_health then
		if mo.health - dmg <= 0 or deathdamagetype then
			if inflictor_player and attacker then
				ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
			end
			
			ZE2.KillMobj(mo, inf, src, damagetype, not deathdamagetype)
			return false
		end
	else
		if deathdamagetype then
			if inflictor_player and attacker then
				ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
			end
			
			ZE2.KillMobj(mo, inf, src, damagetype, not deathdamagetype)
			return false
		end
	end
	
	if mo.player then
		if mo.player["ze2_info"].team == 1 then
			mo.player.powers[pw_flashing] = ZE2.survinvtics.value
			
			if not mo.shield_health then
				ZE2:SetDamageFadeAnim(mo.player, 15)
				S_StartSound(mo, sfx_s3kb9)
			else -- 
				S_StartSound(mo, sfx_shldls)
			end

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
			
			if inflictor_player then
				ZE2:DecrementSprint(mo.player, 90*FRACUNIT)
				
				inflictor_player["ze2_info"].blood_currency = $ + 15
			end
		elseif mo.player["ze2_info"].team == 2 then
			local ztype = mo.player["ze2_info"].zombie_type
			local zombie_hurtsounds = {sfx_zpa1,sfx_zpa2}
			local chosen_hurtsound = zombie_hurtsounds[P_RandomRange(1,2)]
			
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].knockback_multiplier ~= nil then
				local knockback_multiplier = ZE2.ZombieConfig[ztype].knockback_multiplier
				
				knockback = FixedMul($, knockback_multiplier)
			end
			
			if not relativeknockback then
				local r_momxy = FixedHypot(mo.momx, mo.momy)
				
				P_InstaThrust(mo, inf.angle, knockback)
			else
				local r_angle = R_PointToAngle2(mo.x, mo.y, inf.x, inf.y)
				local r_momxy = FixedHypot(mo.momx, mo.momy)
				
				P_InstaThrust(mo, r_angle - ANGLE_180, knockback)
			end
		
			if verticalknockback then
				P_SetObjectMomZ(mo, verticalknockback, true)
			end
			
			mo.player["ze2_info"].landfatigue_timer = 30
			
			S_StartSound(mo, chosen_hurtsound)
			
			if inflictor_player then
				mo.player["ze2_info"].blood_currency = $ + 2
			end
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
	
	if inflictor_player and inflictor_player.valid then
		local dmg_attributes = ZE2:FindEffectAttributes(inflictor_player, "damage_multiplier") 
		local kb_attributes = ZE2:FindEffectAttributes(inflictor_player, "knockback_multiplier")
		
		-- all of this should be a function lol
		
		if #dmg_attributes then
			local multi = 0
			
			for i=1,#dmg_attributes do
				if i == 1 then
					multi = dmg_attributes[i]
				else
					multi = FixedMul($, dmg_attributes[i])
				end
			end
			
			if multi then
				dmg = FixedMul($*FU, multi)/FU
			end
		end
		
		if #kb_attributes then
			local multi = 0 
			
			for i=1,#kb_attributes do
				if i == 1 then
					multi = kb_attributes[i]
				else
					multi = FixedMul($, kb_attributes[i])
				end
			end
			
			if multi then
				knockback = FixedMul($, multi)
			end
		end
	end
	
	if mo.rubiesholding and (mo.rubiesholding - (mo.rubiesholding/3)) > 0 then
		A_RubyDrop(mo, mo.rubiesholding/3)
		mo.rubiesholding = $ - mo.rubiesholding/3
	end
	
	if mo.shield_health then
		if mo.shield_health - dmg <= 0 then
			dmg = $ - abs(mo.shield_health)
			
			if inflictor_player and attacker then
				ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
			end
			
			mo.shield_health = 0
		else
			if inflictor_player and attacker then
				ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
			end
			
			mo.shield_health = $ - dmg
		end
		
		if mo.shield_health <= 0 then
			mo.shield_health = 0
		end
	end
	
	if not mo.shield_health then
		if inflictor_player and attacker then
			ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
		end
		
		mo.health = $ - dmg -- fake damage i guess
	end
	
	if mo.health <= 0 then
		ZE2.KillMobj(mo, inf, src, damagetype, not deathdamagetype)
	end
	
	return false
end)

--ram into players as zombie
/*
addHook("MobjMoveCollide", function(thing,tmthing)
	if (gametype ~= GT_ZE2) return end
	if (ZE2.game_ended) then return end
	if L_ZCollide(thing,tmthing) and tmthing.player and tmthing.player["ze2_info"].team == 2 and thing.player
	and thing.player["ze2_info"].team ~= 2 then
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
	
	mobj.shield_health = 0
end)

-- A P_SPMAngle clone to fit the needs of ZE2
function ZE2.SpawnMissile(m_table)
	local source = m_table.source
	local mobj_type = m_table.mobj_type
	local angle = m_table.angle
	local allow_aim = m_table.allow_aim
	local flags2 = m_table.flags2
	local iteminfo = m_table.iteminfo
	local slope = 0
	local x = source.x
	local y = source.y
	local z -- Initialize later to calculate for MFE_VERTICALFLIP
	local th -- Object that is shot.
	local speed
	
	if allow_aim then
		slope = sin(source.player.aiming)
	end
	
	if source.eflags & MFE_VERTICALFLIP then
		z = source.z + 2*source.height/3 - FixedMul(mobjinfo[mobj_type].height, source.scale)
	else
		z = source.z + source.height/3
	end
	
	th = P_SpawnMobj(x, y, z, mobj_type)
	if not (th and th.valid) then
		return
	end
	
	speed = th.info.speed
	
	if iteminfo then 
		local skin = source.skin
		local temp_iteminfo = ZE2:Copy(iteminfo)
		local missile_fuse = ZE2:GetItemInfoIndex(temp_iteminfo, "fuse", skin)
		local missile_color = ZE2:GetItemInfoIndex(temp_iteminfo, "color", skin)
		local missile_velocity_multiplier = ZE2:GetItemInfoIndex(temp_iteminfo, "velocity_multiplier", skin)

		-- destroy functions
		temp_iteminfo.onspawn = nil
		temp_iteminfo.ontrigger = nil
		temp_iteminfo.onhit = nil
		temp_iteminfo.thinker = nil
		
		th.iteminfo = temp_iteminfo

		if missile_fuse then
			th.fuse = missile_fuse
		end
		
		if missile_color ~= nil then
			th.color = missile_color
		end
		
		if missile_velocity_multiplier then
			speed = FixedMul($, missile_velocity_multiplier)
		end
	end
	
	if source.player then
		th.mobjteam = tonumber(source.player["ze2_info"].team)
	end
	
	if source.eflags & MFE_VERTICALFLIP then
		th.flags2 = $ | MF2_OBJECTFLIP
	end

	P_SetScale(th, source.scale)

	if flags2 then
		th.flags2 = $ | flags2
	end

	if (th.info.seesound and not (th.flags2 & MF2_RAILRING)) then
		S_StartSound(source, th.info.seesound)
	end

	th.target = source

	/* Deprecated for chracter config variable "bullet_speed_multiplier"
	if source.player and source.player.charability == CA_FLY then
		speed = FixedMul($, 3*FRACUNIT/2)
	end
	*/
	
	if source.player and ZE2.CharacterConfig[source.skin] and ZE2.CharacterConfig[source.skin].bullet_speed_multiplier then
		speed = FixedMul($, ZE2.CharacterConfig[source.skin].bullet_speed_multiplier)
	end
	
	th.angle = angle
	
	th.momx = FixedMul(speed, cos(angle))
	th.momy = FixedMul(speed, sin(angle))
	
	--th.momx = P_ReturnThrustX(th, angle, speed)
	--th.momy = P_ReturnThrustY(th, angle, speed)
	
	if allow_aim then
		th.momx = FixedMul(th.momx, cos(source.player.aiming))
		th.momy = FixedMul(th.momy, cos(source.player.aiming))
	end

	th.momz = FixedMul(speed, slope)
	
	th.momx = FixedMul(th.momx, th.scale)
	th.momy = FixedMul(th.momy, th.scale)
	th.momz = FixedMul(th.momz, th.scale)
	
	slope = ZE2.CheckMissileSpawn(th)
	
	if slope then
		return th
	else
		return
	end
end


function ZE2.CheckMissileSpawn(th)
	if not (th.flags & MF_GRENADEBOUNCE) then -- From the Original: "hack: bad! should be a flag.""
		P_SetOrigin(th, th.x + th.momx/2, th.y, th.z)
		P_SetOrigin(th, th.x, th.y + th.momy/2, th.z)
		P_SetOrigin(th, th.x, th.y, th.z + th.momz/2)
	end

	if not P_TryMove(th, th.x, th.y, true) then
		if (th and th.valid) then
			P_ExplodeMissile(th)
		end
		return false
	end
	return true
end


function ZE2.DoPlayerFire(player, iteminfo)
	local ring
	local skin = player.mo.skin
	local missile_object = ZE2:GetItemInfoIndex(iteminfo, "object", skin)
	local flags2 = ZE2:GetItemInfoIndex(iteminfo, "flags2", skin)
	local item_sound = ZE2:GetItemInfoIndex(iteminfo, "sound", skin)
	
	-- dont be a phony
	if not ZE2.ItemPresets[iteminfo.item_id] then 
		return
	end
	
	if ZE2.game_ended or player["ze2_info"].pregamemenu_active then 
		return
	end

	if missile_object then
		local missile_def = {
			source = player.mo, 
			mobj_type = missile_object,
			angle = player.mo.angle,
			allow_aim = true,
			["iteminfo"] = iteminfo, -- you can do iteminfo = iteminfo too, its ["iteminfo"] = iteminfo for visual clarity.
			["flags2"] = flags2,
		}
		
		ring = ZE2.SpawnMissile(missile_def)
		-- [LEGACY]: ring = P_SPMAngle(player.mo, iteminfo.object, player.mo.angle, 1, iteminfo.flags2)
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
	
	if item_sound then
		S_StartSound(player.mo, item_sound)
	end

	if ring then
		ring.shotbyplayer = true

		if ZE2.ItemPresets[iteminfo.item_id].onspawn then
			ZE2.ItemPresets[iteminfo.item_id].onspawn(ring.target,ring,iteminfo)
		end
	end
end

function ZE2.DoPlayerReload(player)
	local iteminfo = ZE2:FetchInventorySlot(player)
	local skin = player.mo.skin
	local ammo = ZE2:GetItemInfoIndex(iteminfo, "ammo", skin)
	local max_ammo = ZE2:GetItemInfoIndex(iteminfo, "max_ammo", skin)
	local reload_time = ZE2:GetItemInfoIndex(iteminfo, "reload_time", skin)
	
	if iteminfo and reload_time and not player["ze2_info"].reload then
		if ammo ~= max_ammo then
			player["ze2_info"].reload = reload_time or 2*TICRATE
			S_StartSound(player.mo, sfx_z_rel1)
		end
	end
end

addHook("MobjThinker", function(mobj)
	if mobj and mobj.valid and mobj.iteminfo and ZE2.ItemPresets[mobj.iteminfo.item_id] 
	and ZE2.ItemPresets[mobj.iteminfo.item_id].thinker and mobj.target then
		ZE2.ItemPresets[mobj.iteminfo.item_id].thinker(mobj.target, mobj)
	end
end)

-- allow weapons to pop monitors
addHook("MobjMoveCollide", function(tmthing, thing)
	if tmthing and tmthing.valid and thing and thing.valid and L_ZCollide(thing,tmthing) then
		if tmthing.shotbyplayer and thing.flags & MF_MONITOR then
			P_KillMobj(thing, tmthing, tmthing.target)
			S_StartSound(tmthing, tmthing.info.deathsound)
			if (thing and thing.valid) then
				P_RemoveMobj(thing)
			end
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
				
				if (inf_player["ze2_info"].team == victim_player["ze2_info"].team) 
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
			local team = thing.player["ze2_info"].team or thing.target.player["ze2_info"].team
			if tmthing.target.player["ze2_info"].team == team then
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