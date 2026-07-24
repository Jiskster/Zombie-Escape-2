local invpos_y = 185*FU
local slot_gap = 20*FU

local function PositionSlot(index, slot, slot_count, slot_gap)
	if not (slot.patch and slot.patch.valid) then
		return end;

	-- Center Slot Position
	slot.x = $ - FixedMul(slot.patch.width*FU, slot.scale)/2
	slot.y = $ - FixedMul(slot.patch.height*FU, slot.scale)/2

	-- Add from the right
	slot.x = $ + (slot_gap) * (index-1)

	-- Center whole inventory
	slot.x = $ - (slot_gap/2) * (slot_count-1)
end

hud.disable("weaponrings")

local itemx, itemy = 0, 0
local itemxo, itemyo = 0, 0
local swingx, swingy = 0, 0
addHook("HUD", function(v, player)
	if (player) and not (player.mo) then
		return
	end

	if not xSlinger.visible_huds.inventory then
		return end;

	local xS = player.xSlinger

	if not xS:inv_get() then
		return
	end

	local hand = xS:hand()

	local slot_count = #xS:inv_get()

	local selected_slot = {
		x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
		y = invpos_y,
		scale = FRACUNIT,
		patch = v.cachePatch("CURWEAP"),
		flags = V_SNAPTOBOTTOM,
		positioned_selection = false, -- Has the selected slot been found to render?
	}

	for i=1, slot_count do
		local iteminfo = xS:slot_get(i)
		local selection = xS.slot

		local item_background = iteminfo:getIndex("background", player.mo.skin)
		local item_background_color = iteminfo:getIndex("background_color", player.mo.skin)
		local item_background_colormap = v.getColormap(nil, item_background_color)

		local slot = {
			x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
			y = invpos_y,
			scale = FRACUNIT,
			patch = nil,
			flags = V_SNAPTOBOTTOM,
		}

		local slot_bg = {
			x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
			y = invpos_y,
			scale = FRACUNIT,
			patch = v.cachePatch(item_background),
			flags = V_SNAPTOBOTTOM,
		}

		local reload_square = xSlinger.deepcopy(slot)
		local firerate_square = xSlinger.deepcopy(slot)

		local item_icon = iteminfo:getIndex("icon", player.mo.skin) --iteminfo.getIndex("icon", player.mo.skin)
		local item_ammo = iteminfo:getIndex("ammo", player.mo.skin)
		local item_count = iteminfo:getIndex("count", player.mo.skin)
		local item_reload_time = iteminfo:getIndex("reload_time", player.mo.skin)
		local item_firerate = iteminfo:getIndex("firerate", player.mo.skin)
		local item_firerate_left = iteminfo:getIndex("firerate_left", player.mo.skin)

		if item_icon then
			slot.patch = v.cachePatch(item_icon)

			local patch = slot.patch

			-- Auto Scale Item
			if patch then
				if patch.width ~= 16 or patch.height ~= 16 then
					slot.scale = FixedDiv(FU, FixedDiv(patch.width*FU, 16*FU))
				end
			end
		end

		if selection == i then
			PositionSlot(i, selected_slot, slot_count, slot_gap)

			selected_slot.positioned_selection = true
		end

		PositionSlot(i, slot, slot_count, slot_gap)
		PositionSlot(i, slot_bg, slot_count, slot_gap)

		-- Draw "Viewnodel"
		if (selection == i) and slot.patch and not camera.chase then
			local vx = (BASEVIDWIDTH - 100) * FRACUNIT
			local vy = (BASEVIDHEIGHT - 60) * FRACUNIT
			local rmomx = player.rmomx
			local rmomy = player.rmomy
			local bob = min((FixedMul(rmomx, rmomx) + FixedMul(rmomy, rmomy)) >> 2, 8 * FRACUNIT)
			local angle = ((256 * leveltime) & 8191) << 19
			local swingx2, swingy2 = 0, 0

			swingx2 = FixedMul(bob, cos(angle))
			angle = ((256 * leveltime) & 4095) << 19
			swingy2 = FixedMul(bob, sin(angle))

			swingx = (swingx - swingx2) / 2
			swingy = (swingy - swingy2) / 2

			if xS.viewmobj_animation then
				swingy = $ + (xS.viewmobj_animation*FU)
				swingx = $ - (xS.viewmobj_animation*FU)
			end

			v.drawScaled(
				vx + swingx,
				vy + swingy,
				slot.scale * 5,
				slot.patch, -- TODO: Use iteminfo_t.hold_icon
				V_SNAPTOBOTTOM|V_SNAPTORIGHT
			)
		end

		-- Draw Item Background
		v.drawScaled(
			slot_bg.x,
			slot_bg.y,
			slot_bg.scale,
			slot_bg.patch,
			slot_bg.flags,
			item_background_colormap
		)

		-- Draw Item
		if slot.patch then
			v.drawScaled(
				slot.x,
				slot.y,
				slot.scale,
				slot.patch,
				slot.flags
			)
		end

		-- [Reload Animation] --
		if selection == i and xS.reload > 0
		and iteminfo.id ~= "" then
			reload_square.scale = FU
			reload_square.patch = v.cachePatch("XSG_GREENSQUARE")

			if item_reload_time then
				reload_square.scale = FU - FixedDiv(xS.reload*FU, item_reload_time*FU)
			end

			PositionSlot(i, reload_square, slot_count, slot_gap)

			v.drawScaled(
				reload_square.x,
				reload_square.y,
				max(0, reload_square.scale),
				reload_square.patch,
				reload_square.flags|V_50TRANS,
				v.getColormap(nil, SKINCOLOR_WHITE)
			)
		end

		-- [Firing Animation] --
		if item_firerate_left and item_firerate
		and iteminfo.id ~= "" then
			firerate_square.scale = FixedDiv(item_firerate_left*FU, item_firerate*FU)
			firerate_square.patch = v.cachePatch("XSG_GREENSQUARE")

			PositionSlot(i, firerate_square, slot_count, slot_gap)

			v.drawScaled(
				firerate_square.x,
				firerate_square.y,
				max(0, firerate_square.scale),
				firerate_square.patch,
				firerate_square.flags|V_50TRANS,
				v.getColormap(nil, SKINCOLOR_YELLOW)
			)
		end

		do -- [Draw Ammo/Item Count] --
			local xoffset = 16*FU
			local yoffset = 8*FU
			local extraflags = 0
			local reloading = (xS.reload > 0)
			local text

			if item_ammo ~= nil and item_ammo >= 0 then
				text = item_ammo
				extraflags = V_SKYMAP

				if item_ammo <= 0 then
					-- Flicker color.
					if ((leveltime/4) % 2) == 0 then
						extraflags = V_REDMAP
					end
				end

				if selection == i then
					if reloading then
						extraflags = V_50TRANS

						-- Flicker color but not transparency.
						if ((leveltime/4) % 2) == 0 then
							extraflags = V_50TRANS|V_REDMAP
						end
					end
				end
			elseif item_count ~= nil and item_count >= 0 then
				text = item_count
			end

			if text ~= nil then
				v.drawString(slot.x + xoffset, slot.y + yoffset, text, slot.flags|extraflags, "thin-fixed-right")
			end
		end
	end

	if selected_slot.positioned_selection then
		local selection = xS.slot

		v.drawScaled(
			selected_slot.x,
			selected_slot.y,
			selected_slot.scale,
			selected_slot.patch,
			selected_slot.flags
		)
	end

	-- Item info.
	local item_color = hand:getIndex("color", player.mo.skin) or SKINCOLOR_WHITE
	local item_name = hand:getIndex("displayname", player.mo.skin) or "ERROR!!"

	v.drawString(160*FU, invpos_y-20*FU, item_name, V_SNAPTOBOTTOM, "thin-fixed-center")

	/*
	customhud.CustomFontString(v, 160*FU, invpos_y-20*FU, item_name, "TNYFC",
	(V_SNAPTOBOTTOM), "center" , FRACUNIT, item_color)
	*/
end)