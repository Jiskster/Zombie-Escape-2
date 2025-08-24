local KB = ZE2.Knockback

return function()
	if gamestate ~= GS_LEVEL then return end
	--clean up
	for k,mo in ipairs(KB.list)
		if not (
			(mo and mo.valid)
			and (mo.health)
			and (mo.knockback ~= nil)
			and (#mo.knockback.list)
		) then
			if (mo and mo.valid and mo.knockback) then
				mo.knockback = nil
			end
			
			table.remove(KB.list,k)
		end
	end
	
	--iterate
	for k,mo in ipairs(KB.list) do
		local thrust = {x = 0; y = 0}
		local knocked = false
		
		local grounded = P_IsObjectOnGround(mo)
		local k = mo.knockback
		
		-- Clean up inactive knockback tables.
		for id,t in ipairs(k.list) do
			if not t.tics then table.remove(k.list, id); end
		end
		
		for id,t in ipairs(k.list) do
			local force = ease.outcubic(FU - (t.frac * t.tics), t.thrust, 0)
			if grounded then
				force = FixedDiv($, mo.friction)
			end
			thrust.x = $ + P_ReturnThrustX(nil,t.angle, force)
			thrust.y = $ + P_ReturnThrustY(nil,t.angle, force)
			t.tics = $ - 1
			if not t.didit then
				local frac = FU/2
				mo.momx,mo.momy = FixedMul($1,frac),FixedMul($2,frac)
				t.didit = true
			end
			knocked = true
		end
		
		local accspeed = FixedDiv(abs(FixedHypot(mo.momx,mo.momy)), mo.scale)
		if knocked then
			P_TryMove(mo,
				mo.x + thrust.x,
				mo.y + thrust.y,
				true
			)
			local cap = 25*FU
			if accspeed > cap then
				local newspeed = accspeed - FixedDiv(accspeed - cap, 8*FU)
				newspeed = FixedMul($,mo.scale)
				local ang = R_PointToAngle2(0,0,mo.momx,mo.momy)
				mo.momx = P_ReturnThrustX(nil,ang,newspeed)
				mo.momy = P_ReturnThrustY(nil,ang,newspeed)
			end
		end
		
		k.wait = max($-1, 0)
	end
end