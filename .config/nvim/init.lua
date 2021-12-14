local config = require('config')
local modules = require('modules')

config.setup(modules)

-- AUTOCMDS
local au = require('utils.au')

au.group('NvimConfigChange', {
	{
		'BufWritePost',
		'~/.config/nvim/**',
		config.compile
	}
})

au.group('SpellCheck', {
	{
		{'BufRead','BufNewFile'},
		'*.md',
		'setlocal spell'
	}
})

-- KEYMAPPING
local key = require('utils.key')

-- write only if changed
vim.api.nvim_set_keymap("n", "<Leader>w", ":up<CR>", { noremap = true })
-- quit (or close window)
vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", { noremap = true, silent = true })
-- Discard all changed buffers & quit
vim.api.nvim_set_keymap("n", "<Leader>Q", ":qall!<CR>", { noremap = true, silent = true })
-- write all and quit
vim.api.nvim_set_keymap("n", "<Leader>W", ":wqall<CR>", { noremap = true, silent = true })

-- Remapping arrows to nothing
key.map { "i", "<left>", "<nop>" }
key.map { "i", "<right>", "<nop>" }
key.map { "i", "<up>", "<nop>" }
key.map { "i", "<down>", "<nop>" }

-- We lost 'J'oin lines, that's a good one we want to keep
key.map { "n", "M", "J" }

-- Movement multipliers
key.map { "n", "H", "b" }
key.map { "n", "<A-h>", "0" }
key.map { "n", "L", "w" }
key.map { "n", "<A-l>", "$" }
key.map { "n", "J", "<C-d>" }
-- key.map { "n", "<A-j>", "G" }
key.map { "n", "K", "<C-u>" }
-- key.map { "n", "<A-k>", "gg" }

-- Adding empty lines in normal mode
key.map { "n", "<CR>", "O<ESC>j"}
key.map { "n", "<A-CR>", "o<ESC>k"}

-- Intellisense
key.map { "n", "<C-Space>", modules.intellisense.open_code_actions }
key.map { "n", "<leader>b", modules.intellisense.prettier_format }
key.map { "n", "<leader>l", modules.intellisense.eslint_fix }
key.map { "n", "<leader>d", modules.intellisense.go_to_definition }
key.map { "n", "<leader>k", modules.intellisense.show_symbol_doc }
key.map { "n", "<leader>rn", modules.intellisense.rename_symbol }
key.map { 'i', '<C-Space>', modules.intellisense.open_suggestions }
key.map { "i", "<TAB>", modules.intellisense.next_suggestion '<TAB>' }
key.map { "i", "<S-TAB>",modules.intellisense.prev_suggestion }
key.map { "i", "<CR>", modules.intellisense.confirm_suggestion }

