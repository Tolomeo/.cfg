local Module = require("_shared.module")
local settings = require("settings")

---@class Interface.Statusline
local Statusline = {}

Statusline.plugins = {
	{
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	},
	"arkav/lualine-lsp-progress",
}

function Statusline:setup()
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

return Module:new(Statusline)
