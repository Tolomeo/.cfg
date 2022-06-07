local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local default_settings = {
	keymaps = {
		["cursor.left"] = "<C-h>",
		["cursor.down"] = "<C-j>",
		["cursor.up"] = "<C-k>",
		["cursor.right"] = "<C-l>",
		["cursor.next"] = "<C-n>",
		["cursor.prev"] = "<C-p>",
		["swap.next"] = "<C-;>",
		["shrink.horizontal"] = "<C-A-j>",
		["shrink.vertical"] = "<C-A-h>",
		["expand.vertical"] = "<C-A-l>",
		["expand.horizontal"] = "<C-A-k>",
		["fullwidth.bottom"] = "<C-S-j>",
		["fullheight.left"] = "<C-S-h>",
		["fullheight.right"] = "<C-S-l>",
		["fullwidth.top"] = "<C-S-k>",
		["equalize"] = "<C-=>",
		["maximize"] = "<C-+>",
		["split.horizontal"] = "<C-x>",
		["split.vertical"] = "<C-y>",
	},
}

local Window = {}

Window._setup_keymaps = function(settings)
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
		{ settings.keymaps["shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ settings.keymaps["shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ settings.keymaps["expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ settings.keymaps["expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ settings.keymaps["fullwidth.bottom"], "<C-w>J" },
		{ settings.keymaps["fullheight.left"], "<C-w>H" },
		{ settings.keymaps["fullheight.right"], "<C-w>L" },
		{ settings.keymaps["fullwidth.top"], "<C-w>K" },
		-- Resetting windows size
		{ settings.keymaps["equalize"], "<C-w>=" },
		-- Maximising current window size
		{ settings.keymaps["maximize"], "<C-w>_<C-w>|" },
		-- Splits
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
		{ settings.keymaps["cursor.prev"], "<Esc><C-w>W" },
		-- Exchange current window with the next one
		{ settings.keymaps["swap.next"], "<Esc><C-w>x" },
		-- Resizing the current window
		{ settings.keymaps["shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ settings.keymaps["shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ settings.keymaps["expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ settings.keymaps["expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ settings.keymaps["fullwidth.bottom"], "<Esc><C-w>J" },
		{ settings.keymaps["fullheight.left"], "<Esc><C-w>H" },
		{ settings.keymaps["fullheight.right"], "<Esc><C-w>L" },
		{ settings.keymaps["fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ settings.keymaps["equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ settings.keymaps["maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ settings.keymaps["split.horizontal"], "<Cmd>split<Cr>" },
		{ settings.keymaps["split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.imap(
		-- Windows Navigation
		{ settings.keymaps["cursor.left"], "<Esc><C-w>h" },
		{ settings.keymaps["cursor.down"], "<Esc><C-w>j" },
		{ settings.keymaps["cursor.up"], "<Esc><C-w>k" },
		{ settings.keymaps["cursor.right"], "<Esc><C-w>l" },
		{ settings.keymaps["cursor.next"], "<Esc><C-w>w" },
		{ settings.keymaps["cursor.prev"], "<Esc><C-w>W" },
		-- Exchange current window with the next one
		{ settings.keymaps["swap.next"], "<Esc><C-w>x" },
		-- Resizing the current window
		{ settings.keymaps["shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ settings.keymaps["shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ settings.keymaps["expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ settings.keymaps["expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ settings.keymaps["fullwidth.bottom"], "<Esc><C-w>J" },
		{ settings.keymaps["fullheight.left"], "<Esc><C-w>H" },
		{ settings.keymaps["fullheight.right"], "<Esc><C-w>L" },
		{ settings.keymaps["fullwidth.top"], "<Esc><C-w>K" },
		-- Resetting windows size
		{ settings.keymaps["equalize"], "<Esc><C-w>=" },
		-- Maximising current window size
		{ settings.keymaps["maximize"], "<Esc><C-w>_<C-w>|" },
		-- Splits
		{ settings.keymaps["split.horizontal"], "<Cmd>split<Cr>" },
		{ settings.keymaps["split.vertical"], "<Cmd>vsplit<Cr>" }
	)
	key.tmap(
		-- Windows navigation
		{ settings.keymaps["cursor.left"], "<C-\\><C-n><C-w>h" },
		{ settings.keymaps["cursor.down"], "<C-\\><C-n><C-w>j" },
		{ settings.keymaps["cursor.up"], "<C-\\><C-n><C-w>k" },
		{ settings.keymaps["cursor.right"], "<C-\\><C-n><C-w>l" },
		{ settings.keymaps["cursor.next"], "<C-\\><C-n><C-w>w" },
		{ settings.keymaps["cursor.prev"], "<C-\\><C-n><C-w>W" },
		-- Exchange current window with the next one
		{ settings.keymaps["swap.next"], "<C-\\><C-n><C-w>x" },
		-- Resizing the current window
		{ settings.keymaps["shrink.horizontal"], "<Cmd>resize -3<Cr>" },
		{ settings.keymaps["shrink.vertical"], "<Cmd>vertical resize -3<Cr>" },
		{ settings.keymaps["expand.vertical"], "<Cmd>vertical resize +3<Cr>" },
		{ settings.keymaps["expand.horizontal"], "<Cmd>resize +3<Cr>" },
		-- moving windows
		{ settings.keymaps["fullwidth.bottom"], "<C-\\><C-n><C-w>J" },
		{ settings.keymaps["fullheight.left"], "<C-\\><C-n><C-w>H" },
		{ settings.keymaps["fullheight.right"], "<C-\\><C-n><C-w>L" },
		{ settings.keymaps["fullwidth.top"], "<C-\\><C-n><C-w>K" },
		-- Resetting windows size
		{ settings.keymaps["equalize"], "<C-\\><C-n><C-w>=" },
		-- Maximising current window size
		{ settings.keymaps["maximize"], "<C-\\><C-n><C-w>_<C-w>|" },
		-- Splits
		{ settings.keymaps["split.horizontal"], "<Cmd>split<Cr>" },
		{ settings.keymaps["split.vertical"], "<Cmd>vsplit<Cr>" }
	)
end

Window.plugins = {}

Window.setup = validator.f.arguments({
	validator.f.shape({
		keymaps = validator.f.optional(validator.f.shape({
			["cursor.left"] = validator.f.optional("string"),
			["cursor.down"] = validator.f.optional("string"),
			["cursor.up"] = validator.f.optional("string"),
			["cursor.right"] = validator.f.optional("string"),
			["cursor.next"] = validator.f.optional("string"),
			["cursor.prev"] = validator.f.optional("string"),
			["swap.next"] = validator.f.optional("string"),
			["shrink.horizontal"] = validator.f.optional("string"),
			["shrink.vertical"] = validator.f.optional("string"),
			["expand.vertical"] = validator.f.optional("string"),
			["expand.horizontal"] = validator.f.optional("string"),
			["fullwidth.bottom"] = validator.f.optional("string"),
			["fullheight.left"] = validator.f.optional("string"),
			["fullheight.right"] = validator.f.optional("string"),
			["fullwidth.top"] = validator.f.optional("string"),
			-- TODO: equalize is not working, in none of the modes
			["equalize"] = validator.f.optional("string"),
			["maximize"] = validator.f.optional("string"),
			-- TODO: move delete to editor.buffer
			["delete"] = validator.f.optional("string"),
			["split.horizontal"] = validator.f.optional("string"),
			["split.vertical"] = validator.f.optional("string"),
		})),
	}),
})
	.. function(settings)
		settings = vim.tbl_deep_extend("force", default_settings, settings)

		Window._setup_keymaps(settings)
	end

Window._get_modal_config = function()
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
