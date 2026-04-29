rawset(_G, 'L_ZCollide', function(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end)

-- code by buggiethebug
rawset(_G, "P_FlyTo", function(mo, fx, fy, fz, sped, addques) --A very useful command honestly.
    if mo.valid then
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - mo.z)
        if flyto < 1 then
            flyto = 1
        end
        --local anglesucc = R_PointToAngle2(mo.x, mo.y, fx, fy)
        
        if addques then
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        end    
    end    
end)

rawset(_G,"L_DoBrakes", function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end)

rawset(_G,"L_DoBrakesXY", function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
end)

rawset(_G,"L_SpeedCap", function(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd = R_PointToDist2(0,0,spd_xy,mo.momz)
	if spd > limit then
		if factor == nil then
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakes(mo,factor)
		return factor
	end
end)

rawset(_G,"L_SpeedCapXY", function(mo,limit,factor)
	local spd = R_PointToDist2(0,0,mo.momx,mo.momy)
	if spd > limit then
		if factor == nil then
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakesXY(mo,factor)
		return factor
	end
end)

rawset(_G, "L_FixedDecimal", function(str,maxdecimal)
	if str == nil or tostring(str) == nil then
		return "<invalid FixedDecimal>"
	end
	local number = tonumber(str)
	maxdecimal = ($ ~= nil) and $ or 3
	if tonumber(str) == 0 then return '0' end
	local polarity = abs(number)/number
	local str_polarity = (polarity < 0) and '-' or ''
	local str_whole = tostring(abs(number/FRACUNIT))
	if maxdecimal == 0 then
		return str_polarity..str_whole
	end
	local decimal = number%FRACUNIT
	decimal = FRACUNIT + $
	decimal = FixedMul($,FRACUNIT*10^maxdecimal)
	decimal = $>>FRACBITS
	local str_decimal = string.sub(decimal,2)
	return str_polarity..str_whole..'.'..str_decimal
end)

--because im LAZY.
--gets @actor's @type of z for @targ
rawset(_G,"GetActorZ",function(actor,targ,type)
	if type == nil then type = 1 end
	if not (actor and actor.valid) then return 0 end
	if not (targ and targ.valid) then return 0 end
	
	local flip = P_MobjFlip(actor)
	
	--get z
	if type == 1 then
		if flip == 1 then
			return actor.z
		else
			return actor.z+actor.height-targ.height
		end
	--get top z
	elseif type == 2 then
		if flip == 1 then
			return actor.z+actor.height
		else
			return actor.z-targ.height
		end
	end
	return 0
end)

rawset(_G,"ReturnTrigAngles",function(angle)
	return cos(angle),sin(angle)
end)