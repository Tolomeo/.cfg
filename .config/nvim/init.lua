local modules = require('modules') local au = require('utils.au') local key = require('utils.key')
local config = require('config')
-- INITIALISATION

config.setup(modules)

-- COLOR SCHEME

modules.theme.color_scheme('rose-pine')

-- AUTOCMDS

-- Recompiling config whenever something changes
au.group('NvimConfigChange', {
	{
		'BufWritePost',
		'~/.config/nvim/**',
		config.compile
	}
})

-- Spellchecking only some files
au.group('SpellCheck', {
	{
		{'BufRead','BufNewFile'},
		'*.md',
		'setlocal spell'
	}
})

-- Opening file browser when nvim is opened against a directory
au.VimEnter = function ()
	if vim.fn.isdirectory(vim.fn.expand('%:p')) > 0 then
		modules.finder.browse_files()
	end
end

-- Yank visual feedback
au.group('YankHighlight', {
	{
		'TextYankPost',
		'*',
		vim.highlight.on_yank
	}
})

-- KEYMAPS

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

-- Movement multipliers
-- Left
key.map { "n", "<A-h>", "b" }
key.map { "n", "H", "0" }
-- Right
key.map { "n", "<A-l>", "w" }
key.map { "n", "L", "$" }
-- Up
key.map { "n", "<A-k>", "(" }
key.map { "n", "K", "gg" }
-- Down
key.map { "n", "<A-j>", ")" }
key.map { "n", "J", "G" }

-- Adding empty lines in normal mode with enter
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

key.map { 'n', '<C-p>', modules.finder.find_files }
key.map { 'n', '<C-b>', modules.finder.browse_files }
key.map { 'n', '<C-f>', modules.finder.find_in_files }
key.map { 'n', '<leader>f', modules.finder.find_in_buffer }
key.map { 'n', '<leader>f', modules.finder.find_buffers }

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

--Remap for dealing with word wrap
key.map { 'n', 'k', "v:count == 0 ? 'gk' : 'k'", expr = true }
key.map { 'n', 'j', "v:count == 0 ? 'gj' : 'j'", expr = true }

-- Join lines and restore cursor location
-- key.map { "n", "J", "mjJ`j" }

-- Yank until the end of line  (note: this is now a default on master)
-- TODO: add o map for all. Ex: yaa to select all
-- vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })
-- vim.api.nvim_set_keymap('n', 'YY', ':%y<CR>', { silent = true, noremap = true })

-- Moving lines with ALT key
-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
key.map { 'n', '<C-j>', modules.editor.move_line_down }
key.map { 'n', '<C-k>', modules.editor.move_line_up }
key.map { 'i', '<C-j>', function ()
	key.input '<ESC>'
	modules.editor.move_line_down()
	key.input 'gi'
end }
key.map { 'i', '<C-k>', function ()
	key.input '<ESC>'
	modules.editor.move_line_up()
	key.input 'gi'
end }
key.map { 'v', '<C-j>', modules.editor.move_selected_lines_down }
key.map { 'v', '<C-k>', modules.editor.move_selected_lines_up }


-- Replace word under cursor in buffer
key.map { 'n', '<leader>sr', modules.editor.replace_current_word_in_buffer }
-- Replace word under cursor in line
key.map { 'n', '<leader>sl', modules.editor.replace_current_word_in_line }
-- Commenting lines
key.map { "n", "<leader>/", modules.editor.comment_line }
key.map { "x", "<leader>/", modules.editor.comment_selection }
key.map { 'n', '<leader><space>' , modules.editor.find_cursor }


--Add leader shortcut
-- vim.api.nvim_set_keymap('n', '<leader><space>', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>st', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>so', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], { noremap = true, silent = true })
