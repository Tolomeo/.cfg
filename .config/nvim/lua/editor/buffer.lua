local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local register = require("_shared.register")

-- Register 0 always contains the last yank.
-- Unfortunately selecting register 0 all the time can be quite annoying, so it would be nice if p used "0
-- https://stackoverflow.com/a/32488853
key.nmap({ "p", '"0p' })
key.nmap({ "P", '"0P' })
for _, register_name in ipairs(register.names) do
	local paste = string.format('"%sp', register_name)
	local Paste = string.format('"%sP', register_name)
	key.nmap({ paste, paste, remap = true }, { Paste, Paste, remap = true })
end

-- Make visual yanks remain in visual mode
key.vmap({ "y", "ygv" })

local Buffer = {}

Buffer.plugins = {
	-- Indentation guides
	"lukas-reineke/indent-blankline.nvim",
	-- Comments
	"b3nj5m1n/kommentary",
	"JoosepAlviste/nvim-ts-context-commentstring",
	-- Auto closing tags
	"windwp/nvim-ts-autotag",
	-- Autoclosing pair of chars
	"windwp/nvim-autopairs",
	-- Parentheses, brackets, quotes, XML tags
	"tpope/vim-surround",
	-- Change case and handles variants of a word
	"tpope/vim-abolish",
	-- additional operator targets
	"wellle/targets.vim",
	-- Highlighting command ranges
	{ "winston0410/range-highlight.nvim", requires = "winston0410/cmd-parser.nvim" },
	-- Highlighting color strings
	"norcalli/nvim-colorizer.lua",
}

Buffer.setup = function()
	-- Autotag
	require("nvim-ts-autotag").setup()

	-- Autopairs
	require("nvim-autopairs").setup({
		disable_filetype = { "TelescopePrompt", "vim" },
	})

	--Map blankline
	require("indent_blankline").setup({
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = true,
		use_treesitter = true,
		strict_tabs = true,
		context_char = "┃",
	})

	-- Kommentary
	vim.g.kommentary_create_default_mappings = false

	-- CursorLine
	vim.g.cursorline_timeout = 0

	-- Colorizer
	require("colorizer").setup()

	-- Range highlight
	require("range-highlight").setup()

	-- Yanks visual feedback
	au.group({
		"OnTextYanked",
		{
			{
				"TextYankPost",
				"*",
				function()
					vim.highlight.on_yank()
				end,
			},
		},
	})
end

-- vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
function Buffer.comment_line()
	key.input("<Plug>kommentary_line_default", "m")
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function Buffer.comment_selection()
	key.input("<Plug>kommentary_visual_default", "m")
end

-- Returns the current word under the cursor
function Buffer.cword()
	return vim.call("expand", "<cword>")
end

return Module:new(Buffer)
