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
---@param error_message? string error_message returned
---@return boolean, string|nil
Validator.validate = function(validationMap, error_message)
	error_message = error_message or "%s"
	local result, validation_error = pcall(vim.validate, validationMap)

	return result, error and string.format(error_message, validation_error) or nil
end

Validator.f = {
	--- Has a validator returning true when at least one of the passed validators returns true
	--- NOTE: doesn't support table validators
	---@param validators table the validators to be applied
	---@param error_message? string error message thrown
	---@return function
	any_of = function(validators, error_message)
		error_message = error_message or "Any_of validation error: %s"

		return function(value)
			for _, validator in ipairs(validators) do
				local valid = ({
					string = function(v)
						return type(v) == validator
					end,
					["function"] = function(v)
						return validator(v)
					end,
				})[type(validator)](value)

				if valid then
					return true
				end
			end

			return false, string.format(error_message, "none of the validators succeeded")
		end
	end,
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
	---@param error_message? string error_message returned
	---@return function
	equal = function(expected, error_message)
		error_message = error_message or "Equality validation error: %s"

		return function(value)
			if expected ~= value then
				return false,
					string.format(
						error_message,
						"Expected value " .. vim.inspect(value) .. "to be equal to " .. vim.inspect(expected)
					)
			end

			return true
		end
	end,
	---Generates a validator function which validates a value has and expected metatable
	---@param parent table the table to look for as a metatable
	---@param error_message? string error_message returned
	---@return function
	instance_of = function(parent, error_message)
		error_message = error_message or "Instance validation error: %s"

		return function(value)
			local expected = tostring(parent)
			local mt = getmetatable(value)

			while true do
				if mt == nil then
					return false,
						string.format(
							error_message,
							"Expected value " .. vim.inspect(value) .. " to be instance of " .. vim.inspect(expected)
						)
				end

				if tostring(mt.__index) == expected then
					return true
				end

				mt = getmetatable(mt.__index)
			end
		end
	end,
	--- Generates a validator function which validates a value is among to the specified ones
	---@param expected table the values to compare against
	---@param error_message? string error_message returned
	---@return function
	one_of = function(expected, error_message)
		error_message = error_message or "Union validation error: %s"

		return function(value)
			for _, expected_value in ipairs(expected) do
				if expected_value == value then
					return true
				end
			end

			return false,
				string.format(
					error_message,
					"Expected value " .. vim.inspect(value) .. " to be one of " .. vim.inspect(expected)
				)
		end
	end,
	--- Generates a validator function which validates a value is a string matching a given pattern
	---@param pattern string the pattern to match against
	---@param error_message? string error_message returned
	---@return function
	pattern = function(pattern, error_message)
		error_message = error_message or "Pattern validation error: %s"

		return function(value)
			if type(value) ~= "string" then
				return false, string.format(error_message, "Expected string, got " .. vim.inspect(value))
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
	---@param error_message? string error_message returned
	---@return function
	greater_than = function(min, error_message)
		error_message = error_message or "Number validation error: %s"

		return function(value)
			local is_valid = type(value) == "number" and value > min

			if not is_valid then
				return false,
					string.format(
						error_message,
						"Expected value " .. vim.inspect(value) .. " to be a number above " .. tostring(min)
					)
			end

			return true
		end
	end,
	--- Generates a validator function which validates a number is less than a given one
	---@param max number the number to compare against
	---@param error_message? string error_message returned
	---@return function
	less_than = function(max, error_message)
		error_message = error_message or "Number validation error: %s"

		return function(value)
			local is_valid = type(value) == "number" and value < max

			if not is_valid then
				return false,
					string.format("Expected value " .. vim.inspect(value) .. " to be a number below " .. tostring(max))
			end

			return true
		end
	end,
	--- Generates a validator function which validates a list using the validators given
	---@param list_validators table validators to use for the list
	---@param error_message? string error message thrown
	---@return function
	list = function(list_validators, error_message)
		error_message = error_message or "List validation error: %s"

		return function(list)
			if type(list) ~= "table" then
				return false, string.format("Expected table, got " .. type(list))
			end

			local validation_map = get_list_validation_map(list, list_validators)
			return Validator.validate(validation_map, error_message)
		end
	end,
	--- Generates a validator function which validates a dictionary using the validators given
	---@param shape_validators table validators to use for the dictionary
	---@param error_message? string error_message returned
	---@return function
	shape = function(shape_validators, error_message)
		error_message = error_message or "Shape validation error: %s"

		return function(shape)
			if type(shape) ~= "table" then
				return false, string.format(error_message, "Expected table, got " .. type(shape))
			end

			local validation_map = get_table_validation_map(shape, shape_validators)
			return Validator.validate(validation_map, error_message)
		end
	end,

	---@class ArgumentsValidator
	---@operator concat:function
	---@operator call:function

	--- Generates a function decorator which validates arguments passed to the decorated function
	---@param arguments_validators table validators to use for function arguments
	---@param error_message? string error message thrown
	---@return ArgumentsValidator
	arguments = function(arguments_validators, error_message)
		error_message = error_message or "Arguments validation error: %s"
		local validate_arguments = Validator.f.list(arguments_validators)

		return setmetatable({
			decorate = function(func)
				return function(...)
					local valid, validation_error = validate_arguments({ ... })

					if not valid then
						error(string.format(error_message, validation_error))
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
