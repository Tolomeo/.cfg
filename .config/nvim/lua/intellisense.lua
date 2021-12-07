local M = {}

M.plugins = {
	-- Conquer of completion
	'neoclide/coc.nvim'
}

function M.setup()
	-- CONQUER OF COMPLETION
	-- Extensions, see https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#install-extensions
	vim.cmd([[
	let g:coc_global_extensions = ["coc-json", "coc-yaml", "coc-html", "coc-emmet", "coc-svg", "coc-css", "coc-cssmodules", "coc-tsserver", "coc-diagnostic", "coc-eslint", "coc-prettier", "coc-sumneko-lua"]
	]])
	-- Keybindings
	-- see https://github.com/albingroen/quick.nvim/blob/main/lua/coc-config.lua
	vim.api.nvim_set_keymap("n", "<leader>.", "<Plug>(coc-codeaction)", {})
	vim.api.nvim_set_keymap("n", "<leader>l", ":CocCommand eslint.executeAutofix<CR>", {})
	vim.api.nvim_set_keymap("n", "<leader>d", "<Plug>(coc-definition)", {silent = true})
	vim.api.nvim_set_keymap("n", "K", ":call CocActionAsync('doHover')<CR>", {silent = true, noremap = true})
	vim.api.nvim_set_keymap("n", "<leader>rn", "<Plug>(coc-rename)", {})
	vim.api.nvim_set_keymap("n", "<leader>b", ":CocCommand prettier.formatFile<CR>", {noremap = true})
	vim.api.nvim_set_keymap("i", "<C-Space>", "coc#refresh()", { silent = true, expr = true })
	vim.api.nvim_set_keymap("i", "<TAB>", "pumvisible() ? '<C-n>' : '<TAB>'", {noremap = true, silent = true, expr = true})
	vim.api.nvim_set_keymap("i", "<S-TAB>","pumvisible() ? '<C-p>' : '<C-h>'", {noremap = true, expr = true})
	vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
	vim.o.hidden = true
	vim.o.backup = false
	vim.o.writebackup = false
	vim.o.updatetime = 300
end

return M
