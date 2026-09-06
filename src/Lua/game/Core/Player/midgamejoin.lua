local holdtime = 0
local holdtimedelay = 0
local MAXHOLDTIME = TICRATE + 13
local MAXHOLDTIMEDELAY = TICRATE

local function showOutOfGameText(player)
	if not player.ze2.injoinqueue_delay then -- using this variable because why not
		chatprintf(player, "\x82" .. "* You are dead! Wait until the game is over!", true)
		player.ze2.injoinqueue_delay = 1*TICRATE
	end
end

local function toggleQueue(player)
	if player.ze2.outofgame then
		showOutOfGameText(player)
	else
		if not player.ze2.injoinqueue_delay then
			player.ze2.injoinqueue = not $

			if player.ze2.injoinqueue then
				chatprintf(player, "\x82" .. "* Game is currently ongoing. " .. "\x83" .. "Added to join queue.", true)
			else
				chatprintf(player, "\x82" .. "* Game is currently ongoing. " .. "\x85" .. "Removed from join queue.", true)
			end

			player.ze2.injoinqueue_delay = 1*TICRATE
		end
	end
end

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

addHook("PlayerCmd", function(player, cmd)
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
end)

local roundresetting = false
addHook("NetVars", function(net)
	roundresetting = net($)
end)
addHook("MapChange", function()
	roundresetting = false
end)

addHook("TeamSwitch", function(player, team, fromspectators, autobalance, scramble)
	local game = ZE2.Game
	
	if fromspectators then
		local player_count = 0

		for p in players.iterate do
			if p.mo and p.mo.valid and p.mo.health and not p.spectator then
				player_count = $ + 1
			end
		end

		player.ze2.was_spectating = true -- Disable special zombie types when unspectating

		if game.active then
			if player_count == 1 then
				if not game.ended then
					if player.ze2.outofgame then
						showOutOfGameText(player)
						return false
					end
					
					return true
				else
					toggleQueue(player)
					return false
				end
			elseif player_count > 0 then
				toggleQueue(player)
				
				return false
			elseif not roundresetting then -- reset whole match
				roundresetting = true
				player.ze2.injoinqueue = true
				G_SetCustomExitVars(gamemap, 2)
				G_ExitLevel()
				return false
			end
		end
	end

	-- NEVER have pregamemenu_active on as spectator
	if team == 0 then
		if game.active and not game.ended then
			if player.mo and player.mo.valid then
				if player.mo.team == 1 then
					player.ze2.karma = min($ + 250, ZE2.MaxKarma)
				elseif player.mo.team == 2 then
					player.ze2.karma = min($ + 380, ZE2.MaxKarma)
				end
			end
		end
		
		player.ze2.injoinqueue = false
	end
end)

addHook("PlayerThink", function(player)
	if player.ze2.injoinqueue_delay then
		player.ze2.injoinqueue_delay = max(0, $ - 1)
	end
end)