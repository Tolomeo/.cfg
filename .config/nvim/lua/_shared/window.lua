local fn = require("_shared.fn")
local validator = require("_shared.validator")

local Window = {}

Window.buffer = vim.api.nvim_win_get_buf

Window.get = validator.f.arguments({
	validator.f.shape({
		"number",
		vars = validator.f.optional("table"),
		options = validator.f.optional("table"),
	}),
}) .. function(args)
	local winnr = args[1]
	local win = {
		winnr = winnr,
		buffer = vim.api.nvim_win_get_buf(winnr),
	}

	if args.vars then
		win.vars = fn.ireduce(args.vars, function(tab_vars, var_name)
			local ok, var_value = pcall(vim.api.nvim_tabpage_get_var, winnr, var_name)

			if ok then
				tab_vars[var_name] = var_value
			end

			return tab_vars
		end, {})
	end

	if args.options then
		win.options = fn.ireduce(args.options, function(win_options, option_name)
			local ok, option_value = pcall(vim.api.nvim_win_get_option, winnr, option_name)

			if ok then
				win_options[option_name] = option_value
			end

			return win_options
		end, {})
	end

	return win
end

return Window
