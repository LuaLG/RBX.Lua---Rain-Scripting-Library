local services = {}

local function CreateService(name, mt)
	services[name] = newproxy(true)
	for i,v in next, mt do
		getmetatable(services[name])[i] = v
	end
end

CreateService("Garbage", {
	__index = {
		Destroy = function(...)
			local args = {...}
			-- WIP
		end
	}
})

local function GetService(service)
	local success, result = pcall(function() return services[service] end)
	if success then
		return result
	end
	error("'" .. service .. "' is not a valid service.")
end

return {GetService = GetService}
