freeslot("MT_ZTEXT")
mobjinfo[MT_ZTEXT] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	speed = 0,
	radius = 0,
	height = 0,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOCLIP
}

freeslot("SPR_LOWERCASE_CHARACTERS", "SPR_NUMBER_CHARACTERS", "SPR_SYMBOLS_CHARACTERS", "SPR_UPPERCASE_CHARACTERS")

local CHARACTER_TABLE = {}
local Characters = {
	--Letters (keys 1 - 26)
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
	"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

	--Digits (keys 27 - 36)
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

	--Symbols (keys 37 - 68)
	"!", "#", "$", "%", "&", "'", "(", ")", "*", "+", ", ", "-", ".", "/",
	":", ";", "<", "=", ">", "?", "@", "[", "\\", "]", "^", "_", "`", "{",
	"|", "}", "~", " "
}
-- Capital and Lower letters
for i = 1, 26  do
	CHARACTER_TABLE[Characters[i]] = {sprite = SPR_UPPERCASE_CHARACTERS, frame = i-1}
	CHARACTER_TABLE[string.lower(Characters[i])] = {sprite = SPR_LOWERCASE_CHARACTERS, frame = i-1}
end
-- Digits
for i = 27, 36 do CHARACTER_TABLE[Characters[i]] = {sprite = SPR_NUMBER_CHARACTERS, frame = i-27} end
-- Symbols
for i = 37, 68 do CHARACTER_TABLE[Characters[i]] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = i-37} end

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

    local length = (8 * string.len(ClearText(mobj.text))) * FU
	local offset = 0 -- left, by default
	if (mobj.textalign == 1) then -- center
		offset = FixedMul(length, FU / 2)
	elseif (mobj.textalign == 2) then -- right
		offset = length - (8 * FU)
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

	local mobj = P_SpawnMobj(x, y, z, MT_ZTEXT)
	mobj.text = text
	mobj.textalign = align
	mobj.moveabletext = moveable
	if (duration > 0) then
		mobj.fuse = duration
	end
	return mobj
end
rawset(_G, "Lugent_SpawnWorldText", Lugent_SpawnWorldText)