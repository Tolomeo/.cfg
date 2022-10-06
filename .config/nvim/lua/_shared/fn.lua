local Fn = {}

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

function Fn.find_last_index(tbl, func)
	for index = #tbl, 1, -1 do
		if func(tbl[index], index) then
			return index
		end
	end
end

function Fn.slice(tbl, startIndex, endIndex)
	local slice = {}
	endIndex = endIndex or #tbl

	for index = startIndex, endIndex do
		table.insert(slice, tbl[index])
	end

	return slice
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

--- Creates a new function that, when called,
---has its arguments preceded by any provided ones
---@param func function
---@vararg any
---@return function
function Fn.bind(func, ...)
	local boundArgs = { ... }

	return function(...)
		return func(unpack(boundArgs), ...)
	end
end

return Fn
