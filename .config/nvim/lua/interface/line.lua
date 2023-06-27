local Module = require("_shared.module")
local key = require("_shared.key")
local tb = require("_shared.tab")
local validator = require("_shared.validator")
local settings = require("settings")

local Line = Module:extend({
	plugins = {
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
		},
		{ "arkav/lualine-lsp-progress" },
		{
			"kdheepak/tabline.nvim",
			dependencies = {
				{ "nvim-lualine/lualine.nvim", lazy = true },
				{ "kyazdani42/nvim-web-devicons", lazy = true },
			},
		},
	},
})

function Line:setup()
	local opt = settings.opt
	local config = settings.config
	local keymap = settings.keymap

	key.nmap({ keymap["tab.next"], "<Cmd>tabnext<Cr>" }, { keymap["tab.prev"], "<Cmd>tabprevious<Cr>" })

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

Line.set_tab_name = validator.f.arguments({
	validator.f.instance_of(Line),
	"number",
	"string",
}) .. function(_, tab, name)
	-- https://github.com/kdheepak/tabline.nvim/blob/main/lua/tabline.lua#L139
	local tabline = require("tabline")
	tabline._new_tab_data(tb.number(tab))
	local data = vim.t[tab].tabline_data
	data.name = name
	vim.t[tab].tabline_data = data
	vim.cmd([[redrawtabline]])
end

return Line:new()
