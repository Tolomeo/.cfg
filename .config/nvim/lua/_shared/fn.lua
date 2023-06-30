local arr = require("_shared.array")
local tbl = require("_shared.table")

local Fn = {}

--- Creates a new function that, when called,
---has its arguments preceded by any provided ones
---@param func function
---@vararg any
---@return function
function Fn.bind(func, ...)
	local boundArgs = { ... }

	return function(...)
		local callArgs = { ... }

		return func(arr.unpack(boundArgs, callArgs))
	end
end

function Fn.merge(...)
	return tbl.reduce({ ... }, function(target, source)
		return vim.tbl_extend("force", target, source)
	end, {})
end

function Fn.merge_deep(...)
	return tbl.reduce({ ... }, function(target, source)
		return vim.tbl_deep_extend("force", target, source)
	end, {})
end

function Fn.trim(str)
	return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

function Fn.split(str, delimiter)
	local result = {}
	local pattern = string.format("([^%s]+)", delimiter)

	for word in string.gmatch(str, pattern) do
		table.insert(result, word)
	end

	return result
end

function Fn.switch(value)
	return function(cases)
		if cases[value] ~= nil then
			return value, cases[value]()
		end
		return nil
	end
end

return Fn
