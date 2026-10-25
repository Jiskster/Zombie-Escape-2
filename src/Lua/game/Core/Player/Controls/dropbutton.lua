addHook("PlayerThink", function(player)
	if (player.cmd.buttons & BT_TOSSFLAG)
	and not (player.lastbuttons & BT_TOSSFLAG) then
		xSlinger.COM_DropHand(player)
	end
end)