freeslot("MT_ZTEXT")
mobjinfo[MT_ZTEXT] = {doomednum = -1, spawnstate = S_INVISIBLE, speed = 0, radius = 0, height = 0, flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOCLIP}

freeslot("SPR_LOWERCASE_CHARACTERS", "SPR_NUMBER_CHARACTERS", "SPR_SYMBOLS_CHARACTERS", "SPR_UPPERCASE_CHARACTERS")

local CHARACTER_TABLE = {
	-- Capital letters
	["A"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 0},
	["B"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 1},
	["C"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 2},
	["D"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 3},
	["E"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 4},
	["F"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 5},
	["G"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 6},
	["H"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 7},
	["I"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 8},
	["J"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 9},
	["K"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 10},
	["L"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 11},
	["M"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 12},
	["N"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 13},
	["O"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 14},
	["P"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 15},
	["Q"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 16},
	["R"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 17},
	["S"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 18},
	["T"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 19},
	["U"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 20},
	["V"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 21},
	["W"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 22},
	["X"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 23},
	["Y"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 24},
	["Z"] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = 25},

	-- Lower letters
	["a"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 0},
	["b"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 1},
	["c"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 2},
	["d"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 3},
	["e"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 4},
	["f"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 5},
	["g"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 6},
	["h"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 7},
	["i"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 8},
	["j"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 9},
	["k"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 10},
	["l"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 11},
	["m"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 12},
	["n"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 13},
	["o"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 14},
	["p"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 15},
	["q"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 16},
	["r"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 17},
	["s"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 18},
	["t"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 19},
	["u"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 20},
	["v"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 21},
	["w"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 22},
	["x"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 23},
	["y"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 24},
	["z"] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = 25},

	-- Digits
	["0"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 0},
	["1"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 1},
	["2"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 2},
	["3"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 3},
	["4"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 4},
	["5"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 5},
	["6"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 6},
	["7"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 7},
	["8"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 8},
	["9"] = {sprite = SPR_NUMBER_CHARACTERS, frame = 9},

	-- Symbols
	["!"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 0},
	["#"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 2},
	["$"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 3},
	["%"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 4},
	["&"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 5},
	["'"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 6},
	["("] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 7},
	[")"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 8},
	["*"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 9},
	["+"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 10},
	[","] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 11},
	["-"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 12},
	["."] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 13},
	["/"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 14},
	[":"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 15},
	[";"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 16},
	["<"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 17},
	["="] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 18},
	[">"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 19},
	["?"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 20},
	["@"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 21},
	["["] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 22},
	["\\"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 23},
	["]"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 24},
	["^"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 25},
	["_"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 26},
	["`"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 27},
	["{"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 28},
	["|"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 29},
	["}"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 30},
	["~"] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 31},
	[" "] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = 32}
}

local COLOR_TABLE = {
	["\x80"] = SKINCOLOR_WHITE,
	["\x81"] = SKINCOLOR_MAGENTA,
	["\x82"] = SKINCOLOR_YELLOW,
	["\x83"] = SKINCOLOR_GREEN,
	["\x84"] = SKINCOLOR_BLUE,
	["\x85"] = SKINCOLOR_RED,
	["\x86"] = SKINCOLOR_GREY,
	["\x87"] = SKINCOLOR_ORANGE,
	["\x88"] = SKINCOLOR_SKY,
	["\x89"] = SKINCOLOR_PURPLE,
	["\x8A"] = SKINCOLOR_AQUA,
	["\x8B"] = SKINCOLOR_PERIDOT,
	["\x8C"] = SKINCOLOR_AZURE,
	["\x8D"] = SKINCOLOR_BROWN,
	["\x8E"] = SKINCOLOR_ROSY,
	["\x8F"] = SKINCOLOR_BLACK
}

local function ClearText(text)
	return text:gsub("\x80", ""):gsub("\x81", ""):gsub("\x82", ""):gsub("\x83", ""):gsub("\x84", ""):gsub("\x85", ""):gsub("\x86", ""):gsub("\x87", ""):gsub("\x88", ""):gsub("\x89", ""):gsub("\x8A", ""):gsub("\x8B", ""):gsub("\x8C", ""):gsub("\x8D", ""):gsub("\x8E", ""):gsub("\x8F", "")
end

local function ParseText(mobj)
	if mobj.parsed then return end

	mobj.characters = {}

	local offset = 0
	if (mobj.textalign == 1) then
		offset = (8 * (string.len(ClearText(mobj.text)) / 2)) * FU
	elseif (mobj.textalign == 2) then
		offset = (8 * (string.len(ClearText(mobj.text)) - 1)) * FU
	end
	mobj.textoffset = offset

	local count = 0
	local color = SKINCOLOR_WHITE
	for index = 1, string.len(mobj.text), 1 do
		local text = string.sub(mobj.text, index, index)
		if not text then continue end

		if COLOR_TABLE[text] then
			color = COLOR_TABLE[text]
			continue
		end

		local offsetx = P_ReturnThrustX(mobj, mobj.angle, mobj.textoffset)
		local offsety = P_ReturnThrustY(mobj, mobj.angle, mobj.textoffset)
		local x = mobj.x - offsetx + P_ReturnThrustX(mobj, mobj.angle, (8 * count) * FU)
		local y = mobj.y - offsety + P_ReturnThrustY(mobj, mobj.angle, (8 * count) * FU)
		local character = P_SpawnMobj(x, y, mobj.z, MT_ZVISUAL)
		character.renderflags = RF_NOCOLORMAPS|RF_FULLBRIGHT|RF_PAPERSPRITE
		character.angle = mobj.angle
		character.sprite, character.frame = CHARACTER_TABLE[text].sprite, CHARACTER_TABLE[text].frame
		character.color = color
		count = count + 1
		table.insert(mobj.characters, character)
	end
	mobj.parsed = true
end

local function HandleText(mobj)
	if not mobj.moveabletext then return end -- needed in case is a static text

	mobj.characters = mobj.characters or {}
	for index, character in ipairs(mobj.characters) do
		if not character or not character.valid then continue end

		local offsetx = P_ReturnThrustX(mobj, mobj.angle, mobj.textoffset)
		local offsety = P_ReturnThrustY(mobj, mobj.angle, mobj.textoffset)
		local x = mobj.x - offsetx + P_ReturnThrustX(mobj, mobj.angle, (8 * (index - 1)) * FU)
		local y = mobj.y - offsety + P_ReturnThrustY(mobj, mobj.angle, (8 * (index - 1)) * FU)
		character.angle = mobj.angle
		P_SetOrigin(character, x, y, mobj.z)
	end
end

addHook("MobjThinker", function(mobj)
	if not mobj or not mobj.valid then return end

	ParseText(mobj)
	HandleText(mobj)
end, MT_ZTEXT)

addHook("MobjFuse", function(mobj)
	mobj.characters = mobj.characters or {}
	for _, other in ipairs(mobj.characters) do
		if not other or not other.valid then continue end

		P_RemoveMobj(other)
	end
end, MT_ZTEXT)

addHook("MobjRemoved", function(mobj)
	mobj.characters = mobj.characters or {}
	for _, other in ipairs(mobj.characters) do
		if not other or not other.valid then continue end

		P_RemoveMobj(other)
	end
end, MT_ZTEXT)

local function Lugent_SpawnWorldText(x, y, z, text, align, duration, moveable)
	if (x == nil) or (y == nil) or (z == nil) then
		error("Attempted to spawn a world text without an valid position", 2)
		return
	end

	if not text or (string.len(text) <= 0) then
		error("Attempted to spawn a world text without any text", 2)
		return
	end

	if (align == nil) or (tonumber(align) == nil) then
		error("Attempted to spawn a world text without any alignment", 2)
		return
	end

	if (align < 0) or (align > 2) then
		error("Attempted to spawn a world text with an invalid alignment (0 = left, 1 = center, 2 = right)", 2)
		return
	end

	if (duration == nil) or (tonumber(duration) == nil) then duration = 0 end
	if (moveable == nil) or (type(moveable) ~= "boolean") then moveable = false end

	local mobj = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z + (64 * FU), MT_ZTEXT)
	mobj.text = text
	mobj.textalign = align
	mobj.moveabletext = moveable
	if (duration > 0) then
		mobj.fuse = duration
	end
	return mobj
end
rawset(_G, "Lugent_SpawnWorldText", Lugent_SpawnWorldText)