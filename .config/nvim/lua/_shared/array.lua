local Array = {}

---Acts like unpack, but accepts multiple arguments
---@generic T
---@param ... T[]
---@return ...T
---@see http://lua-users.org/lists/lua-l/2004-08/msg00354.html
function Array.unpack(...)
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
function Array.reduce(tbl, func, acc)
	for i, v in ipairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

--- Returns the index of the first element in the array that satisfies the provided testing function
---@param tbl table the table to loop against
---@param func function callback returning true or false
---@return number|nil
function Array.find_index(tbl, func)
	for index, item in ipairs(tbl) do
		if func(item, index) then
			return index
		end
	end

	return nil
end

--- Returns the index of the last element in the array that satisfies the provided testing function
---@param tbl table the table to loop against
---@param func function callback returning true or false
---@return number|nil
function Array.find_last_index(tbl, func)
	for index = #tbl, 1, -1 do
		if func(tbl[index], index) then
			return index
		end
	end
end

--- Returns the first element in the array that satisfies the provided testing function
---@generic V
---@param tbl table<number, V> the table to loop against
---@param func function callback returning true or false
---@return V | nil
function Array.find(tbl, func)
	for index, item in ipairs(tbl) do
		if func(item, index) then
			return item
		end
	end

	return nil
end

--- Returns a copy of a portion of an table into a new table selected from startIndex to endIndex
--- StartIndex and endIndex represent the index of items in that table.
--- The original table will not be modified.
---@generic V
---@param tbl table<number, V>
---@param startIndex number
---@param endIndex number
---@return table<number, V>
function Array.slice(tbl, startIndex, endIndex)
	local sliced = {}
	endIndex = endIndex or #tbl

	for index = startIndex, endIndex do
		table.insert(sliced, tbl[index])
	end

	return sliced
end

--- Adds the specified elements to the end of a table and returns the table
---@generic V: table
---@param tbl V
---@vararg any
---@return V
function Array.push(tbl, ...)
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
function Array.map(tbl, func)
	return Array.reduce(tbl, function(new_tbl, value, index)
		table.insert(new_tbl, func(value, index))
		return new_tbl
	end, {})
end

--- Executes a provided function once for each table element
---@param tbl table
---@param func function
function Array.each(tbl, func)
	for index, value in ipairs(tbl) do
		func(value, index, tbl)
	end
end

--- Returns an array of a given table's numbered-keyed property names.
---@param tbl table
---@return table
function Array.indexes(tbl)
	local indexes = {}
	for key, _ in ipairs(tbl) do
		table.insert(indexes, key)
	end
	return indexes
end

--- Creates a copy of a portion of a given table,
--- filtered down to just the elements from the given table that pass the test implemented by the provided function
---@param tbl table
---@param func function
---@return table
function Array.filter(tbl, func)
	return Array.reduce(tbl, function(a, v, i)
		if func(v, i) then
			table.insert(a, v)
		end

		return a
	end, {})
end

--- Determines whether an table includes a certain value among its entries, returning true or false as appropriate
---@param tbl table
---@param search any
---@return boolean
function Array.includes(tbl, search)
	local found = Array.find(tbl, function(item)
		return item == search
	end)

	return found and true or false
end

function Array.rotateRight(tbl, offset)
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

function Array.rotateLeft(tbl, offset)
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

---Gets all but the first element of a table
---@param tbl table
---@return table
function Array.tail(tbl)
	local tail = {}

	for i = 2, #tbl do
		table.insert(tail, tbl[i])
	end

	return tail
end

--- Creates a copy of a table, which has the same items of the provided array in the opposite order
---@param tbl table
---@return table
function Array.reverse(tbl)
	local reversed = {}
	local length = #tbl

	for i = length, 1, -1 do
		table.insert(reversed, tbl[i])
	end

	return reversed
end

--- Creates an array of unique values that are included in both given tables
---@param tbl1 table
---@param tbl2 table
---@return table
function Array.intersection(tbl1, tbl2)
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

--- Creates a table of unique values, in order, from all given tables
---@param tbl1 table
---@param tbl2 table
---@return table
function Array.union(tbl1, tbl2)
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

return Array
