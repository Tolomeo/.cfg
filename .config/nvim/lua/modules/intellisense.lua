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
function M.openCodeActions()
	return vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(coc-codeaction)', true, true, true))
end

function M.prettierFormat()
	return vim.api.nvim_replace_termcodes(':CocCommand prettier.formatFile<CR>', true, true, true)
end

function M.eslintFix()
	return vim.api.nvim_replace_termcodes(':CocCommand eslint.executeAutofix<CR>', true, true, true)
end

function M.goToDefinition()
	return vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(coc-definition)', true, true, true))
end

function M.showSymbolDocumentation()
	return vim.api.nvim_replace_termcodes(':call CocActionAsync("doHover")<CR>', true, true, true)
end

function M.renameSymbol()
	return vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(coc-rename)', true, true, true))
end

function M.openSuggestions()
	return vim.fn['coc#refresh']()
end

function M.nextSuggestion(next)
	if(vim.fn.pumvisible() ~= 0)	then
		return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
	end

	return vim.api.nvim_replace_termcodes(next, true, true, true)
end

function M.prevSuggestion()
	if(vim.fn.pumvisible() ~= 0) then
		return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
	end

	return vim.api.nvim_replace_termcodes('<C-h>', true, true, true)
end

function M.confirmSuggestion()
	if(vim.fn.pumvisible() ~= 0) then
		return vim.fn['coc#_select_confirm']()
	end

	return vim.api.nvim_replace_termcodes('<C-G>u<CR><C-R>=coc#on_enter()<CR>', true, true, true)
end

return M
