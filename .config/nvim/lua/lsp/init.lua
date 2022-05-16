local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Intellisense
Intellisense = Module:new({
	plugins = {
		{
			-- Conquer of completion
			"neoclide/coc.nvim",
			branch = "master",
			run = "yarn install --frozen-lockfile",
		},
	},
	setup = function()
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
					Intellisense.highlight_symbol,
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
	end,
})

Intellisense.open_code_actions = function()
	return key.input("<Plug>(coc-codeaction)", "m")
end

Intellisense.format = function()
	return vim.api.nvim_command('call CocAction("format")')
end

Intellisense.eslint_fix = function()
	return vim.api.nvim_command("CocCommand eslint.executeAutofix")
end

Intellisense.go_to_definition = function()
	return key.input("<Plug>(coc-definition)", "m")
end

Intellisense.go_to_type_definition = function()
	return key.input("<Plug>(coc-type-definition)", "m")
end

Intellisense.go_to_implementation = function()
	return key.input("<Plug>(coc-implementation)", "m")
end

Intellisense.show_references = function()
	return key.input("<Plug>(coc-references)", "m")
end

Intellisense.show_symbol_doc = function()
	return vim.api.nvim_command('call CocActionAsync("doHover")')
end

Intellisense.rename_symbol = function()
	return key.input("<Plug>(coc-rename)", "m")
end

Intellisense.highlight_symbol = function()
	return vim.api.nvim_command("call CocActionAsync('highlight')")
end

Intellisense.show_diagnostics = function()
	return vim.api.nvim_command("CocDiagnostics")
end

Intellisense.next_diagnostic = function()
	return key.input("<Plug>(coc-diagnostic-next)", "m")
end

Intellisense.prev_diagnostic = function()
	return key.input("<Plug>(coc-diagnostic-prev)", "m")
end

-- TODO: move this check into core module
Intellisense.has_suggestions = function()
	return vim.fn.pumvisible() ~= 0
end

Intellisense.open_suggestions = function()
	return key.input(vim.fn["coc#refresh"]())
end

Intellisense.next_suggestion = validator.f.arguments({ "string" })
	.. function(next)
		return function()
			if Intellisense.has_suggestions() then
				return key.input("<C-n>")
			end

			return key.input(next)
		end
	end

Intellisense.prev_suggestion = function()
	if Intellisense.has_suggestions() then
		return key.input("<C-p>")
	end

	return key.input("<C-h>")
end

-- vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
Intellisense.confirm_suggestion = function()
	if Intellisense.has_suggestions() then
		return key.feed(vim.fn["coc#_select_confirm"]())
	end

	return key.feed(key.to_term_code("<C-G>u<CR>") .. vim.fn["coc#on_enter"](), "n")
end

return Intellisense
