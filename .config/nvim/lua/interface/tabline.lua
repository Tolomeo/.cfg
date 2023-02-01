local Module = require("_shared.module")
local settings = require("settings")

---@class Interface.Theme
local Theme = {}

Theme.plugins = {
	{
		"kdheepak/tabline.nvim",
		dependencies = { { "nvim-lualine/lualine.nvim", lazy = true }, { "kyazdani42/nvim-web-devicons", lazy = true } },
	},
}

function Theme:setup()
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

return Module:new(Theme)
