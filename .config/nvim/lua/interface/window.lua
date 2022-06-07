local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local default_settings = {
	modal = {
		border = "solid",
		style = "minimal",
		relative = "editor",
	},
	keymaps = {
		["cursor.left"] = "<C-h>",
		["cursor.down"] = "<C-j>",
		["cursor.up"] = "<C-k>",
		["cursor.right"] = "<C-l>",
		["cursor.next"] = "<C-n>",
		["cursor.prev"] = "<C-p>",
		--
		["swap.next"] = "<C-;>",
		["shrink.horizontal"] = "<C-A-j>",
		["shrink.vertical"] = "<C-A-h>",
		["expand.vertical"] = "<C-A-l>",
		["expand.horizontal"] = "<C-A-k>",
		-- Moving windows
		["fullwidth.bottom"] = "<C-S-j>",
		["fullheight.left"] = "<C-S-h>",
		["fullheight.right"] = "<C-S-l>",
		["fullwidth.top"] = "<C-S-k>",
		-- Resetting windows size
		["equalize"] = "<C-=>",
		-- Maximising current window size
		["maximize"] = "<C-+>",
		-- Splits
		["delete"] = "<C-q>",
		["split.horizontal"] = "<C-x>",
		["split.vertical"] = "<C-y>",
	},
}

local Window = {}

Window.plugins = {}

Window.setup = function(settings)
	settings = vim.tbl_deep_extend("force", default_settings, settings)

	key.nmap(
		-- Windows navigation
		{ settings.keymaps["cursor.left"], "<C-w>h" },
		{ settings.keymaps["cursor.down"], "<C-w>j" },
		{ settings.keymaps["cursor.up"], "<C-w>k" },
		{ settings.keymaps["cursor.right"], "<C-w>l" },
		{ settings.keymaps["cursor.next"], "<C-w>w" },
		{ settings.keymaps["cursor.prev"], "<C-w>W" },
		-- Exchange current window with the next one
		{ settings.keymaps["swap.next"], "<C-w>x" },
		-- Resizing the current window
		{ settings.keymaps["shrink.horizontal"], ":resize -3<Cr>" },
		{ settings.keymaps["shrink.vertical"], ":vertical :resize -3<Cr>" },
		{ settings.keymaps["expand.vertical"], ":vertical :resize +3<Cr>" },
		{ settings.keymaps["expand.horizontal"], ":resize +3<Cr>" },
		-- Moving windows
		{ settings.keymaps["fullwidth.bottom"], "<C-w>J" },
		{ settings.keymaps["fullheight.left"], "<C-w>H" },
		{ settings.keymaps["fullheight.right"], "<C-w>L" },
		{ settings.keymaps["fullwidth.top"], "<C-w>K" },
		-- Resetting windows size
		{ settings.keymaps["equalize"], "<C-w>=" },
		-- Maximising current window size
		{ settings.keymaps["maximize"], "<C-w>_<C-w>|" },
		-- Splits
		{ settings.keymaps["delete"], "<Cmd>bdelete<Cr>" },
		{ settings.keymaps["split.horizontal"], "<Cmd>split<Cr>" },
		{ settings.keymaps["split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.vmap(
		-- Windows Navigation
		{ settings.keymaps["cursor.left"], "<Esc><C-w>h" },
		{ settings.keymaps["cursor.down"], "<Esc><C-w>j" },
		{ settings.keymaps["cursor.up"], "<Esc><C-w>k" },
		{ settings.keymaps["cursor.right"], "<Esc><C-w>l" },
		{ settings.keymaps["cursor.next"], "<Esc><C-w>w" },
		{ settings.keymaps["cursor.prev"], "<Esc><C-w>W" }
	)
	key.imap(
		-- Windows Navigation
		{ settings.keymaps["cursor.left"], "<Esc><C-w>h" },
		{ settings.keymaps["cursor.down"], "<Esc><C-w>j" },
		{ settings.keymaps["cursor.up"], "<Esc><C-w>k" },
		{ settings.keymaps["cursor.right"], "<Esc><C-w>l" },
		{ settings.keymaps["cursor.next"], "<Esc><C-w>w" },
		{ settings.keymaps["cursor.prev"], "<Esc><C-w>W" }
	)
	key.tmap(
		-- Windows navigation
		{ settings.keymaps["cursor.left"], "<C-\\><C-n><C-w>h" },
		{ settings.keymaps["cursor.down"], "<C-\\><C-n><C-w>j" },
		{ settings.keymaps["cursor.up"], "<C-\\><C-n><C-w>k" },
		{ settings.keymaps["cursor.right"], "<C-\\><C-n><C-w>l" },
		{ settings.keymaps["cursor.next"], "<C-\\><C-n><C-w>w" },
		{ settings.keymaps["cursor.prev"], "<C-\\><C-n><C-w>W" }
	)
end

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
	}, default_settings.modal)
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

return Module:new(Window)
