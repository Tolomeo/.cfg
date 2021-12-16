local config = require('config')
local modules = require('modules')

-- INITIALISATION
config.setup(modules)

-- COLOR SCHEME
modules.theme.color_scheme('edge')

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
-- Opening the file browser on startup when nvim is opened against a directory
au.VimEnter = function()
	if vim.fn.isdirectory(vim.fn.expand('%:p')) > 0 then require 'telescope'.extensions.file_browser.file_browser({ hidden = true }) end
end

-- KEYMAPS
local key = require('utils.key')

-- write only if changed
key.map { "n", "<Leader>w", ":up<CR>", silent = false }
-- quit (or close window)
key.map { "n", "<Leader>q", ":q<CR>", }
-- Discard all changed buffers & quit
key.map { "n", "<Leader>Q", ":qall!<CR>", }
-- write all and quit
key.map { "n", "<Leader>W", ":wqall<CR>", }

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
-- git
-- Git blame
key.map { 'n', 'gb', modules.git.git_blame }
-- Git log
key.map { 'n', 'gl', modules.git.git_log }
-- Git diff
key.map { 'n', 'gd', modules.git.git_diff }
-- Git merge
key.map { 'n', 'gm', modules.git.git_mergetool }
-- Toggle hunk preview
key.map { 'n', 'gh', modules.git.show_hunk_preview }
-- Cycling through hunks with TAB and S-TAB
key.map { 'n', ']c', modules.git.next_hunk_preview ']c' }
key.map { 'n', '[c', modules.git.prev_hunk_preview '[c' }

-- Keybindings
-- see https://github.com/albingroen/quick.nvim/blob/main/lua/telescope-config.lua
key.map { 'n', '<C-p>', modules.finder.find_files }
key.map { 'n', '<C-b>', modules.finder.browse_files }
key.map { 'n', '<C-f>', modules.finder.find_in_files }
key.map { 'n', '<leader>f', modules.finder.find_in_buffer }
key.map { 'n', '<leader>f', modules.finder.find_buffers }
--Add leader shortcut
-- vim.api.nvim_set_keymap('n', '<leader><space>', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>st', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>so', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], { noremap = true, silent = true })

-- Neoclip keybindings
key.map { 'n', '<C-y>', modules.finder.find_yanks }
-- Quickfix and location lists keybindings
key.map { 'n', '<C-c>', modules.finder.toggle_quickfixes }
key.map { 'n', '<leader>c', modules.finder.jump_to_quickfixes }
key.map { 'n', '<C-]>', modules.finder.next_quickfix }
key.map { 'n', '<C-[>', modules.finder.prev_quickfix }
-- TODO: these mappings are not working
key.map { 'n', '<C-}>', modules.finder.next_quickfixes_file }
key.map { 'n', '<C-{>', modules.finder.prev_quickfixes_file }
-- key.map { 'n', '<C-c>', '<Plug>(qf_qf_toggle)' }

-- Project keybindings
key.map {  'n', '<C-o>', modules.finder.find_projects }
-- Todos
key.map { 'n', '<C-t>', modules.finder.find_todos }
