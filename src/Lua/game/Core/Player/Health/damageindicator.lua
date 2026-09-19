local cv_fov = CV_FindVar("fov")
local function GetFOV()
	if isdedicatedserver then
		return 1
	end
	return FixedDiv(cv_fov.value, 90*FU)
end

---@param player player_t
---@param source mobj_t
---@param damage integer
function ZE2:AddDamageText(player, source, damage)
	if source.info and source.info.nodamagetext then return end

	player.ze2.damage_text = player.ze2.damage_text or {}
	for index, indicator in ipairs(player.ze2.damage_text) do
		if not indicator.source or not indicator.source.valid then continue end
		if (indicator.source ~= source) then continue end
		indicator.damage = indicator.damage + damage
		indicator.time = 5 * TICRATE
		return
	end

	local x = source.x
	local y = source.y
	local z = source.height * 2
	table.insert(player.ze2.damage_text, {damage = damage, x = x, y = y, z = z, zmom = 0, time = 5 * TICRATE, source = source})
end

xSlinger.addHook("MobjDamage", function(mobj, inf, src, dmg, damagetype)
	local player
	if src and src.valid and src.player and src.player.valid then
		player = src.player
	elseif inf and inf.valid and inf.player and inf.player.valid then
		player = inf.player
	end

	if not player then return end

	ZE2:AddDamageText(player, mobj, dmg)
end)

addHook("PlayerThink", function(player)
	player.ze2.damage_text = player.ze2.damage_text or {}
	for index, indicator in ipairs(player.ze2.damage_text) do
		indicator.time = indicator.time - 1
		if (indicator.time <= 0) then
			table.remove(player.ze2.damage_text, index)
			continue
		end

		local target = indicator.source --[[@as mobj_t?]]
		if not target or not target.valid or (target.health <= 0) then
			if (indicator.time <= TICRATE) then
				indicator.zmom = indicator.zmom - (FU / 2)
				indicator.z = indicator.z + indicator.zmom
			end
			continue
		end

		local x = target.x
		local y = target.y
		local z = target.z + (target.height * 3)
		indicator.x = x
		indicator.y = y
		indicator.z = z
	end
end)