
-- CONQUER OF COMPLETION
-- Extensions, see https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#install-extensions
vim.cmd([[
  let g:coc_global_extensions = ["coc-json", "coc-yaml", "coc-html", "coc-svg", "coc-css", "coc-cssmodules", "coc-tsserver", "coc-diagnostic", "coc-eslint", "coc-prettier", "coc-sumneko-lua"]
]])
-- Keybindings
-- Prettier format buffer
vim.api.nvim_set_keymap('n', '<leader>b', ':CocCommand prettier.formatFile<CR>', { noremap = true, silent = true })

