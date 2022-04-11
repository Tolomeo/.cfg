local module = require("utils.module")
local au = require("utils.au")
local key = require("utils.key")
local Editor = {}

Editor.plugins = {
	-- Highlight, edit, and code navigation parsing library
	"nvim-treesitter/nvim-treesitter",
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
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
	-- additional operator targets
	"wellle/targets.vim",
	-- Change case and handles variants of a word
	"tpope/vim-abolish",
	-- Automatically highlights the line the cursor is in
	"yamatsum/nvim-cursorline",
	-- Highlighting color strings
	"norcalli/nvim-colorizer.lua",
	-- Highlighting command ranges
	{ "winston0410/range-highlight.nvim", requires = "winston0410/cmd-parser.nvim" },
}

function Editor:autocommands()
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

	--[[ au.group({ "OnInsertModeToggle", {
	{
		"InsertEnter",
		"*",
		"set relativenumber"
	},
	{
		"InsertLeave",
		"*",
		"set norelativenumber"
	}
} }) ]]
end

function Editor:setup()
	-- Treesitter configuration
	-- Parsers must be installed manually via :TSInstall
	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"lua",
			"html",
			"css",
			"scss",
			"dockerfile",
			"dot",
			"json",
			"jsdoc",
			"yaml",
			"javascript",
			"typescript",
			"tsx",
		},
		sync_install = true,
		highlight = {
			enable = true, -- false will disable the whole extension
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		indent = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
		},
		context_commentstring = {
			enable = true,
		},
	})

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
end

-- vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
function Editor.comment_line()
	key.input("<Plug>kommentary_line_default", "m")
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function Editor.comment_selection()
	key.input("<Plug>kommentary_visual_default", "m")
end

-- Returns the current word under the cursor
function Editor.cword()
	return vim.call("expand", "<cword>")
end

-- Toggles the current word under the cursor from 'true' to 'false' and viceversa
-- NOTE: this is currently not used
-- TODO: gather a list of commonly 'swappable' words and operate the toggle based on that available dictionary
function Editor.toggle_boolean()
	local word = Editor.cword()

	if word == "true" then
		vim.api.nvim_command("normal! ciwfalse")
	elseif word == "false" then
		vim.api.nvim_command("normal! ciwtrue")
	else
		print("Cannot toggle because the word under the cursor ('" .. word .. "') is not a boolean value")
	end
end

return module.create(Editor)
