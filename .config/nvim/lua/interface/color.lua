local Module = require("_shared.module")
local settings = require("settings")

local Color = Module:extend({
	plugins = {
		-- Color themes
		{ "sainnhe/edge", lazy = false, priority = 1000 },
		{ "sainnhe/everforest", lazy = false, priority = 1000 },
		{ "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
		-- Highlighting color strings
		{ "norcalli/nvim-colorizer.lua" },
	},
})

function Color:setup()
	local config = settings.config
	local colorscheme_name = config["theme.colorscheme"]
	local setup_colorscheme = ({
		edge = function()
			vim.g.edge_style = "neon"
			vim.g.edge_disable_italic_comment = 1
			vim.g.edge_transparent_background = 1
			vim.g.edge_better_performance = true
			vim.g.edge_current_word = "grey background"
			vim.g.edge_diagnostic_virtual_text = "colored"
			vim.g.edge_diagnostic_line_highlight = 1
		end,
		everforest = function()
			vim.g.everforest_disable_italic_comment = 1
			vim.g.everforest_transparent_background = 1
			vim.g.everforest_better_performance = true
			vim.g.everforest_current_word = "grey background"
			vim.g.everforest_diagnostic_virtual_text = "colored"
			vim.g.everforest_diagnostic_line_highlight = 1
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
				overrides = {
					TelescopeBorder = { link = "TelescopeNormal" },
				},
			})
		end,
	})[colorscheme_name]

	setup_colorscheme()
	vim.cmd(string.format("colorscheme %s", colorscheme_name))

	-- Colorizer
	require("colorizer").setup()
end

return Color:new()
