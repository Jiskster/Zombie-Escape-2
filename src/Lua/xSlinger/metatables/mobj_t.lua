-- TODO: Move and rename file

local function validateTeam(player)
	if player.realmo and player.realmo.valid then
		if player.realmo.team == nil then
			player.realmo.team = 1
		end
	end
end

addHook("MobjSpawn", function(mobj)
	if mobj.type == MT_PLAYER then 
		return end;
	
	mobj.team = 0
end)

addHook("PreThinkFrame", function(player)
	for player in players.iterate do
		validateTeam(player)
	end
end)