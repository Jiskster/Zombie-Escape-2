local holdtime = 0
local holdtimedelay = 0
local MAXHOLDTIME = TICRATE + 13
local MAXHOLDTIMEDELAY = TICRATE

addHook("HUD", function(v, player)
	if (not player.spectator) or (player.ze2.outofgame) then
		return
	end

	local text_x = 160
	local text_y = 170
	local flags = V_SNAPTOBOTTOM
	local barflags = V_SNAPTOBOTTOM|V_30TRANS
	local holdtime2 = (holdtime*3)/2 -- holdtime2 is for changing length of bar
	local cyanpatch = v.cachePatch("Z_CYANDOT")
	if holdtime then
		flags = $ | V_50TRANS

		v.drawStretched(text_x*FU - (holdtime2*FU)/2, text_y*FU + 10*FU, holdtime2*FU, FU, cyanpatch, barflags)
	end
	v.drawString(text_x, text_y, "Hold " .. "\x82" .. "FIRE" .. "\x80" .. " to join", flags, "thin-center")
end)


return function(player, cmd)
	if holdtimedelay then
		holdtimedelay = $ - 1
	end

	if player.spectator then
		if (cmd.buttons & BT_ATTACK) and not holdtimedelay
		and not player.ze2.outofgame then
			holdtime = $ + 1
		else
			holdtime = 0
		end

		cmd.buttons = $ & (~BT_ATTACK)

		if holdtime == MAXHOLDTIME then
			cmd.buttons = $ | BT_ATTACK
			holdtimedelay = MAXHOLDTIMEDELAY
			holdtime = 0
		end
	end
end