require('defaults')
_G.user = {
	modules = require('modules'),
	plugins = require('plugins')
}

user.modules.setup()

user.plugins.setup(function(use)
	user.modules.for_each(function (module)
		use(module.plugins)
	end)
end)

-- Remapping arrows to nothing
vim.api.nvim_set_keymap("i", "<left>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<right>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<up>", "<nop>", { noremap = true })
vim.api.nvim_set_keymap("i", "<down>", "<nop>", { noremap = true })

local keymapOpts = { noremap = true, silent = true, expr = true }
vim.api.nvim_set_keymap("n", "<C-Space>", "v:lua.user.modules.intellisense.openCodeActions()", keymapOpts )
vim.api.nvim_set_keymap("n", "<leader>b", "v:lua.user.modules.intellisense.prettierFormat()", keymapOpts )
vim.api.nvim_set_keymap("n", "<leader>l", "v:lua.user.modules.intellisense.eslintFix()", keymapOpts )
vim.api.nvim_set_keymap("n", "<leader>d", "v:lua.user.modules.intellisense.goToDefinition()", keymapOpts )
vim.api.nvim_set_keymap("n", "K", "v:lua.user.modules.intellisense.showSymbolDocumentation()", keymapOpts )
vim.api.nvim_set_keymap("n", "<leader>rn", "v:lua.user.modules.intellisense.renameSymbol()", keymapOpts )
vim.api.nvim_set_keymap("i", "<C-Space>", "v:lua.user.modules.intellisense.openSuggestions()", keymapOpts )
vim.api.nvim_set_keymap("i", "<TAB>", "v:lua.user.modules.intellisense.nextSuggestion('<TAB>')", keymapOpts )
vim.api.nvim_set_keymap("i", "<S-TAB>","v:lua.user.modules.intellisense.prevSuggestion()", keymapOpts )
vim.api.nvim_set_keymap("i", "<CR>", "v:lua.user.modules.intellisense.confirmSuggestion()", keymapOpts )
