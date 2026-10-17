freeslot("sfx_zfall1", "sfx_zfall2", "sfx_zfalld")
sfxinfo[sfx_zfall1].caption = "Fall damage"
sfxinfo[sfx_zfall2].caption = "Fall damage"
sfxinfo[sfx_zfalld].caption = "Dying"

local function P_RandomFixedRange(a,b)
	return a + FixedMul((b - a), P_RandomFixed())
end

local function P_3DThrust(mo, h_ang, v_ang, speed)
	local t = {
		x = FixedMul(cos(h_ang), cos(v_ang)),
		y = FixedMul(sin(h_ang), cos(v_ang)),
		z = sin(v_ang)
	}
	mo.momx = $ + FixedMul(speed, t.x)
	mo.momy = $ + FixedMul(speed, t.y)
	mo.momz = $ + FixedMul(speed, t.z)
end

local METER_UNIT = 64 * FU
ZE2.MIN_FALL_DISTANCE = 5 * METER_UNIT
ZE2.FALL_DAMAGE_AMOUNT = 2

---@param player player_t
local function HandleFalldamage(player)
    if not player.mo or not player.mo.valid then return end
	if not player.mo.health then return end

    if not player.ze2.isFalling then
        if (player.mo.momz > 0) then return end
        if P_IsObjectOnGround(player.mo) then return end

        player.ze2.isFalling = true
        player.ze2.fall_height = player.mo.z
    end

    if (player.mo.momz > 0) then
        player.ze2.isFalling = false
        return
    end

    if not P_IsObjectOnGround(player.mo) then return end

    player.ze2.isFalling = false
	if (player.mo.eflags & MFE_TOUCHWATER) or (player.mo.eflags & MFE_UNDERWATER) then
		return
	end

    local fall_distance = (player.ze2.fall_height - player.mo.z)
    if (fall_distance <= ZE2.MIN_FALL_DISTANCE) then return end

    local fall_damage = FixedMul(ZE2.FALL_DAMAGE_AMOUNT, FixedDiv(fall_distance, METER_UNIT))
    P_DamageMobj(player.mo, nil, nil, fall_damage, 6) -- DMG_FALLDAMAGE = 6
	
	local count = fall_damage / 3
	local angstep = FixedDiv(360 * FRACUNIT, count * FRACUNIT)
	local dist = FixedDiv(8 * player.mo.scale, 3*FU)
	for OUTER = 1, 3 do
		local d = dist * OUTER
		
		for i = 1, count do
			local ha = FixedAngle(angstep * i)
			local va = FixedAngle(P_RandomFixedRange(13 * OUTER * FRACUNIT, 28 * OUTER * FRACUNIT))
			local b = P_SpawnMobjFromMobj(player.mo,
				P_ReturnThrustX(ha, d),
				P_ReturnThrustY(ha, d),
				FRACUNIT, MT_ZOMB_DROPLET
			)
			b.scale = (b.scale * 3)/2
			P_3DThrust(b, ha,va, FixedMul(P_RandomFixedRange(6*FU, 12*FU), player.mo.scale))
		end
	end

    S_StopSound(player.mo)
    if (player.mo.health <= 0) then
        S_StartSound(player.mo, sfx_zfalld)
    else
        S_StartSound(player.mo, ({sfx_zfall1, sfx_zfall2})[P_RandomRange(1, 2)])
    end
end

addHook("PreThinkFrame", function(player)
    local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
    if not settings.fall_damage then return end

	for player in players.iterate do
		HandleFalldamage(player)
	end
end)