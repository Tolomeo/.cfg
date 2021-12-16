local M = {}

M.plugins = {
	'shaunsingh/nord.nvim',
	'navarasu/onedark.nvim',
	'sainnhe/edge',
	'Shatur/neovim-ayu',
	{
  'nvim-lualine/lualine.nvim',
   requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
}

function M.setup()
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
			lualine_b = {'branch', { 'diff', colored = false }, { 'diagnostics', sources = { 'coc' }, colored = false, update_in_insert = true } },
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

M.color_scheme = setmetatable({
	nord = function()
		vim.g.nord_contrast = true
		vim.g.nord_borders = true
		vim.g.nord_disable_background = true
		vim.cmd [[colorscheme nord]]
	end,
	onedark = function ()
		vim.g.onedark_transparent_background = true
		vim.g.onedark_style = 'darker'
		vim.cmd [[colorscheme onedark]]
	end,
	edge = function ()
		vim.g.edge_transparent_background = true
		vim.g.edge_better_performance = true
		vim.g.edge_diagnostic_text_highlight = true
		vim.cmd [[colorscheme edge]]
	end,
	ayu_dark = function ()
		vim.g.ayucolor = 'dark'
		require('ayu').colorscheme()
		require('ayu').setup({ mirage = false, overrides = {} })
	end
}, {
		__call = function (_, themeName)
			M.color_scheme[themeName]()
			require'lualine'.setup {options = {theme = themeName }}
		end
})

return M
