-- Push out players from Thwomp
-- Arg 1: Sector tag where it takes effect
-- Arg 2: Push Out / Thrust speed
-- Arg 3: Push epicenter X
-- Arg 4: Push epicenter Y

addHook("LinedefExecute", function(line, mo, sector)
    for p in players.iterate() do
        if not (p.mo and p.mo.valid and p.mo.health) then continue end

        local pmo = p.mo
        local psector = pmo.subsector.sector
        local angle = R_PointToAngle2(line.args[2] * FU, line.args[3] * FU, pmo.x, pmo.y)

        if not psector.taglist:has(line.args[0]) then continue end

        P_DoPlayerPain(p)
        P_SetObjectMomZ(pmo, 7 * FU, false)
        P_InstaThrust(pmo, angle, line.args[1] * FU)
    end
end, "M_PUSHOUT")