local KB = xSlinger.Knockback

xSlinger.KillMobj = P_KillMobj

function xSlinger.ShouldDamage(mo, inf, src, dmg, damagetype)
	dmg = $ or 0 -- Making sure we don't error!
	damagetype = $ or 0

	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)

	local knockback = 0
	local knockback_tics = 12
	local verticalknockback = 0
	local relativeknockback = false
	local player -- player_t
	local inflictor_player -- player_t
	local attacker -- mobj_t

	local hurtsound = sfx_shldls
	local ignoreskinhurtsound = false

	if inf and inf.valid and (inf.flags & MF_MISSILE) then
		P_ExplodeMissile(inf)
	end

	if (mo.flags & MF_MONITOR) then
		return
	end

	-- Don't damage objects that are the same team.
	if (inf and inf.valid) and (mo and mo.valid) then
		if mo.team == inf.team then
			return false
		end
	end

	if mo.player and mo.player.valid then
		player = mo.player
	end

	if inf and inf.valid and inf.player and inf.player.valid then
		inflictor_player = inf.player
		attacker = inf
	elseif src and src.valid and src.player and src.player.valid then
		inflictor_player = src.player
		attacker = src
	end

	if player and player.powers[pw_flashing] > 0 then
		return false
	end

	do
		local ev, ev_name = xSlinger.findEvent("ShouldDamage")

		if #ev then
			for i,v in ipairs(ev) do
				local result = xSlinger.tryRunHook(ev_name, v, mo, inf, src, dmg, damagetype)
				if result ~= nil then
					return result
				end
			end
		end
	end

	if inf and inf.valid then
		local iteminfo = inf.iteminfo

		if iteminfo then
			setmetatable(iteminfo, xSlinger.METATABLES.ITEMINFO)
			
			local src_skin

			if src and src.valid and src.player then
				src_skin = src.skin
			end

			local item_damage = iteminfo:getIndex("damage", src_skin)
			local item_knockback = iteminfo:getIndex("knockback", src_skin)
			local item_knockback_tics = iteminfo:getIndex("knockback_tics", src_skin)
			local item_sounds = iteminfo:getIndex("sounds", src_skin)

			if item_damage then
				dmg = item_damage
			end

			if item_knockback then
				knockback = item_knockback
			end

			if item_knockback_tics ~= nil then
				knockback_tics = item_knockback_tics
			end

			if item_sounds and item_sounds.hurt then
				local hs = item_sounds.hurt

				if type(hs) == "table" then
					local sound = hs[P_RandomRange(1,#hs)]

					hurtsound = sound
				elseif type(hs) == "number" then
					hurtsound = hs
				end

				ignoreskinhurtsound = true
			end
		end

		if inf.info.forcedamage then
			dmg = inf.info.forcedamage
		end

		if inf.info.forceknockback then
			knockback = inf.info.forceknockback
		end

		-- Knocks back angle between two objects instead of pushing backwards of attacker object
		if inf.info.relativeknockback or inf.relativeknockback then
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

		if iteminfo and iteminfo.hitfunc then
			if inf.target then
				iteminfo:hitfunc(inf.target, mo, inf)
			else
				iteminfo:hitfunc(src, mo, inf)
			end
		end

		if (inf.flags & MF_FIRE) then
			if xSlinger.Effects["burning"] then
				mo:give_effect("burning", {
					normalspeed_multiplier = FU/2,
					actionspd_multiplier = 3*FU/2,
					damage_multiplier = FU/2,
				}, 18, true)
			end
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
			do
				local ev, ev_name = xSlinger.findEvent("MobjDamage")
				if #ev then
					for i,v in ipairs(ev) do
						local result = xSlinger.tryRunHook(ev_name, v, mo, inf, src, dmg, damagetype)
					end
				end
			end
			xSlinger.KillMobj(mo, inf, src, damagetype)
			return false
		end
	else
		if deathdamagetype then
			do
				local ev, ev_name = xSlinger.findEvent("MobjDamage")
				if #ev then
					for i,v in ipairs(ev) do
						local result = xSlinger.tryRunHook(ev_name, v, mo, inf, src, dmg, damagetype)
					end
				end
			end
			xSlinger.KillMobj(mo, inf, src, damagetype)
			return false
		end
	end

	if mo.info.antiknockback then
		knockback = 0
	end

	if mobjinfo[mo.type].npc_name then
		if (not mo.target) and (inf or src.player) then --enemies wake up if you hit them from behind
			mo.target = src
			
			if mo.info.seestate then
				mo.state = mo.info.seestate
			end
		end

		if mobjinfo[mo.type].painsound and mobjinfo[mo.type].painsound ~= sfx_None then
			S_StartSound(mo,mobjinfo[mo.type].painsound)
		end
	end

	-- BOOM! Knockback!
	if inf and inf.valid then
		if inf.knockbacktics then
			knockback_tics = inf.knockbacktics
		end
		
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
	
	if mo.type == MT_PLAYER or mo.playskinhurt then
		local prop_skin = xSlinger.skin_properties[mo.skin]

		if prop_skin and prop_skin.hurtsound
		and not ignoreskinhurtsound then
			local hs = prop_skin.hurtsound
			if type(hs) == "table" then
				local sound = hs[P_RandomRange(1,#hs)]

				hurtsound = sound
			elseif type(hs) == "number" then
				hurtsound = hs
			end
		end
		
		S_StartSound(mo, hurtsound)
	end
	
	if player then
		if xSlinger.teams[mo.team] and xSlinger.teams[mo.team].iframes ~= nil then
			player.powers[pw_flashing] = xSlinger.teams[mo.team].iframes
		else -- default iframes
			player.powers[pw_flashing] = 4
		end

		do
			local ev, ev_name = xSlinger.findEvent("OnPlayerDamage")

			if #ev then
				for i,v in ipairs(ev) do
					local result = xSlinger.tryRunHook(ev_name, v, player, inf, src, dmg, damagetype)
				end
			end
		end
	end

	for i,effect in ipairs(mo.effects) do
		if effect.protection_multiplier then
			dmg = FixedMul($*FU, effect.protection_multiplier)/FU
		end

		if effect.knockback_multiplier then
			knockback = FixedMul($, effect.knockback_multiplier)
		end
	end

	if attacker and attacker.valid then
		for i,effect in ipairs(attacker.effects) do
			if effect.damage_multiplier then
				dmg = FixedMul($*FU, effect.damage_multiplier)/FU
			end
		end
	end

	if mo.shield_health then
		if (mo.shield_efficiency > 0) then -- armor as percentage
			local absorbed_damage = FixedMul(dmg, mo.shield_efficiency) -- efficiency in fracunits -- FU = 100%, FU/2 = 50%, and so on
			if (absorbed_damage <= 0) then -- if the damage is too low, it can protect nothing, avoid that and absorb 1 point at minimum
				absorbed_damage = 1
			end

			if (mo.shield_health <= absorbed_damage) then
				absorbed_damage = mo.shield_health
				mo.shield_efficiency = 0
			end
			mo.shield_health = mo.shield_health - absorbed_damage
			dmg = max(dmg - absorbed_damage, 0)
		else
			mo.shield_health = mo.shield_health - dmg
			if (mo.shield_health <= 0) then
				dmg = abs(mo.shield_health)
				mo.shield_health = 0
			else
				dmg = max(dmg - dmg, 0)
			end
		end
	end
	mo.health = mo.health - dmg -- negate health ourselves, dont use damage function

	do
		local ev, ev_name = xSlinger.findEvent("MobjDamage")
		if #ev then
			for i,v in ipairs(ev) do
				local result = xSlinger.tryRunHook(ev_name, v, mo, inf, src, dmg, damagetype)
			end
		end
	end

	if mo.health <= 0 then
		xSlinger.KillMobj(mo, inf, src, damagetype)
	end

	return false
end

addHook("ShouldDamage", function(...)
	return xSlinger.ShouldDamage(...)
end)