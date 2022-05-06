local fn = require("_shared.fn")

--- Generates a validation map for a list
---@param list table the list value
---@param validators_list table list of validators to use for the validation
---@return table
local get_list_validation_map = function(list, validators_list)
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

--- Generates a validation map for a dictionary
---@param dict table the dictionary value
---@param validators_dict table dictionary of validators to use for the validation
---@return table
local get_dict_validation_map = function(dict, validators_dict)
	return fn.kreduce(validators_dict, function(dict_validation, validator, key)
		local value = dict[key]
		local err = type(validator) == "function" and "correct value for key '" .. key .. "'" or nil

		dict_validation[key] = { value, validator, err }
		return dict_validation
	end, {})
end

local get_table_validation_map = function(tbl, validators_tbl)
	return vim.tbl_extend(
		"error",
		get_list_validation_map(tbl, validators_tbl),
		get_dict_validation_map(tbl, validators_tbl)
	)
end

local Validator = {}

--- Returns the outcome of a validation performed by calling vim.validate
---@param validationMap table the vim.validate opt parameter
---@return boolean, string|nil
Validator.validate = function(validationMap)
	return pcall(vim.validate, validationMap)
end

Validator.f = {
	--- Has a validator returning true when a nil value is passed to it
	---@param validator function|table|string the validator to be enhanced
	---@return function|table
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
	--- Generates a validator function which validates a value is equal to the specified one
	---@param expected any the value to compare against
	---@return function
	equal = function(expected)
		return function(value)
			if expected ~= value then
				return false, "Expected value " .. vim.inspect(value) .. "to be equal to " .. vim.inspect(expected)
			end

			return true
		end
	end,
	--- Generates a validator function which validates a value is among to the specified ones
	---@param expected table the values to compare against
	---@return function
	one_of = function(expected)
		return function(value)
			for _, expected_value in ipairs(expected) do
				if expected_value == value then
					return true
				end
			end

			return false, "Expected value " .. vim.inspect(value) .. " to be one of " .. vim.inspect(expected)
		end
	end,
	--- Generates a validator function which validates a value is a string matching a given pattern
	---@param pattern string the pattern to match against
	---@return function
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
	--- Generates a validator function which validates a number is greater than a given one
	---@param min number the number to compare against
	---@return function
	greater_than = function(min)
		return function(value)
			local is_valid = type(value) == "number" and value > min

			if not is_valid then
				return false, "Expected value " .. vim.inspect(value) .. " to be a number above " .. tostring(min)
			end

			return true
		end
	end,
	--- Generates a validator function which validates a number is less than a given one
	---@param max number the number to compare against
	---@return function
	less_than = function(max)
		return function(value)
			local is_valid = type(value) == "number" and value < max

			if not is_valid then
				return false, "Expected value " .. vim.inspect(value) .. " to be a number below " .. tostring(max)
			end

			return true
		end
	end,
	--- Generates a validator function which validates a list using the validators given
	---@param list_validators table validators to use for the list
	---@return function
	list = function(list_validators)
		return function(list)
			if type(list) ~= "table" then
				return false, "Expected table, got " .. vim.inspect(list)
			end

			local validation_map = get_list_validation_map(list, list_validators)
			return Validator.validate(validation_map)
		end
	end,
	--- Generates a validator function which validates a dictionary using the validators given
	---@param shape_validators table validators to use for the dictionary
	---@return function
	shape = function(shape_validators)
		return function(shape)
			if type(shape) ~= "table" then
				return false, "Expected table, got " .. vim.inspect(shape)
			end

			local validation_map = get_table_validation_map(shape, shape_validators)
			return Validator.validate(validation_map)
		end
	end,
	--- Generates a function decorator which validates arguments passed to the decorated function
	---@param arguments_validators table validators to use for function arguments
	---@return function
	arguments = function(arguments_validators)
		local validate_arguments = Validator.f.list(arguments_validators)

		return setmetatable({
			decorate = function(func)
				return function(...)
					local valid, validation_error = validate_arguments({ ... })

					if not valid then
						error("Arguments validation failed: " .. validation_error)
					end

					return func(...)
				end
			end,
		}, {
			__call = function(self, ...)
				return self.decorate(...)
			end,
			__concat = function(self, ...)
				return self.decorate(...)
			end,
		})
	end,
}

return Validator
