-- Revamped, Dino.lua (modulescript)
-- Updated: 8/2/17

-- A collection of classes that can be used to do different things.
-- Each class should have its own module, but it's fine to put it all into one modulescript.
-- API (coming soon).


-- Queue class

local Queue = {}
Queue.__index = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	
	-- HandlerName : Function
	self.Handlers = {}
	-- HandlerName : Amount
	self.CallQueue = {}
	-- Insert the name of the handler
	self.StopCoroutineTriggers = {}
	
	return self
end

function Queue:RegisterHandler(Name, Function, WaitTime, WaitFirst)
	if typeof(Name) ~= "string" then
		error("Bad argument to `Queue.RegisterHandler`. Expected type `string` as first argument, got `" .. typeof(Name) .. "`")
	end
	if typeof(Function) ~= "function" then
		error("Bad argument to `Queue.RegisterHandler`. Expected type `function` as second argument, got `" .. typeof(Function) .. "`")
	end
	if typeof(WaitTime) ~= "number" then
		error("Bad argument to `Queue.RegisterHandler`. Expected type `number` as third argument, got `" .. typeof(WaitTime) .. "`")
	end
	if typeof(WaitFirst) ~= "boolean" then
		error("Bad argument to `Queue.RegisterHandler`. Expected type `boolean` as fourth argument, got `" .. typeof(WaitFirst) .. "`")
	end
	
	-- End the old queue if it exists
	if self.Handlers[Name] then
		self.StopCoroutineTriggers[Name] = true
		repeat wait() until self.StopCoroutineTriggers[Name] == nil
	end
	
	-- If there was an old queue, it will be overwritten here
	self.Handlers[Name] = Function
	self.CallQueue[Name] = 0
	
	-- Initiate a coroutine for the handler
	coroutine.wrap(function()
		local CurrentWaitTime = 0
		local PreviousTick = tick()
		if WaitFirst then
			CurrentWaitTime = WaitTime
		end		
		
		while wait() do
			if self.StopCoroutineTriggers[Name] then
				self.StopCoroutineTriggers[Name] = nil
				return
			end
			if CurrentWaitTime ~= 0 then
				-- Need to wait
				repeat
					wait()
					if self.StopCoroutineTriggers[Name] then
						self.StopCoroutineTriggers[Name] = nil
						return
					end
				until tick() - PreviousTick >= CurrentWaitTime
			end
			if self.CallQueue[Name] > 0 then
				self.Handlers[Name]()
				CurrentWaitTime = WaitTime
				PreviousTick = tick()
				-- Decrease queue
				self.CallQueue[Name] = self.CallQueue[Name] - 1
			end
		end
	end)()
end

function Queue:RemoveHandler(Name)
	if typeof(Name) ~= "string" then
		error("Bad argument to `Queue.RemoveHandler`. Expected type `string` as first argument, got `" .. typeof(Name) .. "`")
	end
	if self.Handlers[Name] == nil then
		error("No handler with the name `" .. Name .. "` exists.")
	end
	
	if self.Handlers[Name] then
		self.StopCoroutineTriggers[Name] = true
		repeat wait() until self.StopCoroutineTriggers[Name] == nil
		self.Handlers[Name] = nil
		self.CallQueue[Name] = nil
	end
end

function Queue:QueueHandler(Name)
	if typeof(Name) ~= "string" then
		error("Bad argument to `Queue.QueueHandler`. Expected type `string` as first argument, got `" .. typeof(Name) .. "`")
	end
	if self.Handlers[Name] == nil then
		error("No handler with the name `" .. Name .. "` exists.")
	end
	
	self.CallQueue[Name] = self.CallQueue[Name] + 1
end

local Module = {
	Queue = Queue
}

-- Can be removed; used to prevent the module from being hijacked/modified
local Proxy = newproxy(true)
local Metatable = getmetatable(Proxy)
Metatable.__index = Module
Metatable.__newindex = function() error("This table is locked.") end
Metatable.__metatable = "This metatable is locked."

return Proxy
