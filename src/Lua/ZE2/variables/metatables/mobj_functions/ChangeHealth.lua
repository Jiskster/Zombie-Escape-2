return function(self, amount)
	if self.health + amount > self.maxhealth then
		self.health = self.maxhealth
	else
		self.health = $ + amount
	end
end