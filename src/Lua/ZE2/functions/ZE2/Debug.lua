ZE2.debug.Teleport2Checkpoint = function(p, nextprev)
	if #ZE2.Checkpoints then

		if nextprev == 1 then
			if p.checkpoint_number == #ZE2.Checkpoints then p.checkpoint_number = 1
			else p.checkpoint_number = $+1
			end
		elseif nextprev == -1 then
			if not p.checkpoint_number or p.checkpoint_number == 1 then p.checkpoint_number = #ZE2.Checkpoints
			else p.checkpoint_number = $-1
			end
		end

		local info = ZE2.Checkpoints[p.checkpoint_number]
		P_SetOrigin(p.mo, info.x*FU, info.y*FU, info.z*FU)
		p.mo.angle = FixedAngle(info.angle*FRACUNIT)

		p.mo.flags2 = $ & ~MF2_TWOD -- get out
		CONS_Printf(p, "\130Teleported to checkpoint number \128"..p.checkpoint_number)
	end
end