-- GitSigns maps
-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua

-- Gitsigns
require('gitsigns').setup {
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 100,
  }
}

-- toggle hunk line highlight
vim.api.nvim_set_keymap(
  "n",
  "<Leader>gh",
  [[<Cmd>lua require'gitsigns'.toggle_linehl()<CR>]],
  { noremap = true, silent = true }
)
-- toggle hunk line Num highlight
vim.api.nvim_set_keymap(
  "n",
  "<Leader>gn",
  [[<Cmd>lua require'gitsigns'.toggle_numhl()<CR>]],
  { noremap = true, silent = true }
)

-- toggle hunk line Num highlight
vim.api.nvim_set_keymap(
  "n",
  "<Leader>gp",
  [[<Cmd>lua require'gitsigns'.preview_hunk()<CR>]],
  { noremap = true, silent = true }
)
-- Cycling through hunks with TAB and S-TAB
vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
