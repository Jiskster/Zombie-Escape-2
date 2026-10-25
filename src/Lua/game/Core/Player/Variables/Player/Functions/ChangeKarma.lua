return function(self, amount)
    local MIN = ZE2.MinKarma
    local MAX = ZE2.MaxKarma

    self.karma = min(max(MIN, $ + amount), MAX)
end