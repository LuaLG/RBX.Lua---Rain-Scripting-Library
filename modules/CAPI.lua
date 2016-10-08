local module = {}

local LUA_GLOBALSINDEX = -10002

--[[
Stack:
stack = {
	entry_1   first entry, bottom of stack
	entry_2	  second entry, second from bottom
	.
	.
	.
	entry_n   nth entry where n is the number of elements on stack, this is the top
}


Entry:
A stack entry is a table containing a value, and string representation of the type of the value

{["type"] = "type", ["value"] = value}
{["type"] = "number", ["value"] = 1337}
{["type"] = "string", ["value"] = "magic"}
{["type"] = "function", ["value"] = function() return end}


Example of a stack after pushing nil, and a number 400:
stack = {
	{["type"] = "nil", ["value"] = nil}
	{["type"] = "number", ["value"] = 400}
}
]]


module.global_state = {
	["stack"] = {}
}

-- Always returns a stack entry (or a fake one for things like GLOBALSINDEX)
-- {["type"] = "type", ["value"] = value}
local function index2adr(L, idx)
	if (idx > 0) then
		if (idx > #L.stack) then return nil end
		return L.stack[idx]
	elseif (idx == LUA_GLOBALSINDEX) then
		return {
			["type"] = "table",
			["value"] = getfenv(0)
		}
	elseif (false) then 
		-- TODO: add support for LUA_REGISTRYINDEX, LUA_ENVIRONINDEX
	elseif (idx < 0) then
		if (idx < -#L.stack) then return nil end
		return L.stack[#L.stack + idx + 1]
	end
end

local function push(L, tt, val)
	L.stack[#L.stack+1] = {
		["type"] = tt,
		["value"] = val
	}
end

module.lua_pop = function(L, n)
	if n > 0 then
		local stack_len = #L.stack
		if n > stack_len then L.stack = {} return end
		for i = stack_len - n + 1, stack_len do
			L.stack[i] = nil
		end
	end
end

module.lua_gettop = function(L)
	return #L.stack
end

------------------------------------------------------------------

module.lua_pushnil = function(L)
	push(L, "nil", nil)
end

module.lua_pushstring = function(L, String)
	push(L, "string", String)
end

module.lua_pushboolean = function(L, Bool)
	push(L, "boolean", Bool)
end

module.lua_pushnumber = function(L, Number)
	push(L, "number", Number)
end

module.lua_pushcclosure = function(L, Function, Upvals)
	-- todo	
end

module.lua_pushvalue = function(L, index)
	L.stack[#L.stack+1] = index2adr(L, index)
end

------------------------------------------------------------------

module.lua_toboolean = function(L, index)
	local val = index2adr(L, index)["value"]
	return not not val
end

module.lua_tonumber = function(L, index)
	return tonumber(index2adr(L, index)["value"]) or 0
end

module.lua_tostring = function(L, index)
	return tostring(index2adr(L, index)["value"])
end

module.lua_tointeger = function(L, index)
	local val = index2adr(L, index)["value"]
	return math.floor(tonumber(val)) or 0
end

------------------------------------------------------------------

module.lua_getglobal = function(L, k)
	return module.lua_getfield(L, LUA_GLOBALSINDEX, k)
end

module.lua_getfield = function(L, index, k)
	local stk = index2adr(L, index)
	if stk["type"] == "table" then
		local value = stk["value"][k]
		push(L, type(value), value)
	end
end

module.lua_setglobal = function(L, k)
	return module.lua_setfield(L, LUA_GLOBALSINDEX, k)
end

module.lua_setfield = function(L, index, k)
	local stk = index2adr(L, index)
	if stk["type"] == "table" then
		stk["value"][k] = index2adr(L, -1)["value"]
	end
end

return module
