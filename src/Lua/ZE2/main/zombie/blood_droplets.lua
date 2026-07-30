-- Blood droplets will spawn when a zombie gets hit... or whatever use you want to do with this.

local droplt_scale = FU * 4 / 9

-- Main object
freeslot(
    "MT_ZOMB_DROPLET",
    "S_ZDROPLET",
    "S_ZDROPLET_DEATH"
)

mobjinfo[MT_ZOMB_DROPLET] = {
    doomednum = -1,
    spawnstate = S_ZDROPLET,
    deathstate = S_ZDROPLET_DEATH,
    radius = mobjinfo[MT_GOOP].radius,
    height = mobjinfo[MT_GOOP].height,
    flags = MF_SLIDEME|MF_SCENERY|MF_RUNSPAWNFUNC|MF_NOBLOCKMAP
}

states[S_ZDROPLET] = {SPR_GOOP, A|FF_TRANS30, -1, function(mo) -- A good oportunity to set up the blood droplet here
    mo.spritexscale = droplt_scale
    mo.spriteyscale = droplt_scale
    mo.translation = "goop_to_blood"
    P_SetObjectMomZ(mo, FU * 3)
end, nil, nil, S_ZDROPLET}

states[S_ZDROPLET_DEATH] = {SPR_GOOP, C|FF_TRANS30, 2 * TICRATE, function(mo)
    mo.spritexscale = $ * 8 / 6 -- Scale it a bit more when it touches the ground.
    mo.spriteyscale = $ * 8 / 6
    mo.momx = 0
    mo.momy = 0
end, 0, 0, S_NULL}

addHook("MobjThinker", function(mo) -- MobjHitFloor my beloved where are you?! TODO: Replace this with MobjHitFloor in v2.2.16
    if not (mo and mo.valid) then return end
    if mo.state == mo.info.deathstate then return end
    if mo.state != S_ZDROPLET then return end
    if not P_IsObjectOnGround(mo) then return end

    mo.state = mo.info.deathstate
end, MT_ZOMB_DROPLET)

local function Z_DoDroplet(p, blood_quantity)
    local mo = p.mo


    for i = 1, blood_quantity do
        local pradius = mo.radius / FU -- Idk, P_RandomRange throws a warning about big numbers so I had to divide by FU first
        local pheight = mo.height / FU
        local spawnpos_xy = P_RandomRange(0, pradius / 2) * FU
        local spawnpos_z = P_RandomRange(pheight / 4, pheight / 3 * 2) * FU

        local drop_rad = FixedAngle(P_RandomRange(0, 360))
        local droplt = P_SpawnMobjFromMobj(mo, spawnpos_xy, spawnpos_xy, spawnpos_z, MT_ZOMB_DROPLET)

        P_InstaThrust(droplt, (drop_rad * FU), FixedMul(P_RandomRange(2, 7) * FU, mo.scale))
    end
end

xSlinger.addHook("OnPlayerDamage", function(p, inf, src, dmg, damagetype)
    if not (p.mo and p.mo.valid and p.mo.team == 2) then return end
    if dmg <= 4 then return end -- Yeah no I'll not let you spam it lol

    local dmg_strenght = (dmg * 10) / 100
    local blood_count = max(2, min(dmg_strenght, 30))

    Z_DoDroplet(p, blood_count)
end)

addHook("MobjDeath", function(mo) -- Drop blood also on death duh
    if not (mo and mo.valid and mo.team == 2) then return end

    Z_DoDroplet(mo.player, 20)
end, MT_PLAYER)
