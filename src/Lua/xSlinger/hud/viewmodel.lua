local itemx, itemy = 0, 0
local itemxo, itemyo = 0, 0
local swingx, swingy = 0, 0
local maxviewanim = 0

addHook("HUD", function(v, player)
	local xS = player.xSlinger
	local hand = xS:hand()
	
	if not xSlinger.visible_huds.viewmodel then
		return end;
	
	if camera.chase then
		return
	end
	
	if not (player.mo and player.mo.valid) then
		return
	end
	
	if not (hand) then
		return
	end
	
	local icon = hand:get("icon", player.mo.skin) -- string
	
	if not icon then
		return
	end
	
	local p_icon = v.cachePatch(icon)
	local scale = FixedDiv(16*FU, p_icon.width*FU)
	
	local vx = (BASEVIDWIDTH - 100) * FRACUNIT
	local vy = (BASEVIDHEIGHT - 60) * FRACUNIT
	local bob = player.bob / 2
	local angle = (leveltime * ANG10)
	local swingx2, swingy2 = 0, 0
	if player.realmo and player.realmo.valid then
		if not P_IsObjectOnGround(player.realmo) then
			bob = player.bob / 4
		end
	end

	swingy2 = FixedMul(bob / 2, -abs(sin(angle)))
	swingx2 = FixedMul(bob / 2, cos(angle))

	swingx = (swingx - swingx2) / 2
	swingy = (swingy - swingy2) / 2

	if xS.viewmobj_animation then
		if xS.viewmobj_animation > maxviewanim then
			maxviewanim = xS.viewmobj_animation
		end
		
		local diff = maxviewanim - xS.viewmobj_animation
		local ese = ease.outquart(FixedDiv(diff, maxviewanim), 42*FU, 0)
		swingy = $ + ese
		swingx = $ - ese/2
	else
		maxviewanim = 0
	end

	v.drawScaled(
		vx + swingx,
		vy + swingy,
		scale*5, -- scale
		p_icon, -- TODO: Use iteminfo_t.hold_icon
		V_SNAPTOBOTTOM|V_SNAPTORIGHT
	)
end)