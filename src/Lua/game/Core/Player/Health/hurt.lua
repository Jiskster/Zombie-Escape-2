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

		if (team == 1) then
			if killer and killer.valid then
				if ZE2.cv_instantinfection.value then
					killing = false
					ZE2.ZombifyPlayer(player)
					ZE2.PlayZombieSound(player, true)
				end
				player.ze2.karma = min(player.ze2.karma + (ZE2.CountPlayers("survivors") * 22), ZE2.MaxKarma)
				killer.player.ze2.karma = max(1, killer.player.ze2.karma - 22)

				xSlinger.RemoveShieldFromMobj(mo)

				killer.player.ze2.cash = killer.player.ze2.cash + cash_award
				S_StartSound(killer.player.mo, sfx_rbyhit)
				print(string.format("%s%s%s has been infected by %s%s", "\x84", player.name, "\x83", "\x85", killer.player.name))
				CONS_Printf(killer.player, "\x83" .. "+ $" .. cash_award .. " cash gained from infecting a survivor!")
			end
		elseif (team == 2) then
			if ztype and ZE2.ZombieConfig[ztype] and ZE2.ZombieConfig[ztype].killaward then
				local killaward = ZE2.ZombieConfig[ztype].killaward
				if killer and killer.valid then
					A_RubyDrop(mo, killaward)
					killer.player.ze2.karma = max(1, killer.player.ze2.karma - 120)
				end
			end
		end
	end

	if killing then
		local player = mo.player
		if player and player.valid then
			local playercolor = (mo.team == 1) and "\x84" or "\x85"
			if src and src.valid then
				if src.player and src.player.valid then
					local sourcecolor = (src.team == 1) and "\x84" or "\x85"
					print(string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", sourcecolor, src.player.name))
				elseif src.info and src.info.npc_name then
					print(string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", "\x82", src.info.npc_name))
				elseif (src.flags & (MF_ENEMY|MF_BOSS)) then
					print(string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", "\x82", "Something"))
				elseif (src.flags & (MF_FIRE)) then
					print(string.format("%s%s%s has been burned to death", playercolor, player.name, "\x83"))
				else
					print(string.format("%s%s%s has been killed", playercolor, player.name, "\x83"))
				end
			elseif inf and inf.valid then
				print(string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", "\x82", "Something"))
			else
				print(string.format("%s%s%s has died", playercolor, player.name, "\x83"))
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
			player.ze2.karma = min(player.ze2.karma + 3, ZE2.MaxKarma)
			pV:ChangeStamina(-40 * FRACUNIT)
		end
		pV:DamageFade(15)
	elseif (player.mo.team == 2) then
		if attacker and attacker.player and attacker.team == 1 then
			local found = player.mo:search_effect("alphazombie.rage")
			if player.ze2.zombie_type == "alpha" and not #found then
				player.mo:give_effect("alphazombie.rage_regen", {}, TICRATE, true)
			end
		end
	end
end)

-- Prevent early game damage to zombies and from zombies.
xSlinger.addHook("ShouldDamage", function(mo, inf, src, dmg, damagetype)
	local game = ZE2.Game
	local player = mo.player
	local attacker

	if src and src.valid then
		attacker = src
	elseif inf and inf.valid then
		attacker = inf
	end

	if player and player.valid and (game.ended or game.state == ZE2.GS_PREGAME or ((mo.team == 2) and game.releasetime)) then
		return false
	end

	if attacker and attacker.valid then
		if (player and player.valid) and (attacker.player and attacker.player.valid) and (mo.reactiontime or attacker.reactiontime) then
			return false
		end
	end

	if attacker and attacker.player and (attacker.team == 2) and game.releasetime then
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