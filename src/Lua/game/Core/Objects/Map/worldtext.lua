-- Author: Lugent

--Object definition
freeslot("MT_WORLDTEXT")
mobjinfo[MT_WORLDTEXT] = {
	--$Title World Text
	--$Sprite LETRAR
	--$Category Utilities
	--$Angled true
	--$WallSprite true
	--$StringArg0 "String"
	--$StringArg0ToolTip "The text to display.\n\nUse |n to insert a newline.\nUse ^0 though ^f to change color in a Lua/SOC way.\nUse |c[<color>] to change color to a skincolor (can be vanilla or custom). Ex.: |c[red]"
	--$Arg0 "Text Alignment"
	--$Arg0Type 11
	--$Arg0Default 0
	--$Arg0Tooltip "The type of text alignment"
	--$Arg0Enum { 0 = "Left"; 1 = "Center"; 2 = "Right"; }
	--$Arg1 "Duration (Tics)"
	--$Arg1Type 0
	--$Arg1Default 0
	--$Arg1Tooltip "Duration in tics before expiring\n 0 = infinite"
	--$Arg2 "Dynamic?"
	--$Arg2Type 11
	--$Arg2Default 0
	--$Arg2Tooltip "Makes the text dynamic to allow Lua for changing the position, angle and/or text of this object?\n\nNOTICE: Do not have too many dynamic texts or it will slow down and/or crash the game"
	--$Arg2Enum { 0 = "No"; 1 = "Yes"; }
	doomednum = 9999,
	spawnstate = S_INVISIBLE,
	radius = 0,
	height = 0,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOCLIP
}

freeslot("MT_WORLDTEXT_CHARACTER")
mobjinfo[MT_WORLDTEXT_CHARACTER] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
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

local CHARACTER_WIDTH = 8 * FU
local CHARACTER_HEIGHT = 8 * FU

local COLOR_TABLE = {
	["\x80"] = SKINCOLOR_WHITE,
	["\x81"] = SKINCOLOR_MAGENTA,
	["\x82"] = SKINCOLOR_YELLOW,
	["\x83"] = SKINCOLOR_GREEN,
	["\x84"] = SKINCOLOR_BLUE,
	["\x85"] = SKINCOLOR_PEPPER,
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

---@param text string
---@return string, any
local function ClearText(text)
	text = text:gsub("\x80", ""):gsub("\x81", ""):gsub("\x82", ""):gsub("\x83", ""):gsub("\x84", ""):gsub("\x85", ""):gsub("\x86", ""):gsub("\x87", ""):gsub("\x88", ""):gsub("\x89", ""):gsub("\x8A", ""):gsub("\x8B", ""):gsub("\x8C", ""):gsub("\x8D", ""):gsub("\x8E", ""):gsub("\x8F", "")

	local realtext = ""
	local index = 0
	while true do
		if (index > string.len(text)) then break end

		local character = string.sub(text, index, index)
		if (character == "|") then
			local next = string.sub(text, index + 1, index + 2)
			if (next == "c[") then
				local start = index + 3
				local name = "|c["
				while true do
					if (start > string.len(text)) then break end

					local char = string.sub(text, start, start)
					name = name .. char
					if (char == "]") then
						break
					end
					start = start + 1
				end
				text = string.sub(text, index + string.len(name))
				index = 0
				continue
			end
		end
		realtext = realtext .. character
		index = index + 1
	end
	return realtext
end

---@param mobj mobj_t
local function RemoveText(mobj)
	mobj.characters = mobj.characters or {}
	for index = #mobj.characters, 1, -1 do
		P_RemoveMobj(mobj.characters[index])
		table.remove(mobj.characters, index)
	end
end

---@param mobj mobj_t
---@param parent mobj_t
local function OffsetText(mobj, parent)
	local x = parent.x
	local y = parent.y
	local z = parent.z

	local positionX = FixedMul(mobj.positionx, parent.scale)
	local positionY = FixedMul(mobj.positiony, parent.scale)

	x = x + P_ReturnThrustX(nil, parent.angle, positionX)
	y = y + P_ReturnThrustY(nil, parent.angle, positionX)
	z = z - positionY -- reversed to reflect actual logic

	P_MoveOrigin(mobj, x, y, z)
	mobj.angle = parent.angle
	mobj.scale = parent.scale
	mobj.dispoffset = parent.dispoffset
	mobj.momx = parent.momx
	mobj.momy = parent.momy
	mobj.momz = parent.momz
	mobj.alpha = parent.alpha
end

local function CreateText(mobj)
    if mobj.characters then
		RemoveText(mobj)
	end
	mobj.characters = {}

	local strings = {}
	local lengths = {}
	for line in string.gmatch(mobj.text, "[^\r\n]+") do
		local clearline = ClearText(line)
		table.insert(strings, line)
		table.insert(lengths, CHARACTER_WIDTH * (#clearline - 1))
	end

	local offsety = -CHARACTER_HEIGHT * (#strings - 1)
	local color = SKINCOLOR_WHITE
	for layer, line in ipairs(strings) do
		local length = lengths[layer]
		local align = max(min(FU, mobj.align_text), 0)
		print(align)
		local offsetx = -FixedMul(length, align)
		local skip = 0
		for index = 1, #line, 1 do
			if skip then
				skip = skip - 1
				continue
			end

			local text = string.sub(line, index, index)
			if not text then continue end

			if COLOR_TABLE[text] then
				color = COLOR_TABLE[text]
				continue
			end

			if (text == "|") then
				local next = string.sub(line, index + 1, index + 2)
				if (next == "c[") then
					local start = index + 3
					local name = ""
					local ended = false
					skip = 2
					while true do
						if (start > string.len(line)) then break end

						local char = string.sub(line, start, start)
						if (char == "]") then
							skip = skip + 1
							ended = true
							break
						end
						name = name .. char
						start = start + 1
					end
					skip = skip + string.len(name)

					local disp = "|c[" .. name
					if ended then
						disp = disp .. "]"
					end
					lengths[layer] = lengths[layer] - CHARACTER_WIDTH * (#disp - 1)

					local candidate = R_GetColorByName(name)
					if candidate then
						color = candidate
					end
					continue
				end
			end

			local x = offsetx
			local y = offsety
			local character = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_WORLDTEXT_CHARACTER)
			if not character or not character.valid then continue end

			character.sprite, character.frame = CHARACTER_TABLE[text].sprite, CHARACTER_TABLE[text].frame
			character.color = color
			character.renderflags = RF_NOCOLORMAPS|RF_FULLBRIGHT|RF_PAPERSPRITE
			character.flags = mobj.flags
			character.angle = mobj.angle
			character.scale = mobj.scale
			character.drawonlyforplayer = mobj.drawonlyforplayer
			character.dontdrawforviewmobj = mobj.dontdrawforviewmobj
			character.alpha = mobj.alpha
			character.positionx = x
			character.positiony = y
			offsetx = offsetx + CHARACTER_WIDTH
			table.insert(mobj.characters, character)
			OffsetText(character, mobj)
		end
		offsety = offsety + CHARACTER_HEIGHT
	end
end

---@param mobj mobj_t
local function MoveText(mobj)
	mobj.characters = mobj.characters or {}
	for index, character in ipairs(mobj.characters) do
		if not character or not character.valid then continue end
		OffsetText(character, mobj)
	end
end

addHook("MapThingSpawn", function (mobj, thing)
	if not mobj or not mobj.valid then return end

	local text = thing.stringargs[0]
	local align = thing.args[0]
	local duration = thing.args[1]
	local dynamic = thing.args[2]

	local index = 1
	local actual_text = ""
	while true do
		if (index > string.len(text)) then
			break
		end

		local character = string.sub(text, index, index)
		if (character == "^") then
			local next = string.sub(text, index + 1, index + 1)
			if (next == "^") then
				actual_text = actual_text .. character
				index = index + 1
				continue
			elseif NUMBER_TO_COLOR[next:upper()] then
				actual_text = actual_text .. NUMBER_TO_COLOR[next:upper()]
				index = index + 2
				continue
			end
		elseif (character == "|") then
			local next = string.sub(text, index + 1, index + 1)
			if (next == "|") then
				actual_text = actual_text .. character
				index = index + 1
				continue
			elseif (next == "n") then
				actual_text = actual_text .. "\n"
				index = index + 2
				continue
			end
		end
		actual_text = actual_text .. character
		index = index + 1
	end

	if (align == 1) then
		align = FU / 2
	elseif (align == 2) then
		align = FU
	end

	mobj.text = actual_text
	mobj.align_text = align
	mobj.dynamic_text = dynamic
	if (duration > 0) then
		mobj.fuse = duration
	end
end, MT_WORLDTEXT)

addHook("MobjThinker", function(mobj)
	if not mobj or not mobj.valid then return end

	if (mobj.text ~= mobj.textparsed) then
		mobj.textparsed = mobj.text
		CreateText(mobj)
	end

	if mobj.dynamic_text then
		MoveText(mobj)
	end
end, MT_WORLDTEXT)

addHook("MobjFuse", function(mobj)
	RemoveText(mobj)
end, MT_WORLDTEXT)

addHook("MobjRemoved", function(mobj)
	RemoveText(mobj)
end, MT_WORLDTEXT)

--- Spawns a 3D text via mobjs using a master mobj which controls the text, enabling moveable allows it to be dynamic instead of static
---@param x fixed_t
---@param y fixed_t
---@param z fixed_t
---@param text string
---@param align fixed_t?
---@param dynamic boolean?
---@return mobj_t?
local function SpawnWorldText(x, y, z, text, align, dynamic)
	if (x == nil) or (y == nil) or (z == nil) then
		error("Attempted to spawn a world text without a valid position", 2)
		return
	end

	if not text or (string.len(text) <= 0) then
		error("Attempted to spawn a world text without any text", 2)
		return
	end

	local mobj = P_SpawnMobj(x, y, z, MT_WORLDTEXT)
	mobj.text = text
	mobj.align_text = align or 0
	mobj.dynamic_text = dynamic or false
	return mobj
end
rawset(_G, "SpawnWorldText", SpawnWorldText)