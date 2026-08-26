-- [ Accessible Skin Colors ] --

ZE2.AccessibleSkinColors = {}

local accessible_skincolors = ZE2.AccessibleSkinColors
local insert = table.insert

--Gets a random accessible skin color
function ZE2.GetRandomSkinColor()
    return R_GetColorByName(accessible_skincolors[P_RandomRange(1, #accessible_skincolors)])
end

--Update list when ZE2 is loaded and when other addons loads
local function UpdateSkinColors() --If new accessible skincolors are found
	for i = 1, #skincolors - 1 do
		if accessible_skincolors[i] then continue end --Is already on the list? skip
		if not skincolors[i].accessible then continue end --Is not accessible? skip
		insert(accessible_skincolors, skincolors[i].name)
	end
end
UpdateSkinColors(); addHook("AddonLoaded", UpdateSkinColors)

-- [ Lock Player ] --

function ZE2.lockPlayer(player)
    if not player.mo then return end
	if player.spectator then return end

	local mo = player.mo
	local ztype = player.ze2.zombie_type
	local zc = ZE2.ZombieConfig

	if mo.team == 2 then
		local zskin = "zsonic"
		if (ztype and zc[ztype]) then
			zskin = zc[ztype].skin
		end
		local notzombie = skins[player.skin].name ~= zskin
		if notzombie then
			R_SetPlayerSkin(player, zskin)
		end
	elseif mo.team == 1 then
		local currentskin = skins[player.skin].name
		local badskin = (currentskin == "zsonic")
		local selectedskin = player.ze2.selected_character
		for name,_ in pairs(zc) do
			if currentskin == name then -- if current skin is a blacklisted skin
				badskin = true -- es illegal
				break
			end
		end

		if selectedskin and selectedskin ~= currentskin then
			badskin = true -- bad skin if selected skin is not being worn
		end

		if badskin then
			local newskin = "sonic"

			if selectedskin then
				newskin = selectedskin
			end

			R_SetPlayerSkin(player, newskin)
			player.mo.color = player.skincolor
		end
	end

	if (mo.team == 2 and ztype and zc[ztype]) then
		player.mo.color = zc[ztype].skincolor or SKINCOLOR_ZOMBIE
	end
end

-- [ Reset Player ] --

function ZE2.ResetPlayer(player, set_team, resetinventory, noitems)
	local ze2 = player.ze2
	local xS = player.xSlinger

	local TEAM_SURVIVOR = 1
	local TEAM_ZOMBIE = 2

	local cc = ZE2.SurvivorConfig
	local zc = ZE2.ZombieConfig

	local mo = player.mo

	if not (mo and mo.valid) then
		return end;

	if set_team ~= nil then
		mo.team = set_team
	end

	ZE2.lockPlayer(player) -- To make sure the player is the right skin for the team!

	local team = mo.team

	local skin = mo.skin
	local ztype = ze2.zombie_type

	local config

	if (team == TEAM_SURVIVOR) then
		config = cc[skin]
	elseif (team == TEAM_ZOMBIE) then
		config = zc[ztype]
	end

	ZE2.applyPlayerConfig(player)

	if config then
		mo.scale = config.scale or FRACUNIT
	end

	if team == 1 then
		ze2.zombie_type = "normal"
		xS:inv_set("survivor")
	elseif team == 2 then
		xS:inv_set("zombie")
	end

	ZE2.resetPlayerHealth(player)

	if resetinventory then
		ZE2.setConfigInventory(player, false, noitems)
	end
end

-- [ Skin List ] --

ZE2.blacklisted_characters = {} -- blacklisted characters from showing
ZE2.registered_skins = {}

-- dont blacklist a registered skin or else the game dies
function ZE2.blacklist_skin(skinname)
	ZE2.blacklisted_characters[skinname] = true
	table.insert(ZE2.blacklisted_characters, skinname)
end

ZE2.blacklist_skin("zsonic")

function ZE2.getSkinNames(player, getunlockables)
    local list = {}

	for i=0,#skins do -- for each skin slot
		local foundskin = false -- if the game finds the skin in ZE2.registered_skins

		if not skins[i] then
			continue
		end

		for _,v in ipairs(ZE2.registered_skins) do
			if v == skins[i].name then
				foundskin = true
				break
			end
		end

		-- you failure.
		if not foundskin then
			continue
		end

		local isblacklisted = false
		for _,v in ipairs(ZE2.blacklisted_characters) do
			if v == skins[i].name then
				isblacklisted = true
				break
			end
		end

		if isblacklisted then
			continue
		end

		if getunlockables then
			table.insert(list, skins[i].name)
		else -- Default
			if R_SkinUsable(player, skins[i].name) then
				table.insert(list, skins[i].name)
			end
		end
	end

    return list
end

function ZE2.getSkinNums(player, getunlockables)
    local list = {}

	for i=0,#skins do
		local foundskin = false -- if the game finds the skin in ZE2.registered_skins

		if not skins[i] then
			continue
		end

		for _,v in ipairs(ZE2.registered_skins) do
			if v == skins[i].name then
				foundskin = true
				break
			end
		end

		-- you failure.
		if not foundskin then
			continue
		end

		local isblacklisted = false
		for _,v in ipairs(ZE2.blacklisted_characters) do
			if v == skins[i].name then
				isblacklisted = true
			end
		end

		if isblacklisted then
			continue
		end

		if getunlockables then
			table.insert(list, i)
		else -- Default
			if R_SkinUsable(player, skins[i].name) then
				table.insert(list, i)
			end
		end
	end

    return list
end

-- [ Switch Character ] --

function ZE2.switchCharacter(player, skinname, animation)
	local pmo = player.mo

	if R_SkinUsable(player, skinname) then
		R_SetPlayerSkin(player, skinname)
	else
		R_SetPlayerSkin(player, "sonic")
	end

	ZE2.ResetPlayer(player)
	--S_StartSound(nil, sfx_strpst, player)

	if animation then
		P_SpawnMobj(pmo.x, pmo.y, pmo.z, MT_ZE2_TELEGFX)
	end

	pmo.flags2 = $ & ~MF2_DONTDRAW
	player.pflags = $ & ~PF_INVIS
end