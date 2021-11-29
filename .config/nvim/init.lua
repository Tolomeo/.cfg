require('base')
require('theme')
require('editor')
require('intellisense')
require('versioning')

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager

  -- Git integration
  use 'tpope/vim-fugitive'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Parentheses, brackets, quotes, XML tags, and more
  use 'tpope/vim-surround'

  -- "gc" to comment visual regions/lines
  use 'b3nj5m1n/kommentary'

  -- Automatic tags management
  use 'ludovicchabant/vim-gutentags'

  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- theme based off of the Nord Color Palette.
  use 'shaunsingh/nord.nvim'
  -- fancy status line
  -- use 'itchyny/lightline.vim'
  use {
  'nvim-lualine/lualine.nvim',
   requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- File explorer
  use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
  -- Add indentation guide even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- Conquer of completion
  use {'neoclide/coc.nvim', branch = 'release'}
end)


