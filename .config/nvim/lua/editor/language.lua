local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Language = {}

Language.plugins = {
	-- Highlight, edit, and code navigation parsing library
	"nvim-treesitter/nvim-treesitter",
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
	-- lsp
	{
		-- Conquer of completion
		"neoclide/coc.nvim",
		branch = "master",
		run = "yarn install --frozen-lockfile",
	},
}

Language.setup = function()
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

	-- Extensions, see https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#install-extensions
	vim.g.coc_global_extensions = {
		"coc-sumneko-lua",
		"coc-stylua",
		"coc-json",
		"coc-yaml",
		"coc-html",
		"coc-emmet",
		"coc-svg",
		"coc-css",
		"coc-cssmodules",
		"coc-tsserver",
		"coc-diagnostic",
		"coc-eslint",
		"coc-prettier",
		"coc-calc",
	}

	-- vim.cmd [[autocmd CursorHold * silent call CocActionAsync('highlight')]]
	au.group({
		"CursorSymbolHighlight",
		{
			{
				"CursorHold",
				"*",
				Language.highlight_symbol,
			},
		},
	})

	-- Spellchecking only some files
	au.group({
		"OnMarkdownBufferOpen",
		{
			{
				{ "BufRead", "BufNewFile" },
				"*.md",
				"setlocal spell",
			},
		},
	})
end

Language.open_code_actions = function()
	return key.input("<Plug>(coc-codeaction)", "m")
end

Language.format = function()
	return vim.api.nvim_command('call CocAction("format")')
end

Language.eslint_fix = function()
	return vim.api.nvim_command("CocCommand eslint.executeAutofix")
end

Language.go_to_definition = function()
	return key.input("<Plug>(coc-definition)", "m")
end

Language.go_to_type_definition = function()
	return key.input("<Plug>(coc-type-definition)", "m")
end

Language.go_to_implementation = function()
	return key.input("<Plug>(coc-implementation)", "m")
end

Language.show_references = function()
	return key.input("<Plug>(coc-references)", "m")
end

Language.show_symbol_doc = function()
	return vim.api.nvim_command('call CocActionAsync("doHover")')
end

Language.rename_symbol = function()
	return key.input("<Plug>(coc-rename)", "m")
end

Language.highlight_symbol = function()
	return vim.api.nvim_command("call CocActionAsync('highlight')")
end

Language.show_diagnostics = function()
	return vim.api.nvim_command("CocDiagnostics")
end

Language.next_diagnostic = function()
	return key.input("<Plug>(coc-diagnostic-next)", "m")
end

Language.prev_diagnostic = function()
	return key.input("<Plug>(coc-diagnostic-prev)", "m")
end

-- TODO: move this check into core module
Language.has_suggestions = function()
	return vim.fn.pumvisible() ~= 0
end

Language.open_suggestions = function()
	return key.input(vim.fn["coc#refresh"]())
end

Language.next_suggestion = validator.f.arguments({ "string" })
	.. function(next)
		return function()
			if Language.has_suggestions() then
				return key.input("<C-n>")
			end

			return key.input(next)
		end
	end

Language.prev_suggestion = function()
	if Language.has_suggestions() then
		return key.input("<C-p>")
	end

	return key.input("<C-h>")
end

-- vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
Language.confirm_suggestion = function()
	if Language.has_suggestions() then
		return key.feed(vim.fn["coc#_select_confirm"]())
	end

	return key.feed(key.to_term_code("<C-G>u<CR>") .. vim.fn["coc#on_enter"](), "n")
end

return Module:new(Language)
