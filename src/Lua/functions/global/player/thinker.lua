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
		
		if not ZE2.round_active and player.ze2.pregamemenu_active then
			if player.mo and player.mo.valid then
				player.mo.flags2 = $|MF2_DONTDRAW
			end
		end
		
		if player.ze2.sprintmeter == nil then
			player.ze2.sprintmeter = 100*FRACUNIT
		end
		
		if player.ze2.sprintmeter < 0 then
			player.ze2.sprintmeter = 0
		end

		player.ze2.isSprinting = $ or false
		
		if player.ze2.team == 1 then
			ZE2.SetCCtoplayer(player)
		elseif player.ze2.team == 2 then
			ZE2.SetZCtoplayer(player)
		end
		
		if player.ze2.effects then
			for i,v in pairs(player.ze2.effects) do
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
						
						player.ze2.effects[i] = nil
						continue
					end
				end
			end
		else
			player.ze2.effects = {}
		end
		
		if player.ze2.damage_indicator_table then
			for dmo,v in pairs(player.ze2.damage_indicator_table) do
				
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
						player.ze2:UpdateDamageNumbers(v.damagenumbers, v.real_position, v.number)
					end
					
					if v.tics_left & 1
						v.animation = $ + 1
					end
					
					v.tics_left = $ - 1
					if v.tics_left <= 0 then
						player.ze2.damage_indicator_table[dmo] = nil
						continue
					end
				else
					player.ze2.damage_indicator_table[dmo] = nil
					continue
				end
			end
		end
		
		if player.ze2.landfatigue_timer then
			player.ze2.landfatigue_timer = $ - 1
		end
		
		if player.mo and player.mo.valid then
			local pmo = player.mo
			
			if player.ze2.landfatigue and (pmo.eflags & MFE_JUSTHITFLOOR) then
				player.ze2.landfatigue = false
				player.ze2.landfatigue_timer = $ + 20
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