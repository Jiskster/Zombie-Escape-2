ZE2.ResetPlayer = function(player, choosenewztype)
	local ze2 = player.ze2

	local TEAM_SURVIVOR = 1
	local TEAM_ZOMBIE = 2

	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig

	local mo = player.mo

	if not (mo and mo.valid) then
		return end;
	
	local team = ze2.team

	local skin = mo.skin
	local ztype = ze2.zombie_type

	local config = (team == TEAM_SURVIVOR) and cc[skin] or zc[ztype]

	ZE2.applyPlayerConfig(player)
	ZE2.resetPlayerHealth(player)

	mo.scale = config.scale or FRACUNIT

	if team == 1 then
		ze2.zombie_type = "normal"
	elseif team == 2 then
		ZE2.SetZCinventory(player)
	end
end