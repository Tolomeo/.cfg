require('base')
require('theme')
require('editor')
require('finder')
require('intellisense')
require('versioning')

local au = require('au')

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

-- Opening the file browser on startup when nvim is opened against a directory
au.VimEnter = function()
	if vim.fn.isdirectory(vim.fn.expand('%:p')) > 0 then require 'telescope'.extensions.file_browser.file_browser({ hidden = true }) end
end

local use = require('packer').use
require('packer').startup(function()
	-- Package manager maninging itself
  use 'wbthomason/packer.nvim'

	-- Automatically changing cwd based on the root of the project
	-- see https://github.com/airblade/vim-rooter
	use { 'airblade/vim-rooter', setup = function ()
		-- Setting files/dirs to look for to understand what the root dir is
		vim.api.nvim_set_var('rooter_patterns', {'=nvim', '.git', 'package.json' })
	end }

  -- Git integration
  use 'tpope/vim-fugitive'
  -- Add git related info in the signs columns and popups
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Parentheses, brackets, quotes, XML tags, and more
  use 'tpope/vim-surround'

  -- "gc" to comment visual regions/lines
  use 'b3nj5m1n/kommentary'
	use 'JoosepAlviste/nvim-ts-context-commentstring'

  -- Automatic tags management
  use 'ludovicchabant/vim-gutentags'

  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
	use { "nvim-telescope/telescope-file-browser.nvim" }
	use { "AckslD/nvim-neoclip.lua", config = function()
		require('neoclip').setup()
	end }
	use 'nvim-telescope/telescope-project.nvim'
	use {
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup {
		}
  end }

	-- General qf and loc lists improvements
	use { 'romainl/vim-qf', setup = function()
		vim.api.nvim_set_var('qf_mapping_ack_style', true)
	end }

  -- theme based off of the Nord Color Palette.
  use 'shaunsingh/nord.nvim'
  -- fancy status line
  -- use 'itchyny/lightline.vim'
  use {
  'nvim-lualine/lualine.nvim',
   requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- Add indentation guide even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
	use 'windwp/nvim-ts-autotag'
	use {'edluffy/specs.nvim'}

  -- Conquer of completion
  use {'neoclide/coc.nvim', branch = 'release'}
end)

