local POP_IN_MAX = 5
local pop_in = POP_IN_MAX

return "Checkpoint", function(v, player)
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