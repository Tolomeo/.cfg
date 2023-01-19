local Module = require("_shared.module")
local settings = require("settings")

---@class Interface.Theme
local Theme = {}

Theme.plugins = {
	{
		"kdheepak/tabline.nvim",
		requires = { { "hoob3rt/lualine.nvim", opt = true }, { "kyazdani42/nvim-web-devicons", opt = true } },
	},
}

function Theme:setup()
	local options = settings.options()

	require("tabline").setup({
		enable = true,
		options = {
			component_separators = { options["theme.component_separator"], options["theme.component_separator"] },
			section_separators = { options["theme.section_separator"], options["theme.section_separator"] },
			show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
			modified_icon = "~ ", -- change the default modified icon
		},
	})
end

return Module:new(Theme)
