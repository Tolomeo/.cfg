local lualine = require('lualine')
local M = {}

M.plugins = {
	{ 'shaunsingh/nord.nvim' }
}

function M.setup()
	-- Colortheme
	vim.g.nord_contrast = true
	vim.g.nord_borders = true
	vim.g.nord_disable_background = true
	vim.cmd [[colorscheme nord]]

	-- Statusbar
	lualine.setup()
end

return M
