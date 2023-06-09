local fn = require("_shared.fn")
local validator = require("_shared.validator")

local M = {}

M.create = validator.f.arguments({
	validator.f.shape({}),
}) .. function(config)
	vim.api.nvim_command("tabnew")

	local tab = vim.api.nvim_get_current_tabpage()

	M.update(tab, config)

	vim.api.nvim_command("tabnext -")

	return tab
end

M.update = validator.f.arguments({
	"number",
	validator.f.shape({
		vars = validator.f.optional(validator.f.shape({})),
	}),
}) .. function(tab, config)
	config = fn.merge({ vars = {} }, config)

	fn.keach(config.vars, function(var_value, var_name)
		vim.api.nvim_tabpage_set_var(tab, var_name, var_value)
	end)

	return tab
end

M.cd = validator.f.arguments({
	"string",
}) .. function(path)
	return vim.api.nvim_command(string.format("tcd %s", path))
end

return M
