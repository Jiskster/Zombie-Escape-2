ZE2.damagefadehud = function(v, player)
	if gametype ~= GT_ZE2 then return end
	
	if not player["ze2_info"].damage_fade then 
		return 
	end
	
	local damage_fade = player["ze2_info"].damage_fade
	local damage_fade_max = player["ze2_info"].damage_fade_max
	
	local redpatch = v.cachePatch("Z_DMGFADE")
	local hs = v.width()*FRACUNIT
	local div = FU - FixedDiv(damage_fade*FU, damage_fade_max*FU)
	local ese = ease.outsine(div, 1, 9)
	
	v.drawScaled(0, 0, hs, redpatch, V_SNAPTOLEFT|V_SNAPTOTOP|V_NOSCALEPATCH|(ese<<V_ALPHASHIFT))
end