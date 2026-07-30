addHook("MobjThinker", function(mo)
    if (leveltime % 5 == 0) then return end
    if not (mo and mo.valid) then return end
    if not mo.infectionfx then return end

    local x = P_RandomRange(- mo.radius / FU, mo.radius / FU)
    local y = P_RandomRange(- mo.radius / FU, mo.radius / FU)
    local z = P_RandomRange(0, (mo.height / FU) / 3 * 2)
    local fx_time = TICRATE / 2 -- Should be paired up with the timer on ZombifyPlayer.lua
    local ratio = FixedDiv(mo.infectionfx * FU, fx_time * FU)

    local infectparticle = P_SpawnMobjFromMobj(mo, x * FU, y * FU, z * FU, MT_THOK)
    infectparticle.spritexscale = FixedMul(ratio, FU)
    infectparticle.spriteyscale = FixedMul(ratio, FU)
    infectparticle.state = S_SPINBOBERT_FIRE_TRAIL1
    infectparticle.colorized = true
    infectparticle.color = mo.color
    infectparticle.blendmode = AST_SUBTRACT
    infectparticle.renderflags = RF_FULLBRIGHT
    infectparticle.tics = 10
    P_SetObjectMomZ(infectparticle, P_RandomRange(2, 5) * FU)

    mo.infectionfx = $ - 1
end, MT_PLAYER)
