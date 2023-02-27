local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")
local settings = require("settings")
local fn = require("_shared.fn")

local Window = Module:extend({})

function Window:setup()
	local keymap = settings.keymap

	key.nmap(
		-- Windows navigation
		{ keymap["window.cursor.left"], fn.bind(self.goto_left, self) },
		{ keymap["window.cursor.down"], fn.bind(self.goto_down, self) },
		{ keymap["window.cursor.up"], fn.bind(self.goto_up, self) },
		{ keymap["window.cursor.right"], fn.bind(self.goto_right, self) },
		{ keymap["window.cursor.next"], fn.bind(self.goto_next, self) },
		{ keymap["window.cursor.prev"], fn.bind(self.goto_prev, self) },
		-- Exchange current window with the next one
		{ keymap["window.swap.next"], fn.bind(self.swapwith_next, self) },
		-- Resizing the current window
		{ keymap["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymap["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymap["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymap["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymap["window.fullwidth.bottom"], "<C-w>J" },
		{ keymap["window.fullheight.left"], "<C-w>H" },
		{ keymap["window.fullheight.right"], "<C-w>L" },
		{ keymap["window.fullwidth.top"], "<C-w>K" },
		-- Resetting windows size
		{ keymap["window.equalize"], "<C-w>=" },
		-- Maximising current window size
		{ keymap["window.maximize"], "<C-w>_<C-w>|" },
		-- Splits
		{ keymap["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymap["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.vmap(
		-- Windows navigation
		{ keymap["window.cursor.left"], fn.bind(self.goto_left, self) },
		{ keymap["window.cursor.down"], fn.bind(self.goto_down, self) },
		{ keymap["window.cursor.up"], fn.bind(self.goto_up, self) },
		{ keymap["window.cursor.right"], fn.bind(self.goto_right, self) },
		{ keymap["window.cursor.next"], fn.bind(self.goto_next, self) },
		{ keymap["window.cursor.prev"], fn.bind(self.goto_prev, self) },
		-- Exchange current window with the next one
		{ keymap["window.swap.next"], fn.bind(self.swapwith_next, self) },
		-- Resizing the current window
		{ keymap["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymap["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymap["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymap["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymap["window.fullwidth.bottom"], "<Esc><C-w>J" },
		{ keymap["window.fullheight.left"], "<Esc><C-w>H" },
		{ keymap["window.fullheight.right"], "<Esc><C-w>L" },
		{ keymap["window.fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ keymap["window.equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ keymap["window.maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ keymap["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymap["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.imap(
		-- Windows navigation
		{ keymap["window.cursor.left"], fn.bind(self.goto_left, self) },
		{ keymap["window.cursor.down"], fn.bind(self.goto_down, self) },
		{ keymap["window.cursor.up"], fn.bind(self.goto_up, self) },
		{ keymap["window.cursor.right"], fn.bind(self.goto_right, self) },
		{ keymap["window.cursor.next"], fn.bind(self.goto_next, self) },
		{ keymap["window.cursor.prev"], fn.bind(self.goto_prev, self) },
		-- Exchange current window with the next one
		{ keymap["window.swap.next"], fn.bind(self.swapwith_next, self) },
		-- Resizing the current window
		{ keymap["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymap["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymap["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymap["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymap["window.fullwidth.bottom"], "<Esc><C-w>J" },
		{ keymap["window.fullheight.left"], "<Esc><C-w>H" },
		{ keymap["window.fullheight.right"], "<Esc><C-w>L" },
		{ keymap["window.fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ keymap["window.equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ keymap["window.maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ keymap["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymap["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.tmap(
		-- Windows navigation
		{ keymap["window.cursor.left"], fn.bind(self.goto_left, self) },
		{ keymap["window.cursor.down"], fn.bind(self.goto_down, self) },
		{ keymap["window.cursor.up"], fn.bind(self.goto_up, self) },
		{ keymap["window.cursor.right"], fn.bind(self.goto_right, self) },
		{ keymap["window.cursor.next"], fn.bind(self.goto_next, self) },
		{ keymap["window.cursor.prev"], fn.bind(self.goto_prev, self) },
		-- Exchange current window with the next one
		{ keymap["window.swap.next"], fn.bind(self.swapwith_next, self) },
		-- Resizing the current window
		{ keymap["window.shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ keymap["window.shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ keymap["window.expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ keymap["window.expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ keymap["window.fullwidth.bottom"], "<C-\\><C-n><C-w>J" },
		{ keymap["window.fullheight.left"], "<C-\\><C-n><C-w>H" },
		{ keymap["window.fullheight.right"], "<C-\\><C-n><C-w>L" },
		{ keymap["window.fullwidth.top"], "<C-\\><C-n><C-w>K" },
		-- Resetting windows size
		{ keymap["window.equalize"], "<C-\\><C-n><C-w>=" },
		-- Maximising current window size
		{ keymap["window.maximize"], "<C-\\><C-n><C-w>_<C-w>|" },
		-- Splits
		{ keymap["window.split.horizontal"], "<Cmd>split<Cr>" },
		{ keymap["window.split.vertical"], "<Cmd>vsplit<Cr>" }
	)
end

function Window:goto_left()
	return vim.fn.execute("wincmd h", "")
end

function Window:goto_down()
	return vim.fn.execute("wincmd j", "")
end

function Window:goto_up()
	return vim.fn.execute("wincmd k", "")
end

function Window:goto_right()
	return vim.fn.execute("wincmd l", "")
end

function Window:goto_prev()
	return vim.fn.execute("wincmd w", "")
end

function Window:goto_next()
	return vim.fn.execute("wincmd W", "")
end

function Window:swapwith_next()
	return vim.fn.execute("wincmd x", "")
end

function Window:float_config()
	return {
		focusable = true,
		border = "solid",
		style = "minimal",
		relative = "cursor",
	}
end

function Window:modal_config()
	local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
	local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
	local col = (math.ceil(vim.o.columns - width) / 2) - 1
	local row = (math.ceil(vim.o.lines - height) / 2) - 1
	local config = fn.merge(self:float_config(), {
		col = col,
		row = row,
		width = width,
		height = height,
		relative = "editor",
	})

	return config
end

Window.modal = validator.f.arguments({
	validator.f.instance_of(Window),
	validator.f.shape({
		"number",
		on_resize = validator.f.optional("function"),
		on_resized = validator.f.optional("function"),
	}),
}) .. function(self, options)
	local buffer = options[1]
	local window = vim.api.nvim_open_win(buffer, true, self:modal_config())
	local on_vim_resized = function()
		if not vim.api.nvim_win_is_valid(window) then
			return
		end

		local updatedConfig = self:modal_config()

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
	}, {
		"VimResized",
		buffer,
		on_vim_resized,
	})

	return window
end

return Window:new()
