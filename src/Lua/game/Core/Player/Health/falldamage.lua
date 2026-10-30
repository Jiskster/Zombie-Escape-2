freeslot("sfx_zfall1", "sfx_zfall2", "sfx_zfalld")
sfxinfo[sfx_zfall1].caption = "Falling damage"
sfxinfo[sfx_zfall2].caption = "Falling damage"
sfxinfo[sfx_zfalld].caption = "Dying"

local METER_UNIT = 64 * FU
ZE2.MIN_FALL_DISTANCE = 7 * METER_UNIT -- distance where you take damage
ZE2.FALL_DAMAGE_AMOUNT = 6

ZE2.MIN_FALL_EXHAUST_DISTANCE = 5 * METER_UNIT -- distance where it takes all your stamina
ZE2.FALL_EXHAUST_AMOUNT = 90 * FU

---@param player player_t
---@param damage number
local function DropBlood(player, damage)
    if not player.mo or not player.mo.valid then return end
    if (damage <= 4) then return end -- Yeah no I'll not let you spam it lol

    local pmo = player.mo
    local dmg_strength = (damage * 10) / 5
    local blood_count = max(2, min(dmg_strength, 200))
    Z_DoDroplet(pmo, blood_count)
end

---@param mobj mobj_t
local function FallDamageSound(mobj)
    S_StopSound(mobj)

    if (mobj.health <= 0) then
        S_StartSound(mobj, sfx_zfalld)
		return
	end
    S_StartSound(mobj, ({sfx_zfall1, sfx_zfall2})[P_RandomRange(1, 2)])
end

---@param player player_t
---@param dist fixed_t
---@param playsound boolean
local function HandleFallExhaust(player, mobj, dist, playsound)
	local pV = player.ze2
	if (dist <= ZE2.MIN_FALL_EXHAUST_DISTANCE) then return end
	if playsound then
		FallDamageSound(mobj)
	end

	if displayplayer and displayplayer.valid and (displayplayer == player) then
		for times = 1, 8 do
			P_StartQuake(6 * FU + times * FU, times)
		end
	end
	pV:ChangeStamina(-ZE2.FALL_EXHAUST_AMOUNT)
	P_DoSpinDashDust(player)

	if (dist <= ZE2.MIN_FALL_DISTANCE) then -- if not taking damage
		mobj.momx = FixedMul(mobj.momx, (FU * 6) / 8)
		mobj.momy = FixedMul(mobj.momy, (FU * 6) / 8)
		return
	end

	-- if taking damage
	mobj.momx = FU / 2
	mobj.momy = FU / 2
end

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

    local distance = (player.ze2.fall_height - player.mo.z)
    if (distance <= ZE2.MIN_FALL_DISTANCE) then
		HandleFallExhaust(player, player.mo, distance, true)
		return
	end

    local fall_damage = FixedMul(ZE2.FALL_DAMAGE_AMOUNT, FixedDiv(distance, METER_UNIT))
	if (player.mo.team == 2) then
		fall_damage = fall_damage * 8
	end

	if (player.mo.eflags & MFE_TOUCHWATER) or (player.mo.eflags & MFE_UNDERWATER) then
		fall_damage = fall_damage / 3
	end

	HandleFallExhaust(player, player.mo, distance, false)
    P_DamageMobj(player.mo, nil, nil, fall_damage, ZE2.DMG_FALLDAMAGE)
	DropBlood(player, fall_damage)
	FallDamageSound(player.mo)
end

addHook("PreThinkFrame", function()
	local settings = ZE2.getGametypeSettings()
    if not settings.fall_damage then return end

	for player in players.iterate do
		if not player or not player.valid then continue end
		HandleFalldamage(player)
	end
end)