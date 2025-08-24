local KB = ZE2.Knockback

KB.addKnockback = function(mo, tics, angle, thrust)
	if not mo.knockback then
		KB.initKnockback(mo) 
	end
	
	if mo.knockback.wait then 
		return end;
		
	table.insert(mo.knockback.list, {
		tics = tics,
		angle = angle,
		thrust = thrust,
		frac = (FU / tics),
	})
	
	mo.knockback.wait = 3
	
	local wasinlist = false
	for id,othermo in ipairs(KB.list) do
		if othermo == mo
			wasinlist = true
			break
		end
	end
	
	if not wasinlist then
		table.insert(KB.list, mo)
	end
	
	-- DEBUG: print("KB.addKnockback: "..leveltime)
end