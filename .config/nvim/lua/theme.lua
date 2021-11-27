-- Set theme options
vim.g.nord_contrast = true
vim.g.nord_borders = false
vim.g.nord_disable_background = true

vim.cmd [[colorscheme nord]]

--Set statusbar
require('lualine').setup({
  options = { theme = 'nord' }
})
