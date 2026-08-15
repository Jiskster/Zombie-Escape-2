freeslot("SPR_ZE2_DAMAGENUMBER")

-- Overwrite xSlinger function
function xSlinger.KillMobj(mo, inf, src, damagetype)
	local killing = true
	local deathdamagetype = (damagetype >= DMG_INSTAKILL and damagetype <= DMG_SPECTATOR)

	if mo.player and mo.player.valid then
		local player = mo.player
		local ztype = player.ze2.zombie_type
		local team = mo.team
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

				xSlinger.RemoveShieldFromMobj(mo)

				killer.player.ze2.cash = $ + cash_award
				S_StartSound(killer.player.mo, sfx_rbyhit)
				print(string.format("%s%s%s has been infected by %s%s", "\x84", player.name, "\x83", "\x85", killer.player.name))

				CONS_Printf(killer.player, "\x83+ $"..cash_award.." cash gained from infecting a survivor!")
			end
		elseif team == 2 then
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward

				local player_count = ZE2.PlayerCount()

				local chance = FU/8

				if player_count < 8 then
					chance = FU/4
				end

				if killer and killer.valid then
					A_RubyDrop(mo, killaward)
				
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

---@param player player_t
---@param source mobj_t
---@param damage integer
function ZE2:AddDamageText(player, source, damage)
	if source.info and source.info.nodamagetext then return end

	player.ze2.damage_text = player.ze2.damage_text or {}
	for index, indicator in ipairs(player.ze2.damage_text) do
		if (indicator.source ~= source) then continue end
		if not indicator.text or not indicator.text.valid then continue end
		indicator.text.cusval = indicator.text.cusval + damage
		Lugent_ChangeWorldText(indicator.text, tostring(indicator.text.cusval), 1, TICRATE * 5, true)
		return
	end

	local direction = R_PointToAngle(source.x, source.y)
	local x = P_ReturnThrustX(source, direction, 64 * FU)
	local y = P_ReturnThrustY(source, direction, 64 * FU)
	local z = source.height * 2
	local text = Lugent_SpawnWorldText(source.x + x, source.y + y, source.z + z, tostring(damage), 1, TICRATE * 5, true)
	text.angle = direction - ANGLE_90
	text.momx = source.momx
	text.momy = source.momy
	text.momz = source.momz
	text.oradius = source.radius
	text.oscale = source.scale
	text.drawonlyforplayer = player
	text.cusval = damage
	table.insert(player.ze2.damage_text, {text = text, source = source})
end

xSlinger.addHook("OnPlayerDamage", function(player, inf, src, dmg, damagetype)
	local pV = player.ze2

	local attacker

	if src and src.valid then
		attacker = src
	elseif inf and inf.valid then
		attacker = inf
	end

	if player.mo.team == 1 then
		if attacker and attacker.player and attacker.team == 2 then
			player.ze2.karma = min($ + 3, ZE2.MaxKarma)
			pV:ChangeStamina(-40*FRACUNIT)
		end

		pV:DamageFade(15)
	elseif player.mo.team == 2 then
		if attacker and attacker.player and attacker.team == 1 then
			local found = player.mo:search_effect("alphazombie.rage")
			if player.ze2.zombie_type == "alpha" and not #found then
				player.mo:give_effect("alphazombie.rage_regen", {}, TICRATE, true)
			end
		end
	end
end)

xSlinger.addHook("MobjDamage", function(mobj, inf, src, dmg, damagetype)
	local player
	if src and src.valid and src.player and src.player.valid then
		player = src.player
	elseif inf and inf.valid and inf.player and inf.player.valid then
		player = inf.player
	end

	if not player then return end

	ZE2:AddDamageText(player, mobj, dmg)
end)

-- Prevent early game damage to zombies and from zombies.
xSlinger.addHook("ShouldDamage", function(mo, inf, src, dmg, damagetype)
	local player = mo.player
	local attacker

	if src and src.valid then
		attacker = src
	elseif inf and inf.valid then
		attacker = inf
	end

	if player and player.valid
	and (ZE2.pregame_timeleft or ((mo.team == 2) and ZE2.zombie_releasetime)) then
		return false
	end

	if attacker and attacker.player and attacker.team == 2 and ZE2.zombie_releasetime then
		return false
	end
end)