--[[
	Lua C API simulator in Lua
	By Rain
--]]

local module = {}

-- TODO: Make these part of the module?
local LUA_REGISTRYINDEX = -10000
local LUA_ENVIRONINDEX = -10001
local LUA_GLOBALSINDEX = -10002
local function lua_upvalueindex(i) return LUA_GLOBALSINDEX - i end

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
The type of the value is accessed through the ["type"] field of the table, and the value through the ["value"] field

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

------------------------------------------------------------------

-- Struct definitions

-- TODO: More fields can be added as needed
-- NOTE: Field names have been changed for readability (can be changed back to original if needed)

module.global_state = {
	registry = {},
	mainthread = nil
}

module.lua_state = {
	stack = {},
	globalstate = nil
}

local function new_struct(struct)
	local newstruct = {}
	for i,v in next, struct do
		if type(v) ~= "table" then
			newstruct[i] = v
		else
			newstruct[i] = new_struct(v)
		end
	end
	return newstruct
end

------------------------------------------------------------------

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

module.lua_settop = function(L, idx)
	local stack_len = #L.stack
	if idx < 0 then
		idx = idx + stack_len + 1
		if idx < 0 then
			L.stack = {}
			return
		end
	end
	if idx > stack_len then
		for i = 1, idx - stack_len do
			push(L, "nil", nil)
		end
	else
		for i = idx + 1, stack_len do
			L.stack[i] = nil
		end
	end	
end

module.lua_gettop = function(L)
	return #L.stack
end
	
module.lua_pop = function(L, n)
	module.lua_settop(L, -(n)-1)
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

module.lua_pushinteger = function(L, Integer)
	push(L, "number", math.floor(Integer))
end

module.lua_pushcclosure = function(L, Function, Upvals)
	-- todo	
end

module.lua_pushthread = function(L)
	push(L, "thread", L)
	return (L.globalstate.mainthread == L)
end

module.lua_pushvalue = function(L, index)
	L.stack[#L.stack+1] = index2adr(L, index)
end
		
------------------------------------------------------------------
		
module.lua_newthread = function(L)
	Thread = new_struct(module.lua_state)
	Thread.globalstate = L.globalstate
	push(L, "thread", Thread)
	return Thread
end
	
module.lua_newtable = function(L)
	push(L, "table", {})		
end
	
module.lua_newuserdata = function(L)
	push(L, "userdata", newproxy(true))		
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
	
module.lua_touserdata = function(L, index)
	return index2adr(L, indx)["value"]		
end

------------------------------------------------------------------

module.lua_isnumber = function(L, index)
	local val = index2adr(L, index)["value"]
	return not not tonumber(val)
end

module.lua_isstring = function(L, index)
	local tt = index2adr(L, index)["type"]
	return tt == "number" or tt == "string"
end

module.lua_isuserdata = function(L, index)
	local tt = index2adr(L, index)["type"]
	return tt == "userdata" or tt == "lightuserdata"
end
	
module.lua_type = function(L, index)
	return index2adr(L, index)["type"]		
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
		
------------------------------------------------------------------
		
module.luaL_newstate = function()
	GL = new_struct(module.global_state)
	L = new_struct(module.lua_state)
	GL.mainthread = L
	L.globalstate = GL
	return L
end
		
return module
