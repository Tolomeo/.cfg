--Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Yank until the end of line  (note: this is now a default on master)
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })
-- Select all
vim.api.nvim_set_keymap('n', '<C-y>', ':%y<CR>', { silent = true, noremap = true })

-- Moving among windows with arrows
vim.api.nvim_set_keymap('n', '<up>', '<C-w><up>', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<down>', '<C-w><down>', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<left>', '<C-w><left>', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<right>', '<C-w><right>', { noremap = false, silent = true })

-- Replace word under cursor in buffer
vim.api.nvim_set_keymap('n', '<leader>sr', ':%s/<C-r><C-w>//gI<left><left><left>', { noremap = false, silent = false })
vim.api.nvim_set_keymap('n', '<leader>sl', ':s/<C-r><C-w>//gI<left><left><left>', { noremap = false, silent = false })

--Map blankline
vim.opt.list = true
vim.opt.listchars:append("space:⋅")

require("indent_blankline").setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
  use_treesitter = true,
  strict_tabs = true,
  context_char = '┃'
}

-- KOMMENTARY
-- see https://github.com/b3nj5m1n/kommentary
vim.g.kommentary_create_default_mappings = false
vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
-- vim.api.nvim_set_keymap("n", "<leader>C", "<Plug>kommentary_motion_default", {})
vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {})

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
	ensure_installed = {'lua', 'html', 'css', 'scss', 'dockerfile', 'dot', 'json', 'jsdoc', 'yaml', 'javascript', 'typescript', 'tsx' },
	sync_install = true,
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}
