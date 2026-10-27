-- TODO: Finish it
local function BlockedCollision(self, source, target, line, mobj)
	if not target or not target.valid then return end
	if not source or not source.valid or not source.player or not source.player.valid then return end

	local player = source.player
	if player.spectator then return end

	player.ze2.marker_x, player.ze2.marker_y, player.ze2.marker_z = target.x, target.y, target.z
	player.ze2.marker_tics = 20 * TICRATE
end

local function Tick(self, source, target)
	if not target or not target.valid then return end
	if not source or not source.valid or not source.player or not source.player.valid then
		P_KillMobj(target)
		return
	end

	local range = 256
	local x, y, z = target.x, target.y, target.x
	for i = 0, range do
		if target.momx or target.momy then
			P_XYMovement(target)
			if not target.valid then
				break
			end
		end

		if target.momz then
			P_ZMovement(target)
			if not target.valid then
				break
			end

			if (target.z == target.floorz or target.z + target.height == target.ceilingz) then
				local player = source.player
				if not player.spectator then
					player.ze2.marker_x, player.ze2.marker_y, player.ze2.marker_z = target.x, target.y, target.z
					player.ze2.marker_tics = 15 * TICRATE
				end
				P_KillMobj(target)
				break
			end
		end

		if (not target.valid) or (x == target.x and y == target.y and z == target.z) then
			break
		end
	end
end

local missile_marker_cast =
xSlinger.registerMissile("MARKER_CAST", {
	speed = 16*FRACUNIT,
	displayname = "Rail Ring",
	state = S_INVISIBLE,
	deathstate = S_NULL,
	deathsound = sfx_none,
	radius = 1*FRACUNIT,
	height = 1*FRACUNIT,
	addflags = MF_NOCLIPTHING|MF_NOGRAVITY,
	blocked = BlockedCollision,
	tick = Tick
})

local function PlayerThink(player)
	if player.spectator then return end

	local game = ZE2.Game
	local pv = player.ze2
	local pmo = player.mo
    if not pmo or not pmo.valid then return end

	if (player.ze2.marker_tics > 0) then
		player.ze2.marker_tics = player.ze2.marker_tics - 1
		if (player.ze2.marker_tics <= 0) then
			player.ze2.marker_tics = 0
			player.ze2.marker_x, player.ze2.marker_y, player.ze2.marker_z = 0, 0, 0
		end
	end

    if (player.cmd.buttons & BT_CUSTOM3) and (player.cmd.buttons & BT_ATTACK) and not (player.lastbuttons & BT_ATTACK) then
		local marker = xSlinger.SpawnMissile({
			source = pmo,
			type = "MARKER_CAST",
			angle = pmo.angle,
			allow_aim = true,
			flags2 = MF2_DONTDRAW,
		})
		
		marker.flags = marker.flags | MF_NOCLIPTHING
		player.lastbuttons = $|BT_ATTACK
		player.cmd.buttons = $ & ~BT_ATTACK
	end
end

addHook("PreThinkFrame", function() ---@param player player_t
	for player in players.iterate do
		PlayerThink(player)
	end
end)