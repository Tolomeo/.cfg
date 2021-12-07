-- see https://github.com/wbthomason/packer.nvim#bootstrapping
local fn = vim.fn
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	Packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local function setupModules(...)
	local args = {...}
	for _, module in ipairs(args) do
		module.setup()
	end
end

local function useModulesPlugins(use)
	return function(...)
		local modules = {...}

		for _, module in ipairs(modules) do
			for _, module_plugin in ipairs(module.plugins) do
				use(module_plugin)
			end
		end
	end
end

local base = require('base')
local theme = require('theme')
local editor = require('editor')
local vcs = require('vcs')
local finder = require('finder')
local intellisense = require('intellisense')

setupModules(base, theme, editor, vcs, finder, intellisense)

require('packer').startup(function(use)
	-- Package manager maninging itself
	use 'wbthomason/packer.nvim'

	useModulesPlugins(use)(base, theme, editor, vcs, finder, intellisense)

	-- Automatically set up configuration after cloning packer.nvim
	-- see https://github.com/wbthomason/packer.nvim#bootstrapping
	if Packer_bootstrap then
		require('packer').sync()
	end
end)

vim.cmd [[
augroup Packer
autocmd!
autocmd BufWritePost ~/.config/nvim/** PackerCompile
augroup end
]]
