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

local function sound_falldamage(mo)
    S_StopSound(mo)
    if (mo.health <= 0) then
        S_StartSound(mo, sfx_zfalld)
    else
        S_StartSound(mo, ({sfx_zfall1, sfx_zfall2})[P_RandomRange(1, 2)])
    end
end

local METER_UNIT = 64 * FU
ZE2.MIN_FALL_DISTANCE = 7 * METER_UNIT -- distance where you take damage
ZE2.FALL_DAMAGE_AMOUNT = 6
ZE2.MIN_FALL_EXHAUST_DISTANCE = 5 * METER_UNIT -- distance where it takes all your stamina

local function check_falldamage_exhaust(dist, mo, playsound)
	local player = mo.player
	
	if not (player and player.valid) then
		return
	end
	
	local pV = player.ze2
	
	if dist > ZE2.MIN_FALL_EXHAUST_DISTANCE then
		if playsound then
			sound_falldamage(mo)
		end
		
		if displayplayer and displayplayer.valid
		and displayplayer == player then
			for i=1,8 do
				P_StartQuake(6*FU + i*FU, i)
			end
		end
		
		pV:ChangeStamina(-90 * FRACUNIT)
		P_DoSpinDashDust(player)
		
		if dist > ZE2.MIN_FALL_DISTANCE then -- if taking damage
			mo.momx = FU/2
			mo.momy = FU/2
		else -- if not taking damage
			mo.momx = FixedMul($, (FU*6)/8)
			mo.momy = FixedMul($, (FU*6)/8)
		end
	end
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
	if (player.mo.eflags & MFE_TOUCHWATER) or (player.mo.eflags & MFE_UNDERWATER) then
		return
	end

    local fall_distance = (player.ze2.fall_height - player.mo.z)
    if (fall_distance <= ZE2.MIN_FALL_DISTANCE) then
		check_falldamage_exhaust(fall_distance, player.mo, true)
		return 
	end

    local fall_damage = FixedMul(ZE2.FALL_DAMAGE_AMOUNT, FixedDiv(fall_distance, METER_UNIT))
	if (player.mo.team == 2) then
		fall_damage = $ * 8
	end
	
	check_falldamage_exhaust(fall_distance, player.mo, false)
	
    P_DamageMobj(player.mo, nil, nil, fall_damage, 6) -- DMG_FALLDAMAGE = 6

	dropblood(player, fall_damage)

	sound_falldamage(player.mo)
end

addHook("PreThinkFrame", function(player)
    local game = ZE2.Game
	local settings = ZE2.getGametypeSettings()
    if not settings.fall_damage then return end

	for player in players.iterate do
		HandleFalldamage(player)
	end
end)