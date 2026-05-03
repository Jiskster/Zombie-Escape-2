-- Useful to give a randomized color between accessible skin colors only.

ZE2.AccessibleSkinColors = {}

local accessible_skincolors = ZE2.AccessibleSkinColors
local insert = table.insert

--Gets a random accessible skin color
ZE2.GetRandomSkinColor = function()
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