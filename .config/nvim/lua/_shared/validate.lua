local function ireduce(tbl, func, acc)
	for i, v in ipairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

local function kreduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		if type(i) == "string" then
			acc = func(acc, v, i)
		end
	end
	return acc
end

local function reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

local get_list_validation = function(list, validators_list)
	local length = math.max(#list, #validators_list)
	local validation = {}

	for i = 1, length, 1 do
		local key = tostring(i)
		local list_item = list[i]
		local list_item_validator = validators_list[i] or validators_list[#validators_list]
		local err = type(list_item_validator) == "function" and "correct value at position " .. key or nil
		validation[key] = { list_item, list_item_validator, err }
	end

	return validation
end

local get_dict_validation = function(dict, validators_dict)
	return kreduce(validators_dict, function(dict_validation, validator, key)
		local value = dict[key]
		local err = type(validator) == "function" and "correct value for key '" .. key .. "'" or nil

		dict_validation[key] = { value, validator, err }
		return dict_validation
	end, {})
end

local get_table_validation = function(tbl, validators_tbl)
	return vim.tbl_extend("error", get_list_validation(tbl, validators_tbl), get_dict_validation(tbl, validators_tbl))
end

local Validate = {}

Validate.call = function(value, validator)
	return pcall(vim.validate, { [value] = { value, validator } })
end

Validate.t = {
	optional = function(validator)
		if type(validator) == "function" then
			return function(value)
				if type(value) == "nil" then
					return true
				end
				return validator(value)
			end
		end

		if type(validator) == "table" then
			table.insert(validator, "nil")
			return validator
		end

		return { validator, "nil" }
	end,
	equal = function(expected)
		return function(value)
			if expected ~= value then
				return false, "Expected value " .. vim.inspect(value) .. "to be equal to " .. vim.inspect(expected)
			end

			return true
		end
	end,
	one_of = function(...)
		local expected = { ... }

		return function(value)
			for _, expected_value in ipairs(expected) do
				if expected_value == value then
					return true
				end
			end

			return false, "Expected value " .. vim.inspect(value) .. " to be one of " .. vim.inspect(expected)
		end
	end,
	pattern = function(pattern)
		return function(value)
			if type(value) ~= "string" then
				return false, "Expected string, got " .. vim.inspect(value)
			end

			local match = string.match(value, pattern)

			if not match then
				return false, "Expected string " .. value .. " to match " .. pattern .. " pattern"
			end

			return true
		end
	end,
	greater_than = function(min)
		return function(value)
			local is_valid = type(value) == "number" and value > min

			if not is_valid then
				return false, "Expected value " .. vim.inspect(value) .. " to be a number above " .. tostring(min)
			end

			return true
		end
	end,
	less_than = function(max)
		return function(value)
			local is_valid = type(value) == "number" and value < max

			if not is_valid then
				return false, "Expected value " .. vim.inspect(value) .. " to be a number below " .. tostring(max)
			end

			return true
		end
	end,
	list = function(...)
		local list_validators = { ... }

		return function(list)
			if type(list) ~= "table" then
				return false, "Expected table, got " .. vim.inspect(list)
			end

			local validation_map = get_list_validation(list, list_validators)
			local valid, validation_error = pcall(vim.validate, validation_map)

			if not valid then
				return false, validation_error
			end

			return true
		end
	end,
	shape = function(shape_validations)
		return function(value)
			if type(value) ~= "table" then
				return false
			end

			local validation_map = get_table_validation(value, shape_validations)
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
	local validate_arguments = Validate.t.list(...)

	return setmetatable({}, {
		__concat = function(_, func)
			return function(...)
				local valid, validation_error = validate_arguments({ ... })

				if not valid then
					error("Arguments validation failed: " .. validation_error)
				end

				return func(...)
			end
		end,
	})
end

return Validate
