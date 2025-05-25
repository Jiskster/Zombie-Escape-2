if not leveltime then return end
if gametype ~= GT_ZE2 then return end

if player.mo and player.mo.valid then
	ZE2.LatestCheckpointTeleport(player, true)
end