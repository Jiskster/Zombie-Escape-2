return function(self, amount)
	local player = self.player
	
	if player.ze2.team ~= 1 then return end -- no zombi!!!

	player.ze2.sprintmeter = $ + amount
	
	if player.ze2.sprintmeter > 100*FRACUNIT then
		player.ze2.sprintmeter = 100*FRACUNIT
	elseif player.ze2.sprintmeter < 0 then
		if player.mo and player.mo.valid then
			local newsprintexhaust
			
			if cc[player.mo.skin] and cc[player.mo.skin].sprintexhaust then
				newsprintexhaust = cc[player.mo.skin].sprintexhaust
			end

			if newsprintexhaust ~= nil then
				player.ze2.sprintdelay = abs(newsprintexhaust)
			else
				player.ze2.sprintdelay = TICRATE*2 -- do default
			end
		end
		
		player.ze2.sprintmeter = 0
	end
end