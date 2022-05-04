local function ireduce(tbl, func, acc)
	for i, v in ipairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

local function reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

local Validate = {}

Validate.types = {
	optional = function(validator)
		if type(validator) == "table" then
			table.insert(validator, "nil")
			return validator
		end

		return { validator, "nil" }
	end,
	shape = function(shape_validations)
		return function(value)
			if type(value) ~= "table" then
				return false
			end

			local validation_map = reduce(shape_validations, function(map, validator, key)
				local name = tostring(key)
				local err = type(validator) == "function" and "correct value for '" .. name .. "'" or nil

				map[name] = { value[key], validator, err }
				return map
			end, {})
			local valid, validation_error = pcall(vim.validate, validation_map)

			if not valid then
				return false, validation_error
			end

			return true
		end
	end,
}

-- http://lua-users.org/wiki/DecoratorsAndDocstrings
function Validate.arguments(...)
	local args_validations = { ... }

	return setmetatable(args_validations, {
		__concat = function(_, func)
			return function(...)
				local args = { ... }
				local validation_map = ireduce(args_validations, function(map, validator, key)
					local name, value = tostring(key), args[key]
					local err = type(validator) == "function" and "correct value for argument " .. name or nil

					map[name] = { value, validator, err }
					return map
				end, {})
				local valid, validation_error = pcall(vim.validate, validation_map)

				if not valid then
					error("Arguments validation error: " .. validation_error)
				end

				return func(...)
			end
		end,
	})
end

return Validate
