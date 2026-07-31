-- Blood droplets will spawn when a zombie gets hit... or whatever use you want to do with this.

------- Main object -------

freeslot(
    "MT_ZOMB_DROPLET",
    "S_ZDROPLET",
    "S_ZDROPLET_DEATH"
)

-- Anything for that 10% optimization is received lol
local xS_addHook = xSlinger.addHook
local MT_ZOMB_DROPLET = MT_ZOMB_DROPLET
local S_ZDROPLET = S_ZDROPLET
local S_ZDROPLET_DEATH = S_ZDROPLET_DEATH
local MT_PLAYER = MT_PLAYER
-- Droplet properties
local droplt_scale = FU * 4 / 9
local translation = "goop_to_blood"
local sprite_flags = FF_TRANS30|FF_SEMIBRIGHT

mobjinfo[MT_ZOMB_DROPLET] = {
    doomednum = -1,
    spawnstate = S_ZDROPLET,
    deathstate = S_ZDROPLET_DEATH,
    radius = 4*FRACUNIT,
    height = 4*FRACUNIT,
    flags = MF_SLIDEME|MF_SCENERY|MF_RUNSPAWNFUNC|MF_NOBLOCKMAP
}

states[S_ZDROPLET] = {SPR_GOOP, A|sprite_flags, -1, function(mo) -- A good oportunity to set up the blood droplet here
    mo.spritexscale = droplt_scale
    mo.spriteyscale = droplt_scale
    mo.translation = translation
    P_SetObjectMomZ(mo, FU * 3)
end, nil, nil, S_ZDROPLET}

states[S_ZDROPLET_DEATH] = {SPR_GOOP, C|sprite_flags, 2 * TICRATE, function(mo)
    mo.spritexscale = $ * 8 / 6 -- Scale it a bit more when it touches the ground.
    mo.spriteyscale = $ * 8 / 6
    mo.momx = 0
    mo.momy = 0
end, 0, 0, S_NULL}

------- Droplet behavior -------

local function zombie_droplet_hitground(mo) -- MobjHitFloor my beloved where are you?! TODO: Replace this with MobjHitFloor in v2.2.16
    if not mo.valid then return end
    if not P_IsObjectOnGround(mo) then return end

    if mo.state != S_ZDROPLET_DEATH then
        mo.state = S_ZDROPLET_DEATH
    end
end

local function Z_DoDroplet(mo, blood_quantity)
    local pradius = mo.radius / FU -- Idk, P_RandomRange throws a warning about big numbers so I had to divide by FU first
    local pheight = mo.height / FU

    for i = 1, blood_quantity do
        local spawnpos_xy = P_RandomRange(0, pradius / 2) * FU
        local spawnpos_z = P_RandomRange(pheight / 4, pheight / 3 * 2) * FU
        local drop_rad = FixedAngle(P_RandomRange(0, 360))
        local droplt = P_SpawnMobjFromMobj(mo, spawnpos_xy, spawnpos_xy, spawnpos_z, MT_ZOMB_DROPLET)

        P_InstaThrust(droplt, (drop_rad * FU), FixedMul(P_RandomRange(2, 7) * FU, mo.scale))
    end
end

local function zombie_dropblood(p, inf, src, dmg, damagetype)
    if not (p.mo and p.mo.valid) then return end
    if p.mo.team != 2 then return end
    if dmg <= 4 then return end -- Yeah no I'll not let you spam it lol
    local pmo = p.mo

    local dmg_strenght = (dmg * 10) / 100
    local blood_count = max(2, min(dmg_strenght, 30))

    Z_DoDroplet(pmo, blood_count)
end

local function zombie_death(mo) -- Drop blood also on death duh
    if mo.team != 2 then return end
    Z_DoDroplet(mo, 20)
end

-- Now we hook everything
xS_addHook("OnPlayerDamage", zombie_dropblood)
addHook("MobjThinker", zombie_droplet_hitground, MT_ZOMB_DROPLET)
addHook("MobjDeath", zombie_death, MT_PLAYER)