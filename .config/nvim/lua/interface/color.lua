local Module = require("_shared.module")
local settings = require("settings")

---@class Cfg.Interface.Color
local Color = {}

Color.plugins = {
	-- Color themes
	{ "shaunsingh/nord.nvim", lazy = false, priority = 1000 },
	{ "EdenEast/nightfox.nvim", lazy = false, priority = 1000 },
	{ "sainnhe/edge", lazy = false, priority = 1000 },
	{ "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
	-- Highlighting color strings
	{ "norcalli/nvim-colorizer.lua" },
}

function Color:setup()
	local config = settings.config
	local colorscheme_name = config["theme.colorscheme"]
	local setup_colorscheme = ({
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
			vim.g.edge_diagnostic_virtual_text = "colored"
			vim.g.edge_diagnostic_line_highlight = 1
			vim.g.edge_style = "neon"
		end,
		kanagawa = function()
			require("kanagawa").setup({
				undercurl = false, -- enable undercurls
				commentStyle = { italic = false },
				keywordStyle = { italic = false },
				statementStyle = { bold = false },
				variablebuiltinStyle = { italic = false },
				transparent = true,
				globalStatus = true,
			})
		end,
	})[colorscheme_name]

	setup_colorscheme()
	vim.cmd(string.format("colorscheme %s", colorscheme_name))

	-- TODO: borderless telescope
	-- see https://github.com/nvim-telescope/telescope.nvim/wiki/Gallery#borderless

	-- Colorizer
	require("colorizer").setup()
end

return Module:new(Color)
