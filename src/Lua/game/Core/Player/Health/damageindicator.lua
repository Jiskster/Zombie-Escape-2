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
		if (indicator.source ~= source) then continue end
		if not indicator.text or not indicator.text.valid then continue end
		indicator.text.cusval = indicator.text.cusval + damage
		ChangeWorldText(indicator.text, tostring(indicator.text.cusval), FU / 2, true)
		indicator.text.fuse = TICRATE * 5
		return
	end

	local direction = R_PointToAngle(source.x, source.y)
	local x = P_ReturnThrustX(source, direction, 64 * FU)
	local y = P_ReturnThrustY(source, direction, 64 * FU)
	local z = source.height * 2
	local text = SpawnWorldText(source.x + x, source.y + y, source.z + z, tostring(damage), FU / 2, true)
	text.angle = direction - ANGLE_90
	text.momx = source.momx
	text.momy = source.momy
	text.momz = source.momz
	text.oradius = source.radius
	text.oscale = source.scale
	text.drawonlyforplayer = player
	text.cusval = damage
	text.fuse = TICRATE * 5
	table.insert(player.ze2.damage_text, {text = text, source = source})
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
		local target = indicator.source
		local text = indicator.text
		if not text or not text.valid then
			table.remove(player.ze2.damage_text, index)
			continue
		end

		if not target or not target.valid or (target.health <= 0) then
			local direction = R_PointToAngle(text.x, text.y)
			text.angle = direction - ANGLE_90
			text.momx = 0
			text.momy = 0
			if (text.fuse <= TICRATE) then
				text.momz = text.momz - (FU / 2)
				text.alpha = FixedDiv(text.fuse * FU, TICRATE * FU)
			else
				text.momz = 0
			end

			local scale = FixedDiv(R_PointToDist(text.x, text.y), text.oradius * 10)
			scale = max(scale, text.oscale * 2)
			scale = FixedMul(scale, GetFOV())
			scale = scale / 2
			text.scale = scale
			continue
		end

		local direction = R_PointToAngle(target.x, target.y)
		local x = P_ReturnThrustX(target, direction, 64 * FU)
		local y = P_ReturnThrustY(target, direction, 64 * FU)
		local z = target.height * 2
		text.angle = direction - ANGLE_90
		text.momx = target.momx
		text.momy = target.momy
		text.momz = target.momz
		if (text.fuse <= TICRATE) then
			text.alpha = FixedDiv(text.fuse * FU, TICRATE * FU)
		end

		local scale = FixedDiv(R_PointToDist(target.x, target.y), target.radius * 10)
		scale = max(scale, target.scale * 2)
		scale = FixedMul(scale, GetFOV())
		scale = scale / 2
		text.scale = scale
		text.oradius = target.radius
		text.oscale = target.scale
		P_MoveOrigin(text, target.x + x, target.y + y, target.z + z)
	end
end)