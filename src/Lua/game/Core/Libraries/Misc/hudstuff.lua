local function TableReverse(target)
	local start, length = 1, #target
    if (type(target) == "userdata") then
        start, length = 0, 15
    end

	local result = {}
	for index = length, start, -1 do
		result[length - index + 1] = target[index]
	end
	return result
end

local function FadeAmount(amount)
    local value = ease.linear(amount, 10, 0)
    if (value > 0) and (value < 10) then
        return value << FF_TRANSSHIFT
    end
    return 0
end

---@param v videolib
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param offset integer
---@param amount fixed_t
---@param color integer|skincolor_t|table
---@param flags integer
---@param alpha fixed_t
rawset(_G, "V_DrawBar", function(v, x, y, width, height, offset, amount, color, flags, alpha)
	local vertical
	local reverse
	local distorsion
	local nofading
    local colortable
    local colortable_index, colortable_length = 1, 1
    if (type(color) == "userdata") then
        colortable = color
        colortable_index, colortable_length = 0, 15
    elseif (type(color) == "table") then
        colortable = color
        colortable_index, colortable_length = 1, #colortable
    end

    if (flags & V_FLIP) then
        if (colortable ~= nil) then
            colortable = TableReverse(colortable)
            colortable_index, colortable_length = 1, #colortable
        end
        flags = flags & ~(V_FLIP)
    end

	if (flags & V_MONOSPACE) then
		nofading = true
		flags = flags & ~(V_MONOSPACE)
	end

	if (flags & V_MAGENTAMAP) then
		vertical = true
		flags = flags & ~(V_MAGENTAMAP)
	end

	if (flags & V_YELLOWMAP) then
		reverse = true
		flags = flags & ~(V_YELLOWMAP)
	end

	local fraction
	local start
	local finish
	local step
	local goal = width
	if vertical then
		goal = height
	end

	if reverse then
		start = goal
		finish = 0
		step = -1
		fraction = min(FixedDiv(FU - amount, FU) * goal, goal * FU)
	else
		fraction = min(FixedDiv(amount, FU) * goal, goal * FU)
		start = 0
		finish = goal
		step = 1
	end

    for index = start, finish, step do
		--print(string.format("%s: index = %.1f; fraction = %.1f", index, index * FU, fraction))
		if reverse then
			if ((index * FU) < fraction) then break end
		else
			if ((index * FU) >= fraction) then break end
		end

        local fade = min(FixedMul(alpha, max(fraction - (index * FU), 0)), alpha)
		if nofading then
			fade = alpha
		end

        local transparency = FadeAmount(fade)
        local truecolor
        if (colortable ~= nil) then
			local colorindex = index
			local colormax = width
			if vertical then
				colormax = height
			end

            local colorfraction = max(min(FixedInt(FixedRound(FixedDiv(colorindex * FU, colormax * FU) * colortable_length)), colortable_length), colortable_index)
            truecolor = colortable[colorfraction]
        else
            truecolor = color
        end

		if vertical then
			v.drawFill(x, y + ((offset + 1) * index), width, 1, truecolor|flags|transparency)
		else
			v.drawFill(x + ((offset + 1) * index), y, 1, height, truecolor|flags|transparency)
		end
    end
end)