local saved = {}

function ZE2.Require(path)
	if saved[path] then
		return saved[path]
	else
		saved[path] = dofile(path)
		
		return saved[path]
	end
end