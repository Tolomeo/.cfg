local Module = require("_shared.module")
local settings = require("settings")

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

---@class Interface.Theme
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
	-- Highlighting color strings
	"norcalli/nvim-colorizer.lua",
}

function Theme:setup()
	local options = settings.options()

	-- TODO: passing options to customise color schemes
	color_schemes[options["theme.colorscheme"]]()

	-- Colorizer
	require("colorizer").setup()
end

return Module:new(Theme)
