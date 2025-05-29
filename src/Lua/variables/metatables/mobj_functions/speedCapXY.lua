local function doBrakesXY(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
end

return function(self, limit, factor)
	local spd = R_PointToDist2(0,0,self.momx,self.momy)
	
	if spd > limit
		if factor == nil
			factor = FixedDiv(limit, spd)
		end
		
		doBrakesXY(self, factor)
		return factor
	end
end