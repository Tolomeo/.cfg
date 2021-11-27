-- Set theme options
vim.g.nord_contrast = true
vim.g.nord_borders = false
vim.g.nord_disable_background = true

vim.cmd [[colorscheme nord]]

--Set statusbar
require('lualine').setup({
  options = { theme = 'nord' }
})

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { hl = 'GitGutterAdd', text = '+' },
    change = { hl = 'GitGutterChange', text = '~' },
    delete = { hl = 'GitGutterDelete', text = '_' },
    topdelete = { hl = 'GitGutterDelete', text = '‾' },
    changedelete = { hl = 'GitGutterChange', text = '~' },
  },
}

-- NvimTree
require'nvim-tree'.setup {
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = true,
  auto_close = false,
  hijack_cursor = true,
  update_focused_file = {
    enable = true
  },
  diagnostics = {
    enable = true
  },
  view = {
    side = 'left',
    auto_resize = true
  }
}
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':NvimTreeRefresh<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
