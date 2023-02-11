local Module = require("_shared.module")
local settings = require("settings")

local Syntax = Module:extend({
	plugins = {
		-- Highlight, edit, and code navigation parsing library
		{ "nvim-treesitter/nvim-treesitter" },
		-- Syntax aware text-objects based on treesitter
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
		},
		-- Setting commentstrings based on treesitter
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
		},
		-- Auto closing tags
		{
			"windwp/nvim-ts-autotag",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
		},
		-- Code annotations
		{ "danymat/neogen", dependencies = { "nvim-treesitter/nvim-treesitter" } },
	},
})

function Syntax:setup()
	local config = settings.config

	require("nvim-treesitter.configs").setup({
		ensure_installed = config["language.parsers"],
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
		lsp_interop = {
			enable = true,
			border = "none",
			peek_definition_code = {
				["<leader>df"] = "@function.outer",
				["<leader>dF"] = "@class.outer",
			},
		},
		context_commentstring = {
			enable = true,
		},
	})

	-- Autotag
	require("nvim-ts-autotag").setup()

	require("neogen").setup({})
end

return Syntax:new()
