local arr = require("_shared.array")

local Fn = {}

--- https://github.com/lunarmodules/Penlight/blob/master/lua/pl/utils.lua
--- An iterator over all non-integer keys (inverse of `ipairs`).
--- This uses `pairs` under the hood, so any value that is iterable using `pairs`
--- will work with this function.
---@param t table  the table to iterate over
---@return string
function Fn.kpairs(t)
	local index
	return function()
		local value
		while true do
			index, value = next(t, index)
			if type(index) ~= "number" or math.floor(index) ~= index then
				break
			end
		end
		return index, value
	end
end

--- Executes a user-supplied "reducer" callback function on each key element of the table indexed with a string key, in order, passing in the return value from the calculation on the preceding element
---@param tbl table the table to loop against
---@param func function the reducer callback
---@param acc any the accumulator initial value
---@return any
function Fn.kreduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		if type(i) == "string" then
			acc = func(acc, v, i)
		end
	end
	return acc
end

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

function Fn.kfind(tbl, func)
	for key, item in Fn.kpairs(tbl) do
		if func(item, key) then
			return item
		end
	end

	return nil
end

function Fn.kmap(tbl, func)
	return Fn.kreduce(tbl, function(new_tbl, value, key)
		table.insert(new_tbl, func(value, key))
		return new_tbl
	end, {})
end

function Fn.keach(tbl, func)
	for key, value in Fn.kpairs(tbl) do
		func(value, key, tbl)
	end
end

--- Returns an array of a given table's string-keyed property names.
---@param tbl table
---@return table
function Fn.keys(tbl)
	local keys = {}
	for key, _ in Fn.kpairs(tbl) do
		table.insert(keys, key)
	end
	return keys
end

function Fn.values(tbl)
	local values = {}
	for _, value in Fn.kpairs(tbl) do
		table.insert(values, value)
	end
	return values
end

function Fn.entries(tbl)
	local entries = {}
	for key, value in Fn.kpairs(tbl) do
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
	return Fn.kreduce(tbl, function(a, v, k)
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

function Fn.iunion(tbl1, tbl2)
	local union = {}
	local seen = {}

	for _, element in ipairs(tbl1) do
		union[#union + 1] = element
		seen[element] = true
	end

	for _, element in ipairs(tbl2) do
		if not seen[element] then
			union[#union + 1] = element
			seen[element] = true
		end
	end

	return union
end

return Fn
