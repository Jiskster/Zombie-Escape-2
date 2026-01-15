ZE2.ResetPlayer = function(player, set_team, resetinventory)
	local ze2 = player.ze2
	local xS = player.xSlinger

	local TEAM_SURVIVOR = 1
	local TEAM_ZOMBIE = 2

	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig

	local mo = player.mo

	if not (mo and mo.valid) then
		return end;
	
	if set_team ~= nil then
		xS.team = set_team
	end

	ZE2.lockPlayer(player) -- To make sure the player is the right skin for the team!

	local team = xS.team

	local skin = mo.skin
	local ztype = ze2.zombie_type

	local config

	if (team == TEAM_SURVIVOR) then
		config = cc[skin]
	elseif (team == TEAM_ZOMBIE) then
		config = zc[ztype]
	end

	ZE2.applyPlayerConfig(player)

	if config then
		mo.scale = config.scale or FRACUNIT
	end

	if team == 1 then
		ze2.zombie_type = "normal"
		xS:inv_set("survivor")
	elseif team == 2 then
		xS:inv_set("zombie")
	end

	ZE2.resetPlayerHealth(player)

	if resetinventory then
		ZE2.setConfigInventory(player)
	end
end