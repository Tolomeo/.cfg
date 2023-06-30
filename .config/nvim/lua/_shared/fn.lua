local arr = require("_shared.array")

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

function Fn.switch(value)
	return function(cases)
		if cases[value] ~= nil then
			return value, cases[value]()
		end
		return nil
	end
end

return Fn
