colon = {}

colon.truncateTable = function(tbl)
  for i in pairs (tbl) do
    tbl[i] = nil
  end
end


return setmetatable({}, 
{
	__index = function(_,k) return colon[k] end,
	__newindex = function() print'nope' end,
	__metatable = "die faggot this shit is locked"
})
