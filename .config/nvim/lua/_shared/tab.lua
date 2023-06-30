local fn = require("_shared.fn")
local arr = require("_shared.array")
local validator = require("_shared.validator")
local win = require("_shared.window")

local Tab = {}

Tab.list = vim.api.nvim_list_tabpages

Tab.current = vim.api.nvim_get_current_tabpage

Tab.window = vim.api.nvim_tabpage_get_win

Tab.number = vim.api.nvim_tabpage_get_number

Tab.buffer = function(tab_handle)
	return win.buffer(Tab.window(tab_handle))
end

Tab.create = validator.f.arguments({
	validator.f.shape({
		validator.f.optional("string"),
	}),
}) .. function(args)
	local file = args[1] and args[1] or ""

	vim.api.nvim_command(string.format("tabnew %s", file))

	local update_args = fn.kreduce(args, function(_config, config_value, config_name)
		_config[config_name] = config_value
		return _config
	end, { Tab.current() })

	return Tab.update(update_args)
end

Tab.update = validator.f.arguments({
	validator.f.shape({
		"number",
		vars = validator.f.optional(validator.f.shape({})),
	}),
}) .. function(args)
	local tab = args[1]
	local tab_options = fn.kreduce(args, function(_tab_options, value, key)
		_tab_options[key] = value
		return _tab_options
	end, { vars = {} })

	fn.keach(tab_options.vars, function(var_value, var_name)
		vim.api.nvim_tabpage_set_var(tab, var_name, var_value)
	end)

	return tab
end

Tab.cd = validator.f.arguments({
	"string",
}) .. function(path)
	return vim.api.nvim_command(string.format("tcd %s", path))
end

Tab.get_list = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(options)
	return arr.map(Tab.list(), function(handle)
		return Tab.get(fn.merge({ handle }, options))
	end)
end

Tab.get = validator.f.arguments({ validator.f.shape({
	"number",
	vars = validator.f.optional("table"),
}) }) .. function(options)
	local handle = options[1]
	local tab = {
		handle = handle,
		number = vim.api.nvim_tabpage_get_number(handle),
	}

	if options.vars then
		tab.vars = arr.reduce(options.vars, function(tab_vars, var_name)
			local ok, var_value = pcall(vim.api.nvim_tabpage_get_var, handle, var_name)

			if ok then
				tab_vars[var_name] = var_value
			end

			return tab_vars
		end, {})
	end

	return tab
end

Tab.get_by_number = validator.f.arguments({
	validator.f.shape({
		"number",
	}),
}) .. function(args)
	local number = args[1]
	local get_list_args = fn.kreduce(args, function(_options, option_value, option_name)
		_options[option_name] = option_value
		return _options
	end, {})

	return arr.find(Tab.get_list(get_list_args), function(tab)
		return tab.number == number
	end)
end

Tab.get_current = function(options)
	options = options and options or {}
	options[1] = Tab.current()

	return Tab.get(options)
end

Tab.go_to = function(tab)
	return vim.fn.execute(string.format("tabnext %s", tab))
end

Tab.get_windows = function(args)
	local tab = args[1]

	return arr.map(vim.api.nvim_tabpage_list_wins(tab), function(window_handle)
		return win.get({ window_handle })
	end)
end

return Tab
