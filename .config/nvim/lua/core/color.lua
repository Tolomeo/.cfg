local Module = require("_shared.module")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local settings = require("settings")

---@class Color.Scheme
local Scheme = {
	nord = function()
		vim.g.nord_borders = false
		vim.g.nord_disable_background = true
		vim.g.nord_italic = false
		vim.g.nord_uniform_diff_background = true
		vim.g.nord_bold = false
	end,
	nordfox = function()
		require("nightfox").setup({
			options = {
				transparent = true,
			},
		})
	end,
	edge = function()
		vim.g.edge_style = "neon"
		vim.g.edge_disable_italic_comment = 1
		vim.g.edge_transparent_background = 1
		vim.g.edge_better_performance = true
		vim.g.edge_current_word = "grey background"
		vim.g.edge_diagnostic_text_highlight = true
		vim.g.edge_style = "neon"
	end,
	kanagawa = function()
		require("kanagawa").setup({
			undercurl = false, -- enable undercurls
			commentStyle = { italic = false },
			keywordStyle = { italic = false },
			statementStyle = { bold = false },
			variablebuiltinStyle = { italic = false },
			transparent = true, -- do not set background color
			globalStatus = true, -- adjust window separators highlight for laststatus=3
		})
	end,
}

Scheme.setup = validator.f.arguments({ validator.f.equal(Scheme), validator.f.one_of(fn.keys(Scheme)) })
	.. function(self, name)
		self[name]()
		vim.cmd(string.format("colorscheme %s", name))
	end

---@class Core.Color
local Color = {}

Color.plugins = {
	-- Color themes
	"shaunsingh/nord.nvim",
	"EdenEast/nightfox.nvim",
	"sainnhe/edge",
	"rebelot/kanagawa.nvim",
	-- Highlighting color strings
	"norcalli/nvim-colorizer.lua",
}

function Color:setup()
	local options = settings.options()

	Scheme:setup(options["theme.colorscheme"])

	-- TODO: borderless telescope
	-- see https://github.com/nvim-telescope/telescope.nvim/wiki/Gallery#borderless

	-- Colorizer
	require("colorizer").setup()
end

return Module:new(Color)
