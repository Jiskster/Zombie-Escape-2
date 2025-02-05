local invpos_y = 185*FU
local empty_patch_name = "BLANKIND"
local slot_gap = 20*FU

local function PositionSlot(index, slot, slot_count, slot_gap)
	-- Center Slot Position
	slot.x = $ - (slot.patch.width*FU)/2
	slot.y = $ - (slot.patch.height*FU)/2
	
	-- Add from the right
	slot.x = $ + (slot_gap) * (index-1)

	-- Center whole inventory
	slot.x = $ - (slot_gap/2) * (slot_count-1)
end

return "Inventory", function(v, player)
	if player["ze2_info"].pregamemenu_active then return end
	if ZE2.game_ended then return end
	if player["ze2_info"].ghostmode then return end
	if player["ze2_info"].zombie_shop_open then return end
	
	if ZE2.pregame_timeleft then return end -- if in pregame, dont display
	if ZE2.zombie_releasetime and player["ze2_info"].team == 2 then return end -- if zombie and hasn't been released, dont display
	
	if player and not player.mo then return end
	
	local slot_count = ZE2:FetchInventoryLimit(player)
	
	local selected_slot = {
		x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
		y = invpos_y,
		scale = FRACUNIT,
		patch = v.cachePatch("CURWEAP"),
		flags = V_SNAPTOBOTTOM,
		positioned_selection = false, -- Has the selected slot been found to render?
	}
	
	for i=1, slot_count do
		local selection = player["ze2_info"].inventory_selection
		
		local slot = {
			x = (BASEVIDWIDTH*FU)/2, -- In middle of screen
			y = invpos_y,
			scale = FRACUNIT,
			patch = v.cachePatch(empty_patch_name),
			flags = V_SNAPTOBOTTOM,
		}
		
		local iteminfo = ZE2:FetchInventorySlot(player, i)
		local item_icon = ZE2:GetItemInfoIndex(iteminfo, "icon", player.mo.skin)
		
		if item_icon then
			slot.patch = v.cachePatch(item_icon)
		end
		
		if selection == i then
			PositionSlot(i,
				selected_slot, 
				slot_count, 
				slot_gap
			)
			
			selected_slot.positioned_selection = true
		end
		
		PositionSlot(i, 
			slot, 
			slot_count, 
			slot_gap
		)
		
		v.drawScaled(
			slot.x,
			slot.y,
			slot.scale,
			slot.patch,
			slot.flags
		)
	end
	
	if selected_slot.positioned_selection then
		local selection = player["ze2_info"].inventory_selection
		
		v.drawScaled(
			selected_slot.x,
			selected_slot.y,
			selected_slot.scale,
			selected_slot.patch,
			selected_slot.flags
		)
	end
end