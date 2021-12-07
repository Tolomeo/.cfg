local base = require('base')
local theme = require('theme')
local editor = require('editor')
local vcs = require('vcs')
local finder = require('finder')
local intellisense = require('intellisense')
local au = require('au')

base.setup()
theme.setup()
editor.setup()
vcs.setup()
finder.setup()
intellisense.setup()

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[
augroup Packer
autocmd!
autocmd BufWritePost ~/.config/nvim/** PackerCompile
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

	for _, plugin in ipairs(base.plugins) do
		use(plugin)
	end

	for _, plugin in ipairs(theme.plugins) do
		use(plugin)
	end

	for _, plugin in ipairs(editor.plugins) do
		use(plugin)
	end

	for _, plugin in ipairs(vcs.plugins) do
		use(plugin)
	end

	for _, plugin in ipairs(finder.plugins) do
		use(plugin)
	end

	for _, plugin in ipairs(intellisense.plugins) do
		use(plugin)
	end
end)

