-- see https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	Packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local key = require('utils.key')
local M = {}

function M.setup(setupPlugins)
	require('packer').startup(function (use)
		-- Package manager maninging itself
		use 'wbthomason/packer.nvim'

		-- user defined plugins
		setupPlugins(use)

		-- Automatically set up configuration after cloning packer.nvim
		-- see https://github.com/wbthomason/packer.nvim#bootstrapping
		if Packer_bootstrap then
			require('packer').sync()
		end
	end)

	function M.compile()
		key.feed(key.to_term_code(':PackerCompile<CR>'))
	end

end

return M
