---@param player player_t
---@param attacker mobj_t?
local function GetAssistant(player, attacker)
	if not attacker or not attacker.valid then return end

	local pV = player.ze2
	if (pV.recent_attackers == nil) then return end
	if (#pV.recent_attackers <= 0) then return end

	for index = #pV.recent_attackers, 1, -1 do
		local data = pV.recent_attackers[index]
		if (leveltime > data.time) then continue end
		if (attacker == data.source) then continue end
		return data.source
	end
	return
end

---@param source mobj_t
---@return string, string
function ZE2.GetMobjNameAndColor(source)
	if not source or not source.valid then
		return "", ""
	end

	if source.player and source.player.valid then
		local sourcecolor = (source.team == 1) and "\x84" or "\x85"
		return sourcecolor, source.player.name
	elseif source.info and source.info.npc_name then
		return "\x82", source.info.npc_name
	elseif source.iteminfo and source.iteminfo.displayname then
		return "\x82", source.iteminfo.displayname
	elseif source.missiledef and source.missiledef.displayname then
		return "\x82", source.missiledef.displayname
	end
	return "", ""
end

---@param source mobj_t
---@param inflictor mobj_t?
---@return string, string
local function GetSourceNameWithInflictor(source, inflictor)
	local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(source)
	if inflictor and inflictor.valid and ((inflictor ~= source) or (inflictor.target and inflictor.target.valid and not (inflictor.flags & (MF_BOSS|MF_ENEMY)))) then
		local theircolor, theirname = ZE2.GetMobjNameAndColor(inflictor)
		if (theirname:len() > 0) then -- valid name
			sourcename = sourcecolor .. sourcename .. "\x83" .. "'s " .. theircolor .. theirname
		end
	end
	return sourcecolor, sourcename
end

local DEATH_TYPES = {
	[ZE2.DMG_BLOODBOMB] = "%s%s%s ran out of blood",
	[ZE2.DMG_FALLDAMAGE] = "%s%s%s hit the ground too hard",
	[DMG_WATER] = "%s%s%s dissolved in chemicals",
	[DMG_FIRE] = "%s%s%s burned into ashes",
	[DMG_ELECTRIC] = "%s%s%s electrocuted",
	[DMG_SPIKE] = "%s%s%s spiked to death",
	[DMG_NUKE] = "%s%s%s went nuclear",
	[DMG_DROWNED] = "%s%s%s drowned",
	[DMG_SPACEDROWN] = "%s%s%s couldn't breathe",
	[DMG_DEATHPIT] = "%s%s%s fell into a bottomless pit",
	[DMG_CRUSHED] = "%s%s%s was crushed"
}

---@param assist mobj_t
---@return boolean
local function ValidAssist(assist)
	return (assist and assist.valid and ((assist.player and assist.player.valid) or (assist.info and assist.info.npc_name))) and true or false
end

---@param player player_t
---@param inflictor mobj_t
---@param source mobj_t
---@param damagetype integer
function ZE2.SendDeathMessage(player, inflictor, source, damagetype)
	local assist = GetAssistant(player, source or inflictor)
	local message = ""
	local playercolor = (player.mo.team == 1) and "\x84" or "\x85"

	if source and source.valid and not (source.flags & (MF_BOSS|MF_ENEMY)) and not (source.player and source.player.valid) and source.target and source.target.valid then -- usually projectiles's target
		local mysource = source.target
		while (mysource.target and mysource.target.valid) do
			mysource = mysource.target
		end
		source = (mysource and mysource.valid) and mysource or source
	end

	if source and source.valid then
		if (source.flags & MF_FIRE) then
			message = string.format("%s%s%s burned into ashes", playercolor, player.name, "\x83")
			if ValidAssist(assist) then
				local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
				local oldmessage = message
				message = string.format("%s%s while trying to escape %s%s", oldmessage, "\x83", sourcecolor, sourcename)
			end
		elseif source and source.player then
			local sourcecolor, sourcename = GetSourceNameWithInflictor(source, inflictor)
			message = string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", sourcecolor, sourcename)
			if ValidAssist(assist) then
				local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
				local oldmessage = message
				message = string.format("%s%s with help from %s%s", oldmessage, "\x83", sourcecolor, sourcename)
			end
		elseif source.info and source.info.npc_name then
			local sourcecolor, sourcename = GetSourceNameWithInflictor(source, inflictor)
			if not (source.flags & (MF_BOSS|MF_ENEMY)) and not (source.player and source.player.valid) and source.target and source.target.valid and source.target.player and source.target.player.valid then
				local theircolor, theirname = ZE2.GetMobjNameAndColor(source.target)
				if (theirname:len() > 0) then
					sourcename = theircolor .. theirname .. "\x83" .. "'s " .. sourcecolor .. sourcename
				end
			end

			message = string.format("%s%s%s has been killed by %s%s", playercolor, player.name, "\x83", sourcecolor, sourcename)
			if ValidAssist(assist) then
				local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
				local oldmessage = message
				message = string.format("%s%s with help from %s%s", oldmessage, "\x83", sourcecolor, sourcename)
			end
		else
			message = string.format("%s%s%s died", playercolor, player.name, "\x83")
			if ValidAssist(assist) then
				local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
				message = string.format("%s%s%s while trying to escape %s%s", playercolor, player.name, "\x83", sourcecolor, sourcename)
			end
		end
	elseif DEATH_TYPES[damagetype] then
		message = string.format(DEATH_TYPES[damagetype], playercolor, player.name, "\x83")
		if ValidAssist(assist) then
			local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
			local oldmessage = message
			message = string.format("%s%s while trying to escape %s%s", oldmessage, "\x83", sourcecolor, sourcename)
		end
	elseif (player.mo.eflags & MFE_TOUCHLAVA) then
		message = string.format("%s%s%s discovered the floor was lava", playercolor, player.name, "\x83")
		if ValidAssist(assist) then
			local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
			local oldmessage = message
			message = string.format("%s%s while trying to escape %s%s", oldmessage, "\x83", sourcecolor, sourcename)
		end
	else
		message = string.format("%s%s%s died", playercolor, player.name, "\x83")
		if ValidAssist(assist) then
			local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(assist)
			message = string.format("%s%s%s was finished off by %s%s", playercolor, player.name, "\x83", sourcecolor, sourcename)
		end
	end
	if (message:len() <= 0) then return end

	print(message)
end

---@param player player_t
---@param inflictor mobj_t
---@param source mobj_t
function ZE2.SendInfectionMessage(player, inflictor, source)
	local message = ""
	local playercolor = "\x84"
	if source and source.valid and source.player and source.player.valid then
		local sourcecolor, sourcename = ZE2.GetMobjNameAndColor(source)
		if inflictor and inflictor.valid and ((inflictor ~= source) or (inflictor.target and inflictor.target.valid)) then
			local theircolor, theirname = ZE2.GetMobjNameAndColor(inflictor)
			if (theirname:len() > 0) then -- valid name
				sourcename = sourcecolor .. sourcename .. "\x83" .. "'s " .. theircolor .. theirname
			end
		end
		message = string.format("%s%s%s has been infected by %s%s", playercolor, player.name, "\x83", sourcecolor, sourcename)
	else
		message = string.format("%s%s%s has been infected", playercolor, player.name, "\x83")
	end
	if (message:len() <= 0) then return end

	print(message)
end