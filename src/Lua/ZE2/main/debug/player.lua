addHook("MapLoad", function()
	for p in players.iterate do
		p.checkpointfound = 0
		p.checkpoint_number = 0
		p.noclip = false
		p.newspeed = nil
		p.ze2skinname = nil
	end
end)

--Get the checkpoint the player is touching with searchblockmap
--This only works if the checkpoint doesn't have the noblockmap flag
--Is there a better way to do this?
local function GetCheckpoint(p, range)
	local me = p.mo
	if not (me and me.valid) then return end

	local fakerange = (range > 126*FU) and 256*FU or 126*FU
	searchBlockmap("objects", function(ref, found)
		if found == me then return end
		if not (found and found.valid) then return end
		if not (found.info.doomednum == 5600 or found.type == MT_ZE2CHECKPOINT) then return end
		if not L_ZCollide(me,found) then return end

		me.player.checkpointfound = found.spawnpoint.args[0]
	end,
	me,
	me.x-fakerange, me.x+fakerange,
	me.y-fakerange, me.y+fakerange)
end

--Start searching for checkpoints every tic only if the show checkpoints option is enabled
addHook("PlayerThink", function(p)
	if not (ZE2.cv_debug.value and ZE2.debug.checkpoints_show) then return end
	if not (p.mo and p.mo.valid) then return end
	GetCheckpoint(p, 200*FU)
end)