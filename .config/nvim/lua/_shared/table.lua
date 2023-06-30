local Table = {}

--- Executes a user-supplied "reducer" callback function on each element of the table, in order, passing in the return value from the calculation on the preceding element
---@param tbl table the table to loop against
---@param func function the reducer callback
---@param acc any the accumulator initial value
---@return any
function Table.reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

function Table.merge(...)
	return Table.reduce({ ... }, function(target, source)
		return vim.tbl_extend("force", target, source)
	end, {})
end

function Table.merge_deep(...)
	return Table.reduce({ ... }, function(target, source)
		return vim.tbl_deep_extend("force", target, source)
	end, {})
end

return Table
