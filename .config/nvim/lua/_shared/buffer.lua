local fn = require("_shared.fn")
local validator = require("_shared.validator")

local validate_buffer = validator.f.shape({
	handle = "number",
	name = "string",
	vars = validator.f.optional("table"),
})

local Buffer = {}

Buffer.current = vim.api.nvim_get_current_buf

Buffer.list = vim.api.nvim_list_bufs

Buffer.create = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(args)
	args = fn.merge({}, args)
	args[1] = vim.api.nvim_create_buf(true, false)
	return Buffer.update(args)
end

Buffer.update = validator.f.arguments({
	validator.f.shape({
		"number",
		name = validator.f.optional("string"),
		options = validator.f.optional("table"),
		vars = validator.f.optional("table"),
	}),
}) .. function(config)
	local buf = config[1]
	local buf_options = fn.kreduce(config, function(_options, value, key)
		_options[key] = value
		return _options
	end, { options = {}, vars = {} })

	-- vim.print(config, buf_options)

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

Buffer.get_handle_by_name = validator.f.arguments({
	validator.f.shape({
		"string",
	}),
}) .. function(options)
	local name = options[1]
	local handle = vim.fn.bufnr(name)

	return handle ~= -1 and handle or nil
end

Buffer.get = validator.f.arguments({
	validator.f.shape({
		"number",
		vars = validator.f.optional(validator.f.list({ "string" })),
		options = validator.f.optional(validator.f.list({ "string" })),
	}),
}) .. function(config)
	local handle = config[1]
	local buffer = { handle = handle, name = vim.api.nvim_buf_get_name(handle) }

	if config.vars then
		buffer.vars = fn.ireduce(config.vars, function(buffer_vars, var_name)
			local ok, var_value = pcall(vim.api.nvim_buf_get_var, handle, var_name)

			if ok then
				buffer_vars[var_name] = var_value
			end

			return buffer_vars
		end, {})
	end

	if config.options then
		buffer.options = fn.ireduce(config.options, function(buffer_options, option_name)
			local ok, option_value = pcall(vim.api.nvim_buf_get_option, handle, option_name)

			if ok then
				buffer_options[option_name] = option_value
			end

			return buffer_options
		end, {})
	end

	return buffer
end

Buffer.get_current = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(args)
	args = fn.merge({}, args, { Buffer.current() })

	return Buffer.get(args)
end

Buffer.get_all = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(options)
	return fn.imap(Buffer.list(), function(handle)
		return Buffer.get(fn.merge({ handle }, options))
	end)
end

Buffer.get_listed = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(args)
	return fn.ifilter(Buffer.get_all(args), function(buffer)
		return vim.api.nvim_buf_get_option(buffer.handle, "buflisted")
	end)
end

Buffer.find_by_name = function(name)
	local buf = fn.ifind(Buffer.get_all(), function(buffer)
		return buffer.name == name
	end)

	return buf and buf.handle or nil
end

Buffer.find_by_pattern = function(pattern)
	return fn.ifind(Buffer.get_all(), function(buffer)
		return string.match(buffer.name, pattern)
	end)
end

Buffer.delete = validator.f.arguments({
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

Buffer.is_unnamed = validator.f.arguments({
	validate_buffer,
}) .. function(buffer)
	return buffer.name == ""
end

return Buffer
