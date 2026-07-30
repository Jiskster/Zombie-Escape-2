addHook("MobjThinker", function(mo)
    if (leveltime % 20 == 0) then return end
    if not (mo and mo.valid) then return end
    if not mo.infectionfx then return end

    local x = P_RandomRange(- mo.radius / FU, mo.radius / FU)
    local y = P_RandomRange(- mo.radius / FU, mo.radius / FU)
    local z = P_RandomRange(0, (mo.height / FU) / 3 * 2)

    local infectparticle = P_SpawnMobjFromMobj(mo, x * FU, y * FU, z * FU, MT_THOK)
    infectparticle.state = S_SPINBOBERT_FIRE_TRAIL1
    infectparticle.colorized = true
    infectparticle.color = mo.color
    infectparticle.alpha = FU / 2
    infectparticle.blendmode = AST_ADD
    infectparticle.tics = 10
    P_SetObjectMomZ(infectparticle, P_RandomRange(2, 5) * FU)

    mo.infectionfx = $ - 1
end, MT_PLAYER)
