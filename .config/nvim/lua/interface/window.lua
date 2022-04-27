local Module = require("utils.module")
local au = require("utils.au")

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

function Window.modal(options)
	local buffer = options[1]
	local on_resize = options.on_resize
	local on_resized = options.on_resized

	local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
	local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
	local col = (math.ceil(vim.o.columns - width) / 2) - 1
	local row = (math.ceil(vim.o.lines - height) / 2) - 1
	local window = vim.api.nvim_open_win(
		buffer,
		true,
		vim.tbl_extend("force", {
			col = col,
			row = row,
			width = width,
			height = height,
		}, defaults.modal)
	)

	au.group({
		"Interface.Modal",
		{
			{
				"VimResized",
				nil,
				-- TODO: debounce this
				function()
					if not vim.api.nvim_win_is_valid(window) then
						return
					end

					local updatedWidth = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
					local updatedHeight = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
					local updatedCol = (math.ceil(vim.o.columns - width) / 2) - 1
					local updatedRow = (math.ceil(vim.o.lines - height) / 2) - 1
					local updatedConfig = vim.tbl_extend("force", {
						col = updatedCol,
						row = updatedRow,
						width = updatedWidth,
						height = updatedHeight,
					}, defaults.modal)

					if on_resize then
						on_resize(updatedConfig)
					end

					vim.api.nvim_win_set_config(window, updatedConfig)

					if on_resized then
						on_resized(updatedConfig)
					end
				end,
				buffer = buffer,
			},
		},
	})

	return window
end

return Window
