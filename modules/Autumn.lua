-- I'll just throw in a few funcs from a fun old library I was working on
-- It never went anywhere, so it's more productivity than laziness :P
-- I'll add things here whenever I get new ideas

return setmetatable({}, {__index = {
	Utilities = setmetatable({
		checkFriendship = function(self, type, name1, name2)
			if not type or not name1 or not name2 then error("missing argument(s)", 2) end
			local func = name1["is" .. type .. "With"]
			if func then
				return func(name1, name2)
			end
		end;
		
		splitString = function(self, str, point)
			if not str or not point then error("missing argument(s)", 2) end
			local res = {}
			table.insert(res, string.sub(str, 1, point))
			table.insert(res, string.sub(str, point + 1, string.len(str)))
			return unpack(res)
		end;
		
		findInTable = function(tbl, val)
			if not tbl or not val then error("missing argument(s)", 2) end
			for i,v in pairs(tbl) do
				if v == val then
					return true, i
				end
			end
			return false
		end;
	}, {__index = function(t, k) for i,v in pairs(t) do if i:lower() == k:lower() then return v end end end})
}, __metatable = 42})
