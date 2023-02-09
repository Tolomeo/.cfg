local Module = require("_shared.module")
local settings = require("settings")

---@class Interface.Line
local Line = {}

Line.plugins = {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
	},
	{ "arkav/lualine-lsp-progress" },
	{
		"kdheepak/tabline.nvim",
		dependencies = { { "nvim-lualine/lualine.nvim", lazy = true }, { "kyazdani42/nvim-web-devicons", lazy = true } },
	},
}

function Line:setup()
	self:setup_status()
	self:setup_tab()
end

function Line:setup_tab()
	local config = settings.config

	require("tabline").setup({
		enable = true,
		options = {
			component_separators = { config["icon.component.left"], config["icon.component.right"] },
			section_separators = { config["icon.section.left"], config["icon.section.right"] },
			show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
			modified_icon = "~ ", -- change the default modified icon
		},
	})
end

function Line:setup_status()
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

return Module:new(Line)
