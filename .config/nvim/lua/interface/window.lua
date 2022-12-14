local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")
local settings = require("settings")

---@class Interface.Window
local Window = {}

function Window:_setup_keymaps()
	local keymaps = settings.keymaps()

	key.nmap(
		-- Windows navigation
		{ keymaps["window.cursor.left"], "<C-w>h" },
		{ keymaps["window.cursor.down"], "<C-w>j" },
		{ keymaps["window.cursor.up"], "<C-w>k" },
		{ keymaps["window.cursor.right"], "<C-w>l" },
		{ keymaps["window.cursor.next"], "<C-w>w" },
		{ keymaps["window.cursor.prev"], "<C-w>W" },
		-- Exchange current window with the next one
		{ keymaps["window.swap.next"], "<C-w>x" },
		-- Resizing the current window
		{ keymaps["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymaps["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymaps["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymaps["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymaps["window.fullwidth.bottom"], "<C-w>J" },
		{ keymaps["window.fullheight.left"], "<C-w>H" },
		{ keymaps["window.fullheight.right"], "<C-w>L" },
		{ keymaps["window.fullwidth.top"], "<C-w>K" },
		-- Resetting windows size
		{ keymaps["window.equalize"], "<C-w>=" },
		-- Maximising current window size
		{ keymaps["window.maximize"], "<C-w>_<C-w>|" },
		-- Splits
		{ keymaps["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymaps["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.vmap(
		-- Windows Navigation
		{ keymaps["window.cursor.left"], "<Esc><C-w>h" },
		{ keymaps["window.cursor.down"], "<Esc><C-w>j" },
		{ keymaps["window.cursor.up"], "<Esc><C-w>k" },
		{ keymaps["window.cursor.right"], "<Esc><C-w>l" },
		{ keymaps["window.cursor.next"], "<Esc><C-w>w" },
		{ keymaps["window.cursor.prev"], "<Esc><C-w>W" },
		-- Exchange current window with the next one
		{ keymaps["window.swap.next"], "<Esc><C-w>x" },
		-- Resizing the current window
		{ keymaps["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymaps["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymaps["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymaps["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymaps["window.fullwidth.bottom"], "<Esc><C-w>J" },
		{ keymaps["window.fullheight.left"], "<Esc><C-w>H" },
		{ keymaps["window.fullheight.right"], "<Esc><C-w>L" },
		{ keymaps["window.fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ keymaps["window.equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ keymaps["window.maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ keymaps["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymaps["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.imap(
		-- Windows Navigation
		{ keymaps["window.cursor.left"], "<Esc><C-w>h" },
		{ keymaps["window.cursor.down"], "<Esc><C-w>j" },
		{ keymaps["window.cursor.up"], "<Esc><C-w>k" },
		{ keymaps["window.cursor.right"], "<Esc><C-w>l" },
		{ keymaps["window.cursor.next"], "<Esc><C-w>w" },
		{ keymaps["window.cursor.prev"], "<Esc><C-w>W" },
		-- Exchange current window with the next one
		{ keymaps["window.swap.next"], "<Esc><C-w>x" },
		-- Resizing the current window
		{ keymaps["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymaps["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymaps["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymaps["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymaps["window.fullwidth.bottom"], "<Esc><C-w>J" },
		{ keymaps["window.fullheight.left"], "<Esc><C-w>H" },
		{ keymaps["window.fullheight.right"], "<Esc><C-w>L" },
		{ keymaps["window.fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ keymaps["window.equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ keymaps["window.maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ keymaps["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymaps["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.tmap(
		-- Windows navigation
		{ keymaps["window.cursor.left"], "<C-\\><C-n><C-w>h" },
		{ keymaps["window.cursor.down"], "<C-\\><C-n><C-w>j" },
		{ keymaps["window.cursor.up"], "<C-\\><C-n><C-w>k" },
		{ keymaps["window.cursor.right"], "<C-\\><C-n><C-w>l" },
		{ keymaps["window.cursor.next"], "<C-\\><C-n><C-w>w" },
		{ keymaps["window.cursor.prev"], "<C-\\><C-n><C-w>W" },
		-- Exchange current window with the next one
		{ keymaps["window.swap.next"], "<C-\\><C-n><C-w>x" },
		-- Resizing the current window
		{ keymaps["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymaps["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymaps["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymaps["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymaps["window.fullwidth.bottom"], "<C-\\><C-n><C-w>J" },
		{ keymaps["window.fullheight.left"], "<C-\\><C-n><C-w>H" },
		{ keymaps["window.fullheight.right"], "<C-\\><C-n><C-w>L" },
		{ keymaps["window.fullwidth.top"], "<C-\\><C-n><C-w>K" },
		-- Resetting windows size
		{ keymaps["window.equalize"], "<C-\\><C-n><C-w>=" },
		-- Maximising current window size
		{ keymaps["window.maximize"], "<C-\\><C-n><C-w>_<C-w>|" },
		-- Splits
		{ keymaps["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymaps["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
end

Window.plugins = {}

function Window:setup()
	self:_setup_keymaps()
end

function Window:_get_modal_config()
	local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
	local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
	local col = (math.ceil(vim.o.columns - width) / 2) - 1
	local row = (math.ceil(vim.o.lines - height) / 2) - 1
	return {
		col = col,
		row = row,
		width = width,
		height = height,
		border = "solid",
		style = "minimal",
		relative = "editor",
	}
end

---@type fun(self: Interface.Window, options: { [number]: number, on_resize: function | nil, on_resized: function | nil })
Window.modal = validator.f.arguments({
	validator.f.equal(Window),
	validator.f.shape({
		"number",
		on_resize = validator.f.optional("function"),
		on_resized = validator.f.optional("function"),
	}),
}) .. function(self, options)
	local buffer = options[1]
	local window = vim.api.nvim_open_win(buffer, true, self:_get_modal_config())
	local on_vim_resized = function()
		if not vim.api.nvim_win_is_valid(window) then
			return
		end

		local updatedConfig = self:_get_modal_config()

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

return Module:new(Window)
