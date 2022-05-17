local Module = require("_shared.module")

local color_schemes = {
	nord = function()
		vim.g.nord_disable_background = true
		vim.g.nord_contrast = true
		vim.g.nord_italic = false
		vim.cmd([[colorscheme nord]])
	end,
	onedark = function()
		require("onedark").setup({
			style = "cool",
			transparent = true,
		})
		vim.cmd([[colorscheme onedark]])
	end,
	edge = function()
		vim.g.edge_transparent_background = 1
		vim.g.edge_better_performance = true
		vim.g.edge_current_word = "grey background"
		vim.g.edge_diagnostic_text_highlight = true
		vim.g.edge_style = "neon"
		vim.cmd([[colorscheme edge]])
	end,
	["rose-pine"] = function()
		require("rose-pine").setup({
			dark_variant = "moon",
			dim_nc_background = false,
			disable_background = true,
			disable_float_background = true,
			disable_italics = true,
		})
		vim.cmd("colorscheme rose-pine")
	end,
	tokyonight = function()
		vim.g.tokyonight_transparent = true
		vim.g.tokyonight_italic_keywords = false
		vim.g.tokyonight_italic_comments = false
		vim.cmd([[colorscheme tokyonight]])
	end,
	nightfox = function()
		require("nightfox").setup({
			options = {
				transparent = true,
			},
		})
		vim.cmd([[colorscheme nordfox]])
	end,
	ayu = function()
		require("ayu").setup({ mirage = true, overrides = {
			Normal = { bg = "None" },
		} })
		vim.cmd([[colorscheme ayu]])
	end,
}

local default_settings = {
	color_scheme = "nightfox",
	component_separator = "│",
	section_separator = "",
}

local Theme = {}

Theme.plugins = {
	-- Color themes
	"shaunsingh/nord.nvim",
	"navarasu/onedark.nvim",
	"sainnhe/edge",
	"folke/tokyonight.nvim",
	"EdenEast/nightfox.nvim",
	"Shatur/neovim-ayu",
	"rose-pine/neovim",
	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	},
	{
		"kdheepak/tabline.nvim",
		requires = { { "hoob3rt/lualine.nvim", opt = true }, { "kyazdani42/nvim-web-devicons", opt = true } },
	},
}

Theme.setup = function(settings)
	settings = vim.tbl_extend("force", default_settings, settings)

	-- TODO: passing options to customise color schemes
	color_schemes[settings.color_scheme]()

	-- Statusbar
	require("lualine").setup({
		options = {
			globalstatus = true, -- TODO: derive this from 'laststatus' option
			theme = settings.color_scheme,
			component_separators = {
				left = settings.component_separator,
				right = settings.component_separator,
			},
			section_separators = {
				left = settings.section_separator,
				right = settings.section_separator,
			},
		},
	})

	require("tabline").setup({
		enable = true,
		options = {
			component_separators = { settings.component_separator, settings.component_separator },
			section_separators = { settings.section_separator, settings.section_separator },
			show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
			modified_icon = "~ ", -- change the default modified icon
		},
	})
end

return Module:new(Theme)
