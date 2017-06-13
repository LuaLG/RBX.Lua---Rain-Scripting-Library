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
