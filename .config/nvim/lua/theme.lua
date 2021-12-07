local M = {}

M.plugins = {
	'shaunsingh/nord.nvim',
	{
  'nvim-lualine/lualine.nvim',
   requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
}

function M.setup()
	-- Colortheme
	vim.g.nord_contrast = true
	vim.g.nord_borders = true
	vim.g.nord_disable_background = true
	vim.cmd [[colorscheme nord]]

	-- Statusbar
	require('lualine').setup()
end

return M
