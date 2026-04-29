local width = 14
local cv_fov
local function GetFOV()
	if isdedicatedserver then
		return 1
	end

	if not cv_fov then
		cv_fov = CV_FindVar("fov")
	end

	return FixedDiv(cv_fov.value, 90*FU)
end

return function(self, numbers, properties, damage)
	local player = self.player

	damage = tostring($)
	local str_len = string.len(damage)

	local scale = FixedDiv(R_PointToDist(properties.x,properties.y), properties.radius * 10)
	scale = max($, properties.scale * 2)
	scale = FixedMul($, GetFOV())
	scale = $/2

	local offset = FixedMul((str_len*width)*FU, scale) / 2

	local work = offset
	local angle = R_PointToAngle(properties.x,properties.y) - ANGLE_90

	/*
	do
		local test = P_SpawnMobj(
			properties.x + P_ReturnThrustX(nil, angle, work + (str_len*width*scale)),
			properties.x + P_ReturnThrustY(nil, angle, work + (str_len*width*scale)),
			properties.z + properties.height,
			MT_RAY
		)

		--try swapping the to the other side?
		if not P_CheckSight(test, self.mo) then
			angle = R_PointToAngle(properties.x,properties.y) + ANGLE_90
			work = -$
		end

		if (test and test.valid) then P_RemoveMobj(test) end
	end
	*/

	for i = 1,str_len do
		local n = string.sub(damage,i,i)
		local frame = tonumber(n)

		local num = numbers[i]
		if not (num and num.valid) then
			table.remove(numbers, i)
			continue
		end
		if (num.flags & MF_NOGRAVITY) then
			local offset = 0
			if properties.tics then
				local animation = properties.animation
				if animation == i
				and not num.nu_anim then
					num.nu_offset = 6*FU
					num.nu_anim = true
				else
					num.nu_offset = max($ - FixedDiv(6*FU, FU*3), 0)
				end
			end

			P_MoveOrigin(num,
				properties.x + P_ReturnThrustX(nil, angle, work),
				properties.y + P_ReturnThrustY(nil, angle, work),
				properties.z + properties.height + FixedMul((num.nu_offset or 0), scale)
			)
		end

		num.sprite = SPR_ZE2_DAMAGENUMBER
		num.frame = (frame)|FF_FULLBRIGHT
		num.scale = scale

		if num.fuse == TICRATE*2/3 then
			num.flags = $ &~MF_NOGRAVITY

			P_SetObjectMomZ(num, num.nu_momz)
			P_Thrust(num, angle, num.nu_thrust)
		end

		num.renderflags = $|RF_NOCOLORMAPS
		num.drawonlyforplayer = player
		num.dispoffset = 100

		work = $ + width*scale
	end
end