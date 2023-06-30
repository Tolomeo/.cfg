local arr = require("_shared.array")
local map = require("_shared.map")

local Fn = {}

--- Executes a user-supplied "reducer" callback function on each element of the table, in order, passing in the return value from the calculation on the preceding element
---@param tbl table the table to loop against
---@param func function the reducer callback
---@param acc any the accumulator initial value
---@return any
function Fn.reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

function Fn.keach(tbl, func)
	for key, value in map.pairs(tbl) do
		func(value, key, tbl)
	end
end

--- Returns an array of a given table's string-keyed property names.
---@param tbl table
---@return table
function Fn.keys(tbl)
	local keys = {}
	for key, _ in map.pairs(tbl) do
		table.insert(keys, key)
	end
	return keys
end

function Fn.values(tbl)
	local values = {}
	for _, value in map.pairs(tbl) do
		table.insert(values, value)
	end
	return values
end

function Fn.entries(tbl)
	local entries = {}
	for key, value in map.pairs(tbl) do
		table.insert(entries, { key, value })
	end
	return entries
end

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
	return Fn.reduce({ ... }, function(target, source)
		return vim.tbl_extend("force", target, source)
	end, {})
end

function Fn.merge_deep(...)
	return Fn.reduce({ ... }, function(target, source)
		return vim.tbl_deep_extend("force", target, source)
	end, {})
end

function Fn.trim(str)
	return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

function Fn.kfilter(tbl, func)
	return map.reduce(tbl, function(a, v, k)
		if func(v, k) then
			a[k] = v
		end

		return a
	end, {})
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
