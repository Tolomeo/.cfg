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
	return key.feed(key.to_term_code('<Plug>(coc-codeaction)'))
end

function M.prettier_format()
	return key.to_term_code(':CocCommand prettier.formatFile<CR>')
end

function M.eslint_fix()
	return key.to_term_code(':CocCommand eslint.executeAutofix<CR>')
end

function M.go_to_definition()
	return key.feed(key.to_term_code('<Plug>(coc-definition)'))
end

function M.show_symbol_doc()
	return key.to_term_code(':call CocActionAsync("doHover")<CR>')
end

function M.rename_symbol()
	return key.feed(key.to_term_code('<Plug>(coc-rename)'))
end

function M.has_suggestions()
	return vim.fn.pumvisible() ~= 0
end

function M.open_suggestions()
	return vim.fn['coc#refresh']()
end

function M.next_suggestion(next)
	if(M.has_suggestions())	then
		return key.to_term_code('<C-n>')
	end

	return key.to_term_code(next)
end

function M.prev_suggestion()
	if(M.has_suggestions()) then
		return key.to_term_code('<C-p>')
	end

	return key.to_term_code('<C-h>')
end

function M.confirm_suggestion()
	if(M.has_suggestions()) then
		return vim.fn['coc#_select_confirm']()
	end

	return key.to_term_code('<C-G>u<CR><C-R>=coc#on_enter()<CR>')
end

return M
