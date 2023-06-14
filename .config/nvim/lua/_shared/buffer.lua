local fn = require("_shared.fn")
local validator = require("_shared.validator")

local validate_buffer = validator.f.shape({
	bufnr = "number",
	name = "string",
	vars = validator.f.optional("table"),
})

local M = {}

M.create = validator.f.arguments({
	validator.f.shape({}),
}) .. function(config)
	config[1] = vim.api.nvim_create_buf(true, false)
	return M.update(config)
end

M.update = validator.f.arguments({
	validator.f.shape({
		"number",
		name = validator.f.optional("string"),
		options = validator.f.optional(validator.f.shape({})),
		vars = validator.f.optional(validator.f.shape({})),
	}),
}) .. function(config)
	local buf = config[1]
	local buf_options = fn.kreduce(config, function(_options, value, key)
		_options[key] = value
		return _options
	end, { options = {}, vars = {} })

	if buf_options.name then
		vim.api.nvim_buf_set_name(buf, buf_options.name)
	end

	fn.keach(buf_options.options, function(option_value, option_name)
		vim.api.nvim_buf_set_option(buf, option_name, option_value)
	end)

	fn.keach(buf_options.vars, function(var_value, var_name)
		vim.api.nvim_buf_set_var(buf, var_name, var_value)
	end)

	return buf
end

M.get_id_by_name = validator.f.arguments({
	validator.f.shape({
		"string",
	}),
}) .. function(options)
	local name = options[1]
	local bufnr = vim.fn.bufnr(name)

	return bufnr ~= -1 and bufnr or nil
end

M.get = validator.f.arguments({
	validator.f.shape({
		"number",
		vars = validator.f.optional(validator.f.list({ "string" })),
	}),
}) .. function(config)
	local bufnr = config[1]
	local buffer = { bufnr = bufnr, name = vim.api.nvim_buf_get_name(bufnr) }

	if config.vars then
		buffer.vars = fn.ireduce(config.vars, function(buffer_vars, var_name)
			local ok, var_value = pcall(vim.api.nvim_buf_get_var, bufnr, var_name)

			if ok then
				buffer_vars[var_name] = var_value
			end

			return buffer_vars
		end, {})
	end

	return buffer
end

M.get_all = validator.f.arguments({
	validator.f.optional(validator.f.shape({})),
}) .. function(options)
	return fn.imap(vim.api.nvim_list_bufs(), function(bufnr)
		return M.get(fn.merge({ bufnr }, options))
	end)
end

M.find_by_name = function(name)
	local buf = fn.ifind(M.get_all(), function(buffer)
		return buffer.name == name
	end)

	return buf and buf.bufnr or nil
end

M.delete = validator.f.arguments({
	validator.f.shape({
		"number",
		force = validator.f.optional("boolean"),
	}),
}) .. function(config)
	local buf = config[1]
	local options = fn.kreduce(config, function(_options, value, key)
		_options[key] = value
		return _options
	end, { force = false })

	return vim.api.nvim_buf_delete(buf, options)
end

M.is_unnamed = validator.f.arguments({
	validate_buffer,
}) .. function(buffer)
	return buffer.name == ""
end

return M
