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

---Acts like unpack, but accepts multiple arguments
---@generic T
---@param ... T[]
---@return ...T
---@see http://lua-users.org/lists/lua-l/2004-08/msg00354.html
function Fn.unpack(...)
	local ret = {}
	for _, tbl in ipairs({ ... }) do
		for _, rec in ipairs(tbl) do
			table.insert(ret, rec)
		end
	end
	return unpack(ret)
end

--- Executes a user-supplied "reducer" callback function on each element of the table indexed with a numeric key, in order, passing in the return value from the calculation on the preceding element
---@param tbl table the table to loop against
---@param func function the reducer callback
---@param acc any the accumulator initial value
---@return any
function Fn.ireduce(tbl, func, acc)
	for i, v in ipairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
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

--- Returns the index of the first element in the array that satisfies the provided testing function
---@param tbl table the table to loop against
---@param func function callback returning true or false
---@return number|nil
function Fn.find_index(tbl, func)
	for index, item in ipairs(tbl) do
		if func(item, index) then
			return index
		end
	end

	return nil
end

--- Returns the first element in the array that satisfies the provided testing function
---@generic V
---@param tbl table<number, V> the table to loop against
---@param func function callback returning true or false
---@return V | nil
function Fn.ifind(tbl, func)
	for index, item in ipairs(tbl) do
		if func(item, index) then
			return item
		end
	end

	return nil
end

function Fn.kfind(tbl, func)
	for key, item in Fn.kpairs(tbl) do
		if func(item, key) then
			return item
		end
	end

	return nil
end

function Fn.find_last_index(tbl, func)
	for index = #tbl, 1, -1 do
		if func(tbl[index], index) then
			return index
		end
	end
end

function Fn.slice(tbl, startIndex, endIndex)
	local sliced = {}
	endIndex = endIndex or #tbl

	for index = startIndex, endIndex do
		table.insert(sliced, tbl[index])
	end

	return sliced
end

function Fn.push(tbl, ...)
	for _, value in ipairs({ ... }) do
		table.insert(tbl, value)
	end

	return tbl
end

--- Creates a new table populated with the results of calling a provided functions
---on every numeric indexed element in the calling table
---@param tbl table
---@param func function
---@return table
function Fn.imap(tbl, func)
	return Fn.ireduce(tbl, function(new_tbl, value, index)
		table.insert(new_tbl, func(value, index))
		return new_tbl
	end, {})
end

function Fn.kmap(tbl, func)
	return Fn.kreduce(tbl, function(new_tbl, value, key)
		table.insert(new_tbl, func(value, key))
		return new_tbl
	end, {})
end

function Fn.ieach(tbl, func)
	for index, value in ipairs(tbl) do
		func(value, index, tbl)
	end
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

--- Returns an array of a given table's numbered-keyed property names.
---@param tbl table
---@return table
function Fn.indexes(tbl)
	local indexes = {}
	for key, _ in ipairs(tbl) do
		table.insert(indexes, key)
	end
	return indexes
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

		return func(Fn.unpack(boundArgs, callArgs))
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

function Fn.ifilter(tbl, func)
	return Fn.ireduce(tbl, function(a, v, i)
		if func(v, i) then
			table.insert(a, v)
		end

		return a
	end, {})
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
			return true, cases[value]()
		end
		return false, nil
	end
end

function Fn.iincludes(tbl, search)
	local found = Fn.ifind(tbl, function(item)
		return item == search
	end)

	return found and true or false
end

function Fn.rotateRight(tbl, offset)
	local length = #tbl
	local rotated = {}

	for i = offset, length do
		table.insert(rotated, tbl[i])
	end

	for i = 1, offset - 1 do
		table.insert(rotated, tbl[i])
	end

	return rotated
end

function Fn.rotateLeft(tbl, offset)
	local length = #tbl
	local rotated = {}

	for i = offset, 1, -1 do
		table.insert(rotated, tbl[i])
	end

	for i = length, offset + 1, -1 do
		table.insert(rotated, tbl[i])
	end

	return rotated
end

function Fn.tail(tbl)
	local tail = {}

	for i = 2, #tbl do
		table.insert(tail, tbl[i])
	end

	return tail
end

function Fn.reverse(tbl)
	local reversed = {}
	local length = #tbl

	for i = length, 1, -1 do
		table.insert(reversed, tbl[i])
	end

	return reversed
end

function Fn.iintersection(tbl1, tbl2)
	local result = {}

	local counts = {}
	for _, element in ipairs(tbl1) do
		counts[element] = (counts[element] or 0) + 1
	end

	for _, element in ipairs(tbl2) do
		if counts[element] and counts[element] > 0 then
			table.insert(result, element)
			counts[element] = counts[element] - 1
		end
	end

	return result
end

return Fn
