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
	return ireduce(list, function(list_validation, item, index)
		local key = tostring(index)
		local validator = validators_list[index] or validators_list[#validators_list]
		local err = type(validator) == "function" and "correct value at position " .. key or nil

		list_validation[key] = { item, validator, err }
		return list_validation
	end, {})
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

Validate.t = {
	optional = function(validator)
		if type(validator) == "table" then
			table.insert(validator, "nil")
			return validator
		end

		return { validator, "nil" }
	end,
	equal = function(expected)
		return function(value)
			if expected ~= value then
				return false
			end

			return true
		end
	end,
	list = function(...)
		local list_validators = { ... }

		return function(list)
			if type(list) ~= "table" then
				return false
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
					error("Arguments validation error: " .. validation_error)
				end

				return func(...)
			end
		end,
	})
end

return Validate
