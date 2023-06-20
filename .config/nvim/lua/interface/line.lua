local Module = require("_shared.module")
local settings = require("settings")

local Line = Module:extend({
	plugins = {
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
		},
		{ "arkav/lualine-lsp-progress" },
	},
})

function Line:setup()
	local opt = settings.opt
	local config = settings.config

	require("lualine").setup({
		options = {
			globalstatus = opt.laststatus == 3,
			theme = config["theme.colorscheme"],
			component_separators = {
				left = config["icon.component.left"],
				right = config["icon.component.right"],
			},
			section_separators = {
				left = config["icon.section.left"],
				right = config["icon.section.right"],
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = { "diagnostics", "lsp_progress" },
			lualine_x = {},
			lualine_y = { "encoding", "fileformat", "filetype" },
			lualine_z = { "searchcount", "location", "progress" },
		},
	})
end

return Line:new()
