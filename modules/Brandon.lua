-- Brandon's magical functions

local lib = {}

-- Similar to table.foreach, but for instances
-- Function `f` receives only the child instance as a parameter
lib.foreach_child = function(inst, f)
	local success, children = pcall(inst.GetChildren, inst)
	if success == false then return end	
	for i,v in next, inst:GetChildren() do
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

-- Overthrow Autumn and seize the means of production!
lib.seize_rain = function()
	local autumn_tbl = require(script.Parent.Autumn)
	for i,v in next, autumn_tbl do autumn_tbl[i] = nil end
	setmetatable(autumn_tbl, {
		__index = function(t,k) return function() print("Rain has been seized!") end end,
		__newindex = function(t,k,v) return end,
		__metatable = "Rain has been seized!"
	})
end

return setmetatable({}, {
	__index = function(_,k) return lib[k] end,
	__newindex = function() return end,
	__metatable = "The metatable is locked"
})
