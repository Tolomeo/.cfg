local Module = require("_shared.module")
local au = require("_shared.au")
local validator = require("_shared.validator")

local defaults = {
	modal = {
		border = "solid",
		style = "minimal",
		relative = "editor",
	},
}

local Window = Module:new({
	plugins = {},
})

Window._get_modal_config = function()
	local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
	local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
	local col = (math.ceil(vim.o.columns - width) / 2) - 1
	local row = (math.ceil(vim.o.lines - height) / 2) - 1
	return vim.tbl_extend("force", {
		col = col,
		row = row,
		width = width,
		height = height,
	}, defaults.modal)
end

Window.modal = validator.f.arguments({
	validator.f.shape({
		"number",
		on_resize = validator.f.optional("function"),
		on_resized = validator.f.optional("function"),
	}),
}) .. function(options)
	local buffer = options[1]
	local window = vim.api.nvim_open_win(buffer, true, Window._get_modal_config())
	local on_vim_resized = function()
		if not vim.api.nvim_win_is_valid(window) then
			return
		end

		local updatedConfig = Window._get_modal_config()

		if options.on_resize then
			options.on_resize(updatedConfig)
		end

		vim.api.nvim_win_set_config(window, updatedConfig)

		if options.on_resized then
			options.on_resized(updatedConfig)
		end
	end

	au.group({
		"Interface.Modal",
		{
			{
				"VimResized",
				buffer,
				on_vim_resized,
			},
		},
	})

	return window
end

return Window
