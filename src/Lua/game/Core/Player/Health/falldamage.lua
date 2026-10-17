freeslot("sfx_zfall1", "sfx_zfall2", "sfx_zfalld")
sfxinfo[sfx_zfall1].caption = "Fall damage"
sfxinfo[sfx_zfall2].caption = "Fall damage"
sfxinfo[sfx_zfalld].caption = "Dying"

local function dropblood(player, damage)
    if not player.mo or not player.mo.valid then return end
    if (damage <= 4) then return end -- Yeah no I'll not let you spam it lol

    local pmo = player.mo
    local dmg_strength = (damage * 10) / 5
    local blood_count = max(2, min(dmg_strength, 200))
    Z_DoDroplet(pmo, blood_count)
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

	dropblood(player, fall_damage)

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