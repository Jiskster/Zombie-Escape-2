addHook("LinedefExecute", function(line, mo, sector)
    if not (mo and mo.valid and mo.health) then return end
    if mo.team != 2 then return end -- Only Zombies

    P_LinedefExecute(73, mo) -- Replace the number with the teleport trigger tag
end, "ZOMBTELE")