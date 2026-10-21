function ZE2.dropSurvivorInventory(player, force)
	local settings = ZE2.getGametypeSettings()

	if not settings.survivor_drop_inventory and not force then
		return end;

	local xS = player.xSlinger
	local inv = xS:inv_get("survivor")

	for i=1,#inv do
		local drop = xS:slot_drop(i, nil, "survivor")
		if drop and drop.valid then
			drop.droprandomangle = P_RandomRange(-35,35)*ANG1
		end
	end
end

-- Overwrite xSlinger function
function xSlinger.KillMobj(mo, inf, src, damagetype)
	local settings = ZE2.getGametypeSettings()
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

		if (team == 1) then -- victim is survivor
			if killer and killer.valid then
				if ZE2.cv_instantinfection.value then
					killing = false
					ZE2.ZombifyPlayer(player)
					ZE2.PlayZombieSound(player, true)
				end

				player.ze2.checkpoint_number = killer.player.ze2.checkpoint_number
				player.ze2.checkpoint_number_next = killer.player.ze2.checkpoint_number_next
				player.ze2.checkpoint_timer = killer.player.ze2.checkpoint_timer

				player.ze2.karma = min(player.ze2.karma + (ZE2.CountPlayers("survivors") * 28), ZE2.MaxKarma)
				killer.player.ze2.karma = max(1, killer.player.ze2.karma - 75)

				xSlinger.RemoveShieldFromMobj(mo)

				ZE2.dropSurvivorInventory(player)

				killer.player.ze2.cash = killer.player.ze2.cash + cash_award
				ZE2.SendInfectionMessage(player, (inf == killer) and src or inf, killer)
				CONS_Printf(killer.player, "\x83" .. "+ $" .. cash_award .. " cash gained from infecting a survivor!")
				S_StartSound(killer.player.mo, sfx_rbyhit)
			end
		elseif (team == 2) then -- victim is zombie
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward
				if killer and killer.valid then
					if killaward then
						A_RubyDrop(mo, killaward)
					end

					killer.player.ze2.karma = max(1, killer.player.ze2.karma - 120)
				end
			end

			local dmgtaken = player.ze2.damagefromplayer
			local dmgreq = (mo.maxhealth*7)/10
			if dmgtaken > dmgreq then
				player.ze2.next_zombie_type = "alpha"
			end
		end
	end

	if killing then
		local player = mo.player
		if player and player.valid then
			ZE2.SendDeathMessage(player, inf, src, damagetype)
			ZE2.dropSurvivorInventory(player)

			for i, v in ipairs(player.ze2.recent_attackers) do
				player.ze2.recent_attackers[i] = nil
			end
		end
		P_KillMobj(mo, inf, src, damagetype)
	end
end

-- 
xSlinger.addHook("OnPlayerDamage", function(player, inf, src, dmg, damagetype)
	local pV = player.ze2
	local attacker
	if src and src.valid then
		attacker = src
	elseif inf and inf.valid then
		attacker = inf
	end

	if (player.mo.team == 1) then
		if attacker and attacker.player and (attacker.team == 2) then
			pV.karma = min(pV.karma + 40, ZE2.MaxKarma)
			pV:ChangeStamina(-40 * FRACUNIT)
		end
		pV:DamageFade(15)
	elseif (player.mo.team == 2) then
		if attacker and attacker.player and attacker.team == 1 then
			local found = player.mo:search_effect("alphazombie.rage")
			if (pV.zombie_type == "alpha") and not #found then
				player.mo:give_effect("alphazombie.rage_regen", {}, TICRATE, true)
			end
		end
	end

	if attacker and attacker.valid then
		for index, other in ipairs(pV.recent_attackers) do
			if (other.source ~= attacker) then continue end
			table.remove(pV.recent_attackers, index)
			break
		end
		table.insert(pV.recent_attackers, {source = attacker, time = leveltime + (5 * TICRATE)})
	end

	if attacker and attacker.player then
		pV.damagefromplayer = pV.damagefromplayer + dmg
	end
end)

-- Prevent early game damage to zombies and from zombies.
xSlinger.addHook("ShouldDamage", function(mo, inf, src, dmg, damagetype)
	local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
	local player = mo.player
	local attacker

	if src and src.valid then
		attacker = src
	elseif inf and inf.valid then
		attacker = inf
	end

	if player and player.valid then
		local pregame = (game.state == ZE2.GS_PREGAME) and (not settings.move_during_pregame)
		local frozen_zombie = (mo.team == 2) and (game.zombie_release_time)

		if (game.ended) or (pregame) or (frozen_zombie) then
			return false
		end
	end

	if attacker and attacker.valid then
		if (player and player.valid) and (attacker.player and attacker.player.valid) and (mo.reactiontime or attacker.reactiontime) then
			return false
		end
	end

	if attacker and attacker.player and (attacker.team == 2) and game.zombie_release_time then
		return false
	end
end)

addHook("PlayerThink", function(player)
	if player.ze2.damage_fade and player.ze2.damage_fade_max then
		player.ze2.damage_fade = player.ze2.damage_fade - 1
		if not player.ze2.damage_fade then
			player.ze2.damage_fade_max = 0
		end
	else
		player.ze2.damage_fade = 0
		player.ze2.damage_fade_max = 0
	end
end)