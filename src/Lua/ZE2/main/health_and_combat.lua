local KB = ZE2.Knockback
ZE2.BulletList = {} -- For thinkers and basic caching.

freeslot("SPR_ZE2_DAMAGENUMBER")

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
		if not player.ze2[_table.var] then
			if _table.action then
				_table.action()
			end
		end
		
		player.ze2[_table.var] = true
	else
		player.ze2[_table.var] = false
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

-- Overwrite xSlinger function
function xSlinger.KillMobj(mo, inf, src, damagetype)
	local killing = true
	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)

	if mo.player and mo.player.valid then
		local player = mo.player 
		local ztype = player.ze2.zombie_type
		local team = player.xSlinger.team
		local cash_award = 150
		local killer -- will be valid if player
		
		if inf and inf.valid and inf.player and inf.player.valid then
			killer = inf
		elseif src and src.valid and src.player and src.player.valid then
			killer = src
		end
		
		if team == 1 then
			if killer and killer.valid then
				if ZE2.instantinfection.value then
					killing = false
					
					ZE2.ZombifyPlayer(player)
					ZE2.PlayZombieSound(player, true)
				end
				
				player.ze2.karma = min($ + (ZE2.SurvivorCount()*22), ZE2.MaxKarma)
				killer.player.ze2.karma = max(1, $ - 22)
			
				killer.player.ze2.cash = $ + cash_award
				S_StartSound(killer.player.mo, sfx_rbyhit)
				print("\x84"..player.name.." \x83\has been infected by \x85"..killer.player.name)

				CONS_Printf(killer.player, "\x83+ $"..cash_award.." cash gained from infecting a survivor!")
			end
		elseif team == 2 then
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward
				A_RubyDrop(mo, killaward)
				
				local player_count = ZE2.PlayerCount()
				
				local chance = FU/8
				
				if player_count < 8 then
					chance = FU/4
				end
				
				if killer and killer.valid then
					killer.player.ze2.karma = max(1, $ - 120)
				
					if P_RandomChance(chance) then
						player.ze2.zombie_next_type = "alpha"
					end
				end
			end
		end
		
		player.ze2.killedbysomething = not damagetype
		if not (src and src.valid) then
			player.ze2.killedbysomething = false
		end
	end
	
	if killing then
		P_KillMobj(mo, inf, src, damagetype)
	end
end

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

--these are updated in baseplayer.lua
local function SpawnDamageNumbers(player, victim_mobj, damage)
	local numbers = {}

	--TODO: test to make sure this doesnt spawn too much mobjs, check for desynchs
	do
		damage = tostring($)
		local str_len = string.len(damage)
		
		local scale = FixedDiv(R_PointToDist(victim_mobj.x,victim_mobj.y), victim_mobj.radius * 10)
		scale = max($, victim_mobj.scale * 2)
		scale = FixedMul($, GetFOV())
		scale = $/2
		--print(string.format("s: %f r: %f rt: %f", scale, random, randomthr))
		
		local offset = FixedMul((str_len*width)*FU, scale) / 2
		
		local work = offset
		local angle = R_PointToAngle(victim_mobj.x,victim_mobj.y) - ANGLE_90
		
		for i = 1,str_len do
			local n = string.sub(damage,i,i)
			local frame = tonumber(n)
			
			local num = P_SpawnMobjFromMobj(victim_mobj,
				P_ReturnThrustX(nil, angle, work),
				P_ReturnThrustY(nil, angle, work),
				FixedDiv(victim_mobj.height, victim_mobj.scale),
				MT_THOK
			)
			num.sprite = SPR_ZE2_DAMAGENUMBER
			num.frame = (frame)|FF_FULLBRIGHT
			num.scale = scale
			num.color = victim_mobj.color or SKINCOLOR_RED
			
			num.tics = 2*TICRATE
			num.fuse = num.tics
			
			--num.flags = $ &~MF_NOGRAVITY
			
			num.renderflags = $|RF_NOCOLORMAPS
			num.drawonlyforplayer = player
			num.dispoffset = 100
			
			num.nu_momz = 3 * FU
			num.nu_thrust = 2 * FU * (leveltime % 2 and 1 or -1)
			num.nu_width = width
			if num.nu_offset == nil
				num.nu_offset = 0
			end
			if i == 1
				num.z = $ + 6*scale
				num.nu_offset = 6*FU
			end
			num.nu_anim = nil
			table.insert(numbers, num)
			
			work = $ + width*scale
		end
	end
	return numbers
end

function ZE2:AddDamageIndicator(player, victim_mobj, damage)
	if not player.ze2.damage_indicator_table[victim_mobj] then
		player.ze2.damage_indicator_table[victim_mobj] = {
			tics_left = TICRATE*2,
			animation = 1,
			number = min(damage, victim_mobj.health),
			draw_x = victim_mobj.x,
			draw_y = victim_mobj.y,
			draw_z = victim_mobj.z + (victim_mobj.height*2),
			
			real_position = {
				x = victim_mobj.x,
				y = victim_mobj.y,
				z = victim_mobj.z,
				scale = victim_mobj.scale,
				height = victim_mobj.height,
				radius = victim_mobj.radius
			}
		}
		
		player.ze2.damage_indicator_table[victim_mobj].damagenumbers = SpawnDamageNumbers(player, victim_mobj, min(damage, victim_mobj.health))
	else
		if player.ze2.damage_indicator_table[victim_mobj].tics_left then
			player.ze2.damage_indicator_table[victim_mobj].tics_left = TICRATE*2
			player.ze2.damage_indicator_table[victim_mobj].animation = 1
		end
		
		if player.ze2.damage_indicator_table[victim_mobj].number then
			player.ze2.damage_indicator_table[victim_mobj].number = min($ + damage, victim_mobj.maxhealth or 0)
		end
		
		player.ze2.damage_indicator_table[victim_mobj].draw_x = victim_mobj.x
		player.ze2.damage_indicator_table[victim_mobj].draw_y = victim_mobj.y
		player.ze2.damage_indicator_table[victim_mobj].draw_z = victim_mobj.z + (victim_mobj.height*2)
		
		player.ze2.damage_indicator_table[victim_mobj].real_position = {
			x = victim_mobj.x,
			y = victim_mobj.y,
			z = victim_mobj.z,
			scale = victim_mobj.scale,
			height = victim_mobj.height,
			radius = victim_mobj.radius
		}

		if player.ze2.damage_indicator_table[victim_mobj].damagenumbers then
			for k, mo in ipairs(player.ze2.damage_indicator_table[victim_mobj].damagenumbers) do
				--game already did it for us, cool
				if not (mo and mo.valid) then continue end
				P_RemoveMobj(mo)
			end
		end

		player.ze2.damage_indicator_table[victim_mobj].damagenumbers = SpawnDamageNumbers(player, victim_mobj, player.ze2.damage_indicator_table[victim_mobj].number)
	end
end

xSlinger.addHook("OnPlayerDamage", function(player, inf, src, dmg, damagetype)
	
end)

addHook("SeenPlayer", function(player)
	if gametype == GT_ZE2 then
		return false
	end
end)