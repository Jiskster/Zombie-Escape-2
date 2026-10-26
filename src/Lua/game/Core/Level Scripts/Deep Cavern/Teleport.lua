addHook("LinedefExecute", function(line, mo, sector)
    if not (mo and mo.valid and mo.health) then return end
    if mo.team != 1 then return end -- Only Survivors

    P_LinedefExecute(63, mo) -- Replace the number with the teleport trigger tag
end, "SECRETSURV")