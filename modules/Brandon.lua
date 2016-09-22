-- Brandon's magical functions

local lib = {}

-- Similar to table.foreach, but for instances
-- Function `f` receives only the child instance as a parameter
lib.foreach_child = function(inst, f)
	local success, children = pcall(inst.GetChildren, inst)
	if success == false then return end	
	for i,v in next, children do
		if f(v) ~= nil then
			return
		end
	end
end

-- Same as foreach_child, except it recursively iterates through all descendants
lib.foreach_descendant = function(inst, f)
	local success, children = pcall(inst.GetChildren, inst)
	if success == false then return end
	for i,v in next, children do
		if f(v) ~= nil then
			return
		end
		lib.foreach_descendant(v, f)
	end
end

return lib
