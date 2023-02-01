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
	local options = settings.options()

	require("tabline").setup({
		enable = true,
		options = {
			component_separators = { options["icon.component.left"], options["icon.component.right"] },
			section_separators = { options["icon.section.left"], options["icon.section.right"] },
			show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
			modified_icon = "~ ", -- change the default modified icon
		},
	})
end

function Line:setup_status()
	local globals = settings.globals()
	local options = settings.options()

	require("lualine").setup({
		options = {
			globalstatus = globals.laststatus == 3,
			theme = options["theme.colorscheme"],
			component_separators = {
				left = options["icon.component.left"],
				right = options["icon.component.right"],
			},
			section_separators = {
				left = options["icon.section.left"],
				right = options["icon.section.right"],
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
