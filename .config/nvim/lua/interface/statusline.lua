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
				left = options["theme.component_separator"],
				right = options["theme.component_separator"],
			},
			section_separators = {
				left = options["theme.section_separator"],
				right = options["theme.section_separator"],
			},
		},
		sections = {
			lualine_c = {
				"lsp_progress",
			},
		},
	})
end

return Module:new(Statusline)
