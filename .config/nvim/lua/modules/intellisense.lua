local key = require('utils.key')
local M = {}

M.plugins = {
	-- Conquer of completion
	'neoclide/coc.nvim',
	branch = 'release'
}

function M.setup()
	-- Extensions, see https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#install-extensions
	vim.g.coc_global_extensions = {
		"coc-sumneko-lua",
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
		"coc-calc"
	}
end

-- Module actions
function M.open_code_actions()
	return key.input('<Plug>(coc-codeaction)', 'm')
end

function M.prettier_format()
	return key.input(':CocCommand prettier.formatFile<CR>')
end

function M.eslint_fix()
	return key.input(':CocCommand eslint.executeAutofix<CR>')
end

function M.go_to_definition()
	return key.input('<Plug>(coc-definition)', 'm')
end

function M.go_to_type_definition()
	return key.input('<Plug>(coc-type-definition)', 'm')
end

function M.go_to_implementation()
	return key.input('<Plug>(coc-implementation)', 'm')
end

function M.show_references()
	return key.input('<Plug>(coc-references)', 'm')
end

function M.show_symbol_doc()
	return key.input(':call CocActionAsync("doHover")<CR>')
end

function M.rename_symbol()
	return key.input('<Plug>(coc-rename)', 'm')
end
 
function M.show_diagnostics()
	return key.input(':CocDiagnostics<CR>')
end

function M.next_diagnostic()
	return key.input('<Plug>(coc-diagnostic-next)', 'm')
end
   
function M.prev_diagnostic()
	return key.input('<Plug>(coc-diagnostic-prev)', 'm')
end

-- TODO: move this check into core module
function M.has_suggestions()
	return vim.fn.pumvisible() ~= 0
end

function M.open_suggestions()
	return key.input(vim.fn['coc#refresh']())
end

function M.next_suggestion(next)
	return function()
		if(M.has_suggestions())	then
			return key.input('<C-n>')
		end

		return key.input(next)
	end
end

function M.prev_suggestion()
	if(M.has_suggestions()) then
		return key.input('<C-p>')
	end

	return key.input('<C-h>')
end
-- vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
function M.confirm_suggestion()
	if(M.has_suggestions()) then
		return key.feed(vim.fn['coc#_select_confirm']())
	end

	return key.feed(key.to_term_code '<C-G>u<CR>' .. vim.fn['coc#on_enter'](), 'n')
end

return M
