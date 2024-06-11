local function fixedfromstring(str)
    local nsign, intstr, fracstr, esign, exp = string.match(str, "([+-]?)(%d*)%.?(%d*)[eE]?([-+]?)(%d*)")

    esign = (esign == "-") and -1 or 1
    nsign = (nsign == "-") and -1 or 1

    exp = (tonumber(exp) or 0) * esign

    local numstr = intstr .. fracstr
    local point = #intstr + exp

    intstr = numstr:sub(1, point)
    fracstr = numstr:sub(point + 1)

    local frac = 0

    while #fracstr > 0 do
        local digit = tonumber(fracstr:sub(-1))
        frac = (frac + digit * FRACUNIT) / 10
        fracstr = fracstr:sub(1, -2)
    end

    local int = tonumber(intstr) or 0

    if int > FRACUNIT then
        return nsign == -1 and INT32_MIN or INT32_MAX
    end

    return nsign * (int * FRACUNIT + frac)
end

rawset(_G, "fixedfromstring", fixedfromstring)