local fn = require("_shared.fn")
local validator = require("_shared.validator")
local win = require("_shared.window")

local Tab = {}

Tab.create = validator.f.arguments({
	validator.f.shape({
		validator.f.optional("string"),
	}),
}) .. function(args)
	local files = fn.imap(args, function(file)
		return file
	end)
	local config = fn.kreduce(args, function(_config, config_value, config_name)
		_config[config_name] = config_value
		return _config
	end, {})

	vim.api.nvim_command(string.format("tabnew %s", table.concat(files, " ")))

	local handle = vim.api.nvim_get_current_tabpage()
	config[1] = handle

	Tab.update(config)

	vim.api.nvim_command("tabnext -")

	return handle
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

Tab.get = validator.f.arguments({ validator.f.shape({
	"number",
	vars = validator.f.optional("table"),
}) }) .. function(options)
	local tabpage = options[1]
	local tab = {
		tabpage = tabpage,
		number = vim.api.nvim_tabpage_get_number(tabpage),
	}

	if options.vars then
		tab.vars = fn.ireduce(options.vars, function(tab_vars, var_name)
			local ok, var_value = pcall(vim.api.nvim_tabpage_get_var, tabpage, var_name)

			if ok then
				tab_vars[var_name] = var_value
			end

			return tab_vars
		end, {})
	end

	return tab
end

Tab.list = vim.api.nvim_list_tabpages

Tab.current = vim.api.nvim_get_current_tabpage

Tab.get_list = validator.f.arguments({
	validator.f.optional("table"),
}) .. function(options)
	return fn.imap(vim.api.nvim_list_tabpages(), function(tabpage)
		return Tab.get(fn.merge({ tabpage }, options))
	end)
end

Tab.get_by_number = validator.f.arguments({
	validator.f.shape({
		"number",
	}),
}) .. function(args)
	local num = args[1]
	local options = fn.kreduce(args, function(_options, option_value, option_name)
		_options[option_name] = option_value
		return _options
	end, {})

	return fn.ifind(Tab.get_list(options), function(tab)
		return tab.number == num
	end)
end

Tab.get_current = function(options)
	options = options and options or {}
	options[1] = vim.api.nvim_get_current_tabpage()

	return Tab.get(options)
end

Tab.go_to = function(tab)
	return vim.fn.execute(string.format("tabnext %s", tab))
end

Tab.get_windows = function(args)
	local tab = args[1]

	return fn.imap(vim.api.nvim_tabpage_list_wins(tab), function(winnr)
		return win.get({ winnr })
	end)
end

return Tab
