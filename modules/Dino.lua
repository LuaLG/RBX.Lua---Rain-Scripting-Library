--[[
	Still a WIP	
	
	Documentation:
	
	module.GetService(string service)
		-	Returns a service with the name `service`
		-	Throws an error if the service cannot be found
		
	`Garbage` service:
		Garbage.Destroy(Instance object)
			- Destroys the object and constantly renames it for obfuscation purposes (not the best)
		
	
--]]


local services = {}

local function CreateService(name, children)
	services[name] = newproxy(true)
	getmetatable(services[name]).__index = children
end

CreateService("Garbage", {
	Destroy = function(...)
		local args = {...}
		-- WIP
	end
})

local function GetService(service)
	local success, result = pcall(function() return services[service] end)
	if success then
		return result
	end
	error("'" .. service .. "' is not a valid service.")
end

return {GetService = GetService}
