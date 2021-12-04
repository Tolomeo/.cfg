-- TELESCOPE
require('telescope').setup {
  defaults = {
		defaults = {
			color_devicons = true,
		},
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
      n = {
      },
    },
  },
}
-- Extensions
require("telescope").load_extension "file_browser"
require('telescope').load_extension 'neoclip'
-- Keybindings
-- see https://github.com/albingroen/quick.nvim/blob/main/lua/telescope-config.lua
vim.api.nvim_set_keymap('n', '<C-p>', "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap = true })
vim.api.nvim_set_keymap(
  "n",
  "<C-o>",
  "<cmd>lua require 'telescope'.extensions.file_browser.file_browser({ hidden = true })<CR>",
  {noremap = true}
)
vim.api.nvim_set_keymap('n', '<C-f>', "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({previewer = false})<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-Tab>', "<cmd>lua require('telescope.builtin').buffers()<CR>", { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-f>', "<cmd>lua require('telescope.builtin').file_browser()<CR>", { noremap = true })
--Add leader shortcuts
-- vim.api.nvim_set_keymap('n', '<leader><space>', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>st', [[<cmd>lua require('telescope.builtin').tags()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>so', [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]], { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>?', [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]], { noremap = true, silent = true })

-- Neoclip keybindings
vim.api.nvim_set_keymap('n', '<C-y>', "<cmd>lua require('telescope').extensions.neoclip.default()<CR>", { silent = true })

-- Quickfix and location lists keybindings
vim.api.nvim_set_keymap('n', '<C-]>', '<Plug>(qf_qf_next)', {})
vim.api.nvim_set_keymap('n', '<C-[>', '<Plug>(qf_qf_previous)', {})
vim.api.nvim_set_keymap('n', '<C-}>', '<Plug>(qf_qf_next_file)', {})
vim.api.nvim_set_keymap('n', '<C-{>', '<Plug>(qf_qf_previous_file)', {})
-- vim.api.nvim_set_keymap('n', '<C-c>', '<Plug>(qf_qf_toggle_stay)', {})
vim.api.nvim_set_keymap('n', '<C-c>', '<Plug>(qf_qf_toggle)', {})
vim.api.nvim_set_keymap('n', '<leader>c', '<Plug>(qf_qf_switch)', {})
