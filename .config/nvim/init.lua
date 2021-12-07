require('defaults')
-- see https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	Packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end
-- modules
local modules = require('modules')

modules.for_each(function(module)
	module.setup()
end)

require('packer').startup(function(use)
	-- Package manager maninging itself
	use 'wbthomason/packer.nvim'

	modules.for_each(function (module)
		use(module.plugins)
	end)

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
