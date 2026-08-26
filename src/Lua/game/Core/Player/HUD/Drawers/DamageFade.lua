return "DamageFade", function(v, player)
	if not player.ze2.damage_fade then return end

	local damage_fade = player.ze2.damage_fade
	local damage_fade_max = player.ze2.damage_fade_max
	local div = FU - FixedDiv(damage_fade*FU, damage_fade_max*FU)
	local ese = ease.outsine(div, 1, 9)

	v.draw(0,0,v.cachePatch("ZE2_BLUDOVLY"),V_ADD|(ese<<V_ALPHASHIFT))
	if ese <= 3 then
		v.draw(0,0,v.cachePatch("ZE2_BLUDOVLY"),V_ADD|((ese/2)<<V_ALPHASHIFT))
	end
end