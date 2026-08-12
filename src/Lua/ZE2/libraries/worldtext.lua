--Object definition
freeslot("MT_ZTEXT")
mobjinfo[MT_ZTEXT] = {
	--$Title World Text
	--$Sprite LETRAR
	--$Category Lugent Utilities
	--$Angled true
	--$WallSprite  true
	--$StringArg0 "Text"
	--$StringArg0ToolTip "The text to display"
	--$Arg0 "Alignment"
	--$Arg0Type 11
	--$Arg0Default 0
	--$Arg0Tooltip "The type of text alignment"
	--$Arg0Enum { 0 = "Left"; 1 = "Center"; 2 = "Right"; }
	--$Arg1 "Duration"
	--$Arg1Type 0
	--$Arg1Default 0
	--$Arg1Tooltip "Duration in tics before expiring\n 0 = infinite"
	--$Arg2 "Moveable"
	--$Arg2Type 11
	--$Arg2Default 0
	--$Arg2Tooltip "Allow the text to be manipulated by scripts?\n Both position, rotation and text via Lugent_ChangeWorldText"
	--$Arg2Enum { 0 = "No"; 1 = "Yes"; }
	doomednum = 9999,
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

	--Symbols (keys 37 - 69)
	"!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ", ", "-", ".", "/",
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
for i = 37, 69 do CHARACTER_TABLE[Characters[i]] = {sprite = SPR_SYMBOLS_CHARACTERS, frame = i-37} end

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

local NUMBER_TO_COLOR = {
	["0"] = "\x80",
	["1"] = "\x81",
	["2"] = "\x82",
	["3"] = "\x83",
	["4"] = "\x84",
	["5"] = "\x85",
	["6"] = "\x86",
	["7"] = "\x87",
	["8"] = "\x88",
	["9"] = "\x89",
	["A"] = "\x8A",
	["B"] = "\x8B",
	["C"] = "\x8C",
	["D"] = "\x8D",
	["E"] = "\x8E",
	["F"] = "\x8F"
}

local function ClearText(text)
	return text:gsub("\x80", ""):gsub("\x81", ""):gsub("\x82", ""):gsub("\x83", ""):gsub("\x84", ""):gsub("\x85", ""):gsub("\x86", ""):gsub("\x87", ""):gsub("\x88", ""):gsub("\x89", ""):gsub("\x8A", ""):gsub("\x8B", ""):gsub("\x8C", ""):gsub("\x8D", ""):gsub("\x8E", ""):gsub("\x8F", "")
end

---@param mobj mobj_t
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
	mobj.textoffset = FixedMul(offset, mobj.scale)

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
		local position = FixedMul((8 * count) * FU, mobj.scale)
		local x = (mobj.x - offsetx) + P_ReturnThrustX(mobj, mobj.angle, position)
		local y = (mobj.y - offsety) + P_ReturnThrustY(mobj, mobj.angle, position)
		local character = P_SpawnMobj(x, y, mobj.z, MT_ZVISUAL)
		character.sprite, character.frame = CHARACTER_TABLE[text].sprite, CHARACTER_TABLE[text].frame
		character.color = color
		character.renderflags = RF_NOCOLORMAPS|RF_FULLBRIGHT|RF_PAPERSPRITE
		character.flags = mobj.flags
		character.angle = mobj.angle
		character.scale = mobj.scale
		character.drawonlyforplayer = mobj.drawonlyforplayer
		character.dontdrawforviewmobj = mobj.dontdrawforviewmobj
		character.alpha = mobj.alpha
		count = count + 1
		table.insert(mobj.characters, character)
	end
	mobj.parsed = true
end

---@param mobj mobj_t
local function HandleText(mobj)
	if not mobj.moveabletext then return end -- needed in case is a static text

	mobj.characters = mobj.characters or {}
	for index, character in ipairs(mobj.characters) do
		if not character or not character.valid then continue end

		local offsetx = P_ReturnThrustX(mobj, mobj.angle, mobj.textoffset)
		local offsety = P_ReturnThrustY(mobj, mobj.angle, mobj.textoffset)
		local position = FixedMul((8 * (index - 1)) * FU, mobj.scale)
		local x = (mobj.x - offsetx) + P_ReturnThrustX(mobj, mobj.angle, position)
		local y = (mobj.y - offsety) + P_ReturnThrustY(mobj, mobj.angle, position)
		character.angle = mobj.angle
		character.momx = mobj.momx
		character.momy = mobj.momy
		character.momz = mobj.momz
		character.scale = mobj.scale
		character.drawonlyforplayer = mobj.drawonlyforplayer
		character.dontdrawforviewmobj = mobj.dontdrawforviewmobj
		character.alpha = mobj.alpha
		P_MoveOrigin(character, x, y, mobj.z)
	end
end

addHook("MapThingSpawn", function (mobj, thing)
	if not mobj or not mobj.valid then return end

	local text = thing.stringargs[0]
	local align = thing.args[0]
	local duration = thing.args[1]
	local moveable = thing.args[2]

	local nexttoskip
	local actualtext = ""
	for index = 1, string.len(text), 1 do
		local character = string.sub(text, index, index)
		if (nexttoskip ~= nil) and (character:upper() == nexttoskip:upper()) then
			nexttoskip = nil
			continue
		elseif (character == "^") then
			local next = string.sub(text, index + 1, index + 1)
			if (next == "^") then
				actualtext = actualtext .. character .. next
				nexttoskip = next
				continue
			elseif NUMBER_TO_COLOR[next:upper()] then
				actualtext = actualtext .. NUMBER_TO_COLOR[next:upper()]
				nexttoskip = next
				continue
			end
		end
		actualtext = actualtext .. character
	end

	mobj.text = actualtext
	mobj.textalign = align
	mobj.moveabletext = moveable
	if (duration > 0) then
		mobj.fuse = duration
	end
end, MT_ZTEXT)

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

--- Spawns a 3D text via mobjs using a master mobj which controls the text, enabling moveable allows it to be dynamic instead of static
---@param x fixed_t
---@param y fixed_t
---@param z fixed_t
---@param text string
---@param align
---| 0 Left
---| 1 Center
---| 2 Right
---@param duration tic_t?
---@param moveable boolean?
---@return mobj_t?
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

---@param mobj mobj_t
---@param text string
---@param align
---| 0 Left
---| 1 Center
---| 2 Right
---@param duration tic_t?
---@param moveable boolean?
local function Lugent_ChangeWorldText(mobj, text, align, duration, moveable)
	if not mobj or not mobj.valid then return end

	if not text or (string.len(text) <= 0) then
		error("Attempted to spawn a world text without any text", 2)
		return false
	end

	if (align == nil) or (tonumber(align) == nil) then
		error("Attempted to spawn a world text without any alignment", 2)
		return false
	end

	if (align < 0) or (align > 2) then
		error("Attempted to spawn a world text with an invalid alignment (0 = left, 1 = center, 2 = right)", 2)
		return false
	end

	if (duration == nil) or (tonumber(duration) == nil) then duration = 0 end
	if (moveable == nil) or (type(moveable) ~= "boolean") then moveable = false end

	mobj.characters = mobj.characters or {}
	for _, other in ipairs(mobj.characters) do
		if not other or not other.valid then continue end

		P_RemoveMobj(other)
	end

	mobj.parsed = false
	mobj.text = text
	mobj.textalign = align
	mobj.moveabletext = moveable
	if (duration > 0) then
		mobj.fuse = duration
	end
	return true
end
rawset(_G, "Lugent_ChangeWorldText", Lugent_ChangeWorldText)