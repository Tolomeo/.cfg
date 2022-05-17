local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")

local Text = {}

Text.plugins = {
	-- Indentation guides
	"lukas-reineke/indent-blankline.nvim",
	-- Comments
	"b3nj5m1n/kommentary",
	"JoosepAlviste/nvim-ts-context-commentstring",
	-- Code docs
	{ "danymat/neogen", requires = "nvim-treesitter/nvim-treesitter" },
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

Text.setup = function()
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

	-- Code docs
	require("neogen").setup({})

	-- CursorLine
	vim.g.cursorline_timeout = 0

	-- Colorizer
	require("colorizer").setup()

	-- Range highlight
	require("range-highlight").setup()

	-- Yank visual feedback
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
function Text.comment_line()
	key.input("<Plug>kommentary_line_default", "m")
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function Text.comment_selection()
	key.input("<Plug>kommentary_visual_default", "m")
end

-- Returns the current word under the cursor
function Text.cword()
	return vim.call("expand", "<cword>")
end

return Module:new(Text)
