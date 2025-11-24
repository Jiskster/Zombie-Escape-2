freeslot("S_VISIBLE_CHECKPOINT")
states[S_VISIBLE_CHECKPOINT] = {SPR_TGFX, FF_FULLBRIGHT|A, -1, nil, 0, 0, S_VISIBLE_CHECKPOINT}

local show_checkpoints = function(mo)
	if not (mo and mo.valid) then return end

	if ZE2.debug.checkpoints_show == true then
		if mo.state ~= S_VISIBLE_CHECKPOINT then
			--need to remove noblockmap flag to make the player find it with searchblockmap
			mo.flags = $ &~MF_NOBLOCKMAP
			mo.state = S_VISIBLE_CHECKPOINT --set it's state to a visible one
		end
	elseif mo.state ~= S_INVISIBLE then
		mo.flags = $|MF_NOBLOCKMAP
		mo.state = S_INVISIBLE
	end
	if not ZE2.cv_debug.value
	and mo.state ~= S_INVISIBLE then
		mo.flags = $|MF_NOBLOCKMAP
		mo.state = S_INVISIBLE
	end
end
addHook("MobjThinker", show_checkpoints, MT_ZE2CHECKPOINT)