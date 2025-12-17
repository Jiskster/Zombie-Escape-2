local KB = ZE2.Knockback

return function(mo, inf, src, dmg, damagetype)
	if (gametype ~= GT_ZE2) return end
	if ZE2.game_ended then return false end
	
	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)
	
	local knockback = 0
	local knockback_tics = 12
	local verticalknockback = 0
	local relativeknockback = false
	local inflictor_player -- player_t
	local attacker -- mobj_t
	local attackedbyzombie = false
	
	if inf and inf.valid and (inf.flags & MF_MISSILE) then
		P_ExplodeMissile(inf)
	end
	
	--check again incase above block removed inf
	if (inf and inf.valid) and inf.player and mo and mo.player then
		if mo.player.ze2.team == inf.player.ze2.team then
			return false
		else
			attackedbyzombie = true
		end
	end
	
	if inf and inf.valid and inf.player then
		inflictor_player = inf.player
		attacker = inf
	elseif src and src.valid and src.player then
		inflictor_player = src.player
		attacker = src
	end
	
	if src and src.player and mo and mo.player then
		if mo.player.ze2.team == src.player.ze2.team then
			return false
		else
			attackedbyzombie = true
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
		
		mo.player.ze2.shop_open = false
		mo.player.ze2.shop_anim = 0
		
		if inflictor_player and (ZE2.zombie_releasetime and mo.player.ze2.team == 2) then
			return false
		end
	end
	
	if inf and inf.valid then
		if inf.iteminfo then
			local srcskin
			
			if src and src.valid and src.player then
				srcskin = src.skin
			end
			
			local iteminfo = ZE2:Copy(inf.iteminfo)
			local item_damage = ZE2:GetItemInfoIndex(iteminfo, "damage", srcskin)
			local item_knockback = ZE2:GetItemInfoIndex(iteminfo, "knockback", srcskin)
			local item_knockback_tics = ZE2:GetItemInfoIndex(iteminfo, "knockback_tics", srcskin)
			
			if item_damage then
				dmg = item_damage
			end
			
			if item_knockback then
				knockback = item_knockback
			end
			
			if item_knockback_tics ~= nil then
				knockback_tics = item_knockback_tics
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

		-- ehh whatever, throw this in here too
		if (inf.flags & MF_FIRE) then
			mo.player.ze2:GiveEffect("flaming_effect", {
				normalspeed_multiplier = FU/2,
				actionspd_multiplier = 3*FU/2,
				damage_multiplier = FU/2,
			}, 4*TICRATE)
		end
	end
	
	if (inf and inf.valid and inf.player) then 
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
	
	if mo.info.antiknockback then
		knockback = 0
	end
	
	if mo.player then
		local player = mo.player
		local pv = player.ze2

		if pv.team == 1 then
			if not attackedbyzombie then
				player.powers[pw_flashing] = ZE2.survinvtics.value
				
				if not mo.shield_health then
					pv:DamageFade(15)
					S_StartSound(mo, sfx_s3kb9)
				else -- 
					S_StartSound(mo, sfx_shldls)
				end
			else -- if attacked by zombie
				pv:DamageFade(15)
				S_StartSound(mo, sfx_zbatk1 + P_RandomRange(0,2))
			end
			
			if inflictor_player then
				player.ze2:ChangeStamina(-40*FRACUNIT)
			end
		elseif pv.team == 2 then
			local ztype = pv.zombie_type
			local zombie_hurtsounds = {sfx_zpa1,sfx_zpa2}
			local chosen_hurtsound = zombie_hurtsounds[P_RandomRange(1,2)]
			
			if pv.crouching then
				knockback = $ * 3
			end
			
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].knockback_multiplier ~= nil then
				local knockback_multiplier = ZE2.ZombieConfig[ztype].knockback_multiplier
				
				knockback = FixedMul($, knockback_multiplier)
			end
			
			pv.zombie_slowtics = 7
			
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
	end
	
	-- BOOM! Knockback! 
	if inf and inf.valid then
		if not relativeknockback then
			KB.addKnockback(mo, knockback_tics, inf.angle, knockback)
		else
			local r_angle = R_PointToAngle2(mo.x, mo.y, inf.x, inf.y)
			
			KB.addKnockback(mo, knockback_tics, r_angle - ANGLE_180, knockback)
		end
		
		if verticalknockback then
			P_SetObjectMomZ(mo, verticalknockback, true)
		end
	end
	
	if inflictor_player and inflictor_player.valid then
		local dmg_attributes = inflictor_player.ze2:FindEffectAttributes("damage_multiplier") 
		local kb_attributes = inflictor_player.ze2:FindEffectAttributes("knockback_multiplier") 
		
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
	
	if mo.cashholding and (mo.cashholding - (mo.cashholding/3)) > 0 then
		A_RubyDrop(mo, mo.cashholding/3)
		mo.cashholding = $ - mo.cashholding/3
	end
	
	if mo.shield_health then
		--not enough shield to take the hit (TODO: play ring loss sound and damage fade when this happens)
		if mo.shield_health - dmg <= 0 then
			dmg = $ - abs(mo.shield_health)
			
			if inflictor_player and attacker then
				ZE2:AddDamageIndicator(inflictor_player, mo, dmg)
			end
			
			mo.shield_health = 0
		--shield negates damage
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
	
	ZE2.LimitMobjHealth(mo)
	
	return false
end