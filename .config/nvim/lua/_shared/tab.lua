local fn = require("_shared.fn")
local validator = require("_shared.validator")

local M = {}

M.create = validator.f.arguments({
	validator.f.shape({}),
}) .. function(config)
	vim.api.nvim_command("tabnew")

	local tab = vim.api.nvim_get_current_tabpage()
	config[1] = tab

	M.update(config)

	vim.api.nvim_command("tabnext -")

	return tab
end

M.update = validator.f.arguments({
	validator.f.shape({
		"number",
		vars = validator.f.optional(validator.f.shape({})),
	}),
}) .. function(config)
	local tab = config[1]
	local tab_options = fn.kreduce(config, function(_tab_options, value, key)
		_tab_options[key] = value
		return _tab_options
	end, { vars = {} })

	fn.keach(tab_options.vars, function(var_value, var_name)
		vim.api.nvim_tabpage_set_var(tab, var_name, var_value)
	end)

	return tab
end

M.cd = validator.f.arguments({
	"string",
}) .. function(path)
	return vim.api.nvim_command(string.format("tcd %s", path))
end

M.get = validator.f.arguments({ validator.f.shape({
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

M.get_current = function(options)
	options = options and options or {}
	options[1] = vim.api.nvim_get_current_tabpage()

	return M.get(options)
end

return M
