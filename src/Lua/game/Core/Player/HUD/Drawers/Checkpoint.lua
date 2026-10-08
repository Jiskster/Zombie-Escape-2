local POP_IN_MAX = 5
local pop_in = POP_IN_MAX

local function drawCatchUp(v, player)
	local checkpoint_timer = player.ze2.checkpoint_timer
	local x = 160*FU
	local y = 140*FU
	local p_starpost = v.cachePatch("Z_STARPOST")
	local flags = V_SNAPTOBOTTOM
	
	local div = FU - FixedDiv(pop_in, POP_IN_MAX) -- counting up
	y = $ + ease.outquint(div, 4*FU, 0)
	
	if checkpoint_timer then
		v.drawScaled(x - (p_starpost.width*FU)/2, y, FU, p_starpost, flags|V_50TRANS)
		v.drawString(x, y + 8*FU, checkpoint_timer/TICRATE, flags, "thin-fixed-center")
		v.drawString(x, y - 4*FU, "Catching Up In:", flags|V_ALLOWLOWERCASE, "thin-fixed-center")
		
		pop_in = max(0, $ - 1)
	else
		pop_in = POP_IN_MAX
	end
end

local function drawW2S(v, player)
	local checkpoint_timer = player.ze2.checkpoint_timer
	--local checkpoint_number = player.ze2.checkpoint_number
	local latest_checkpoint_number = 0
	
	local mobj = player.mo
	
	if not (mobj and mobj.valid) then
		return
	end
	
	if (mobj.team == 1) then
		latest_checkpoint_number = ZE2.LatestSurvivorCheckpoint
	else
		latest_checkpoint_number = ZE2.LatestZombieCheckpoint
	end
	
	if not (checkpoint_timer and latest_checkpoint_number) then
		return
	end
	
	local checkpoint = ZE2.Checkpoints[latest_checkpoint_number]
	local cmobj = checkpoint.mobj
	
	if not (checkpoint and cmobj and cmobj.valid) then
		return
	end
	
	local result = xS_GetScreenCoords(v, player, camera, {
		x = cmobj.x;
		y = cmobj.y;
		z = cmobj.z + (cmobj.height*3)/2;
		eflags = cmobj.eflags;
	})
	
	if not (result and result.onscreen) then
		return
	end
	
	local p_starpost = v.cachePatch("Z_STARPOST")
	local p_starpost_scale = result.scale*2
	local x = result.x - FixedMul(p_starpost.width*FU, p_starpost_scale)/2
	local y = result.y + sin(FixedAngle(leveltime*FU*10))/4
	
	if p_starpost_scale > 0 then
		v.drawScaled(x, y, p_starpost_scale, p_starpost) 
	end
end

return "Checkpoint", function(v, player)
	drawCatchUp(v, player)
	drawW2S(v, player) -- the hud thats on the checkpoint object in world
end