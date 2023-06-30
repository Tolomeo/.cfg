local arr = require("_shared.array")

local Map = {}

--- https://github.com/lunarmodules/Penlight/blob/master/lua/pl/utils.lua
--- An iterator over all non-integer keys (inverse of `ipairs`).
--- This uses `pairs` under the hood, so any value that is iterable using `pairs`
--- will work with this function.
---@param t table  the table to iterate over
---@return string
function Map.pairs(t)
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
function Map.reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		if type(i) == "string" then
			acc = func(acc, v, i)
		end
	end
	return acc
end

function Map.find(tbl, func)
	for key, item in Map.pairs(tbl) do
		if func(item, key) then
			return item
		end
	end

	return nil
end

function Map.map(tbl, func)
	return Map.reduce(tbl, function(new_tbl, value, key)
		table.insert(new_tbl, func(value, key))
		return new_tbl
	end, {})
end

function Map.each(tbl, func)
	for key, value in Map.pairs(tbl) do
		func(value, key, tbl)
	end
end

--- Returns an array of a given table's string-keyed property names.
---@param tbl table
---@return table
function Map.keys(tbl)
	local keys = {}
	for key, _ in Map.pairs(tbl) do
		table.insert(keys, key)
	end
	return keys
end

function Map.values(tbl)
	local values = {}
	for _, value in Map.pairs(tbl) do
		table.insert(values, value)
	end
	return values
end

function Map.entries(tbl)
	local entries = {}
	for key, value in Map.pairs(tbl) do
		table.insert(entries, { key, value })
	end
	return entries
end

function Map.merge(...)
	return Map.reduce({ ... }, function(target, source)
		return vim.tbl_extend("force", target, source)
	end, {})
end

function Map.merge_deep(...)
	return Map.reduce({ ... }, function(target, source)
		return vim.tbl_deep_extend("force", target, source)
	end, {})
end

function Map.filter(tbl, func)
	return Map.reduce(tbl, function(a, v, k)
		if func(v, k) then
			a[k] = v
		end

		return a
	end, {})
end

return Map
