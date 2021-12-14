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
	require'lualine'.setup {
		options = {
			icons_enabled = true,
			theme = 'auto',
			component_separators = { left = '/', right = '/'},
			section_separators = { left = '', right = ''},
			disabled_filetypes = {},
			always_divide_middle = true,
		},
		sections = {
			lualine_a = {'mode'},
			lualine_b = {'branch', { 'diff', colored = false }, { 'diagnostics', sources = { 'coc'}, colored = false, update_in_insert = true } },
			lualine_c = {'filename'},
			lualine_x = {'encoding', 'fileformat', 'filetype'},
			lualine_y = {'progress'},
			lualine_z = {'location'}
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {'filename'},
			lualine_x = {'location'},
			lualine_y = {},
			lualine_z = {}
		},
		tabline = {},
		extensions = {}
	}
end

return M
