local cv_fov = CV_FindVar("fov")
local function GetFOV()
	if isdedicatedserver then
		return 1
	end
	return FixedDiv(cv_fov.value, 90*FU)
end

return function(player)
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
end