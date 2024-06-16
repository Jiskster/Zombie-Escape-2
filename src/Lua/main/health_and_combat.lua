-- Fang's Cork Bullet
mobjinfo[MT_CORK].forcedamage = 10
mobjinfo[MT_CORK].forceknockback = 20*FU

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
		local ruby_award = 30
		
		if team == 1 then
			local killer
			
			if inf and inf.player and inf.player.valid then
				killer = inf
			elseif src and src.player and src.player.valid then
				killer = src
			end
			
			if killer then
				if ZE2.instantinfection.value then
					killing = false
					
					ZE2.ZombifyPlayer(player)
					ZE2.PlayZombieSound(player, true)
					player["ze2_info"].weapondelay = 3*TICRATE -- To prevent a chain effect when defending.
				end
			
				ZE2:QueuePlayerRubies(killer.player, ruby_award)
				print("\x84"..player.name.." \x83\has been infected by \x85"..killer.player.name)
				
				CONS_Printf(killer.player, "\x85+"..ruby_award.." rubies gained from infected a survivor!")
			end
		elseif team == 2 then
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward
				A_RubyDrop(mo, killaward)
			end
		end
		
		player["ze2_info"].killedbysomething = killedbysomething
	end
	
	if killing then
		P_KillMobj(mo, inf, src, damagetype)
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
	
	if inf and inf.player and mo and mo.player then
		if mo.player["ze2_info"].team == inf.player["ze2_info"].team then
			return false
		end
	end
	
	if src and src.player and mo and mo.player then
		if mo.player["ze2_info"].team == src.player["ze2_info"].team then
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
		
		mo.player["ze2_info"].shop_open = false
		mo.player["ze2_info"].shop_anim = 0
	end
	
	if inf then
		if inf.iteminfo then
			local iteminfo = inf.iteminfo
			
			if iteminfo.damage then
				dmg = iteminfo.damage
			end
			
			if iteminfo.knockback then
				knockback = iteminfo.knockback
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
	if mo.health - dmg <= 0 or deathdamagetype then
		ZE2.KillMobj(mo, inf, src, damagetype, not deathdamagetype)
		return false
	end
	
	if mo.player then
		if mo.player["ze2_info"].team == 1 then
			mo.player.powers[pw_flashing] = ZE2.survinvtics.value
			ZE2:SetDamageFadeAnim(mo.player, 15)
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
		elseif mo.player["ze2_info"].team == 2 then
			local ztype = mo.player["ze2_info"].zombie_type
			local zombie_hurtsounds = {sfx_zpa1,sfx_zpa2}
			local chosen_hurtsound = zombie_hurtsounds[P_RandomRange(1,2)]
			
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].knockback_multiplier ~= nil then
				local knockback_multiplier = ZE2.ZombieConfig[ztype].knockback_multiplier
				
				knockback = FixedMul($, knockback_multiplier)
			end
			
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
	
	if iteminfo then 
		local temp_iteminfo = ZE2:Copy(iteminfo)

		-- destroy functions
		temp_iteminfo.onspawn = nil
		temp_iteminfo.ontrigger = nil
		temp_iteminfo.onhit = nil
		
		th.iteminfo = temp_iteminfo
		
		if iteminfo.fuse then
			th.fuse = iteminfo.fuse
		end
		
		if iteminfo.color ~= nil then
			th.color = iteminfo.color
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

	speed = th.info.speed
	if source.player and source.player.charability == CA_FLY then
		speed = FixedMul(speed, 3*FRACUNIT/2)
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
	
	if not ZE2.ItemPresets[iteminfo.item_id] then
		return
	end
	
	if ZE2.game_ended or player["ze2_info"].charselect_choosing then 
		return
	end

	if iteminfo.object then
		local missile_def = {
			source = player.mo, 
			mobj_type = iteminfo.object,
			angle = player.mo.angle,
			allow_aim = true,
			iteminfo = iteminfo,
			flags2 = iteminfo.flags2,
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
	
	if iteminfo.sound then
		S_StartSound(player.mo, iteminfo.sound)
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
	if iteminfo and iteminfo.reload_time and not player["ze2_info"].reload then
		if iteminfo.ammo ~= iteminfo.max_ammo then
			player["ze2_info"].reload = iteminfo.reload_time or 2*TICRATE
			S_StartSound(player.mo, sfx_z_rel1)
		end
	end
end

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