local module = require("utils.module")
-- local au = require("utils.au")

local defaults = {
	component_separator = "│",
	section_separator = "",
}

local Interface = {}

Interface.plugins = {
	-- Color themes
	"shaunsingh/nord.nvim",
	"navarasu/onedark.nvim",
	"sainnhe/edge",
	"folke/tokyonight.nvim",
	"EdenEast/nightfox.nvim",
	"Shatur/neovim-ayu",
	"rose-pine/neovim",
	-- File tree
	{
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
	},
	-- Status line
	{
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	},
	{
		"kdheepak/tabline.nvim",
		requires = { { "hoob3rt/lualine.nvim", opt = true }, { "kyazdani42/nvim-web-devicons", opt = true } },
	},
}

function Interface:autocommands()
	-- Forcing every new window created to open vertically
	-- see https://vi.stackexchange.com/questions/22779/how-to-open-files-in-vertical-splits-by-default
	--[[ au.group({ "OnWindowOpen", {
		{
			"WinNew",
			"*",
			"wincmd L",
		},
	} }) ]]
end

function Interface:setup()
	vim.g.nvim_tree_highlight_opened_files = 3
	vim.g.nvim_tree_group_empty = 1
	-- NvimTree
	require("nvim-tree").setup({
		hijack_netrw = true,
		-- hijack_directories = true,
		auto_reload_on_write = true,
		open_on_tab = true,
		diagnostics = {
			enable = true,
			show_on_dirs = true,
		},
		git = {
			enable = true,
			ignore = false,
		},
		update_focused_file = {
			enable = true,
			update_cwd = true,
		},
		view = {
			preserve_window_proportions = true,
			mappings = {
				list = {
					{ key = "<CR>", action = "edit_in_place" },
				},
			},
		},
	})

	-- Statusbar
	require("lualine").setup({
		options = {
			globalstatus = true, -- TODO: derive this from 'laststatus' option
			component_separators = { left = defaults.component_separator, right = defaults.component_separator },
			section_separators = { left = defaults.section_separator, right = defaults.section_separator },
		},
	})

	require("tabline").setup({
		enable = true,
		options = {
			component_separators = { defaults.component_separator, defaults.component_separator },
			section_separators = { defaults.section_separator, defaults.section_separator },
			show_tabs_always = true, -- this shows tabs only when there are more than one tab or if the first tab is named
			modified_icon = "~ ", -- change the default modified icon
		},
	})
end

Interface.color_scheme = setmetatable({
	nord = function()
		vim.g.nord_disable_background = true
		vim.g.nord_contrast = true
		vim.g.nord_italic = false
		vim.cmd([[colorscheme nord]])
		require("lualine").setup({ options = { theme = "nord" } })
	end,
	onedark = function()
		vim.g.onedark_transparent_background = true
		vim.g.onedark_style = "cool"
		vim.cmd([[colorscheme onedark]])
		require("lualine").setup({ options = { theme = "onedark" } })
	end,
	edge = function()
		vim.g.edge_transparent_background = 1
		vim.g.edge_better_performance = true
		vim.g.edge_current_word = "grey background"
		vim.g.edge_diagnostic_text_highlight = true
		vim.g.edge_style = "neon"
		vim.cmd([[colorscheme edge]])
	end,
	["rose-pine"] = function()
		require("rose-pine").setup({
			dark_variant = "moon",
			dim_nc_background = false,
			disable_background = true,
			disable_float_background = true,
			disable_italics = true,
		})
		vim.cmd("colorscheme rose-pine")
		require("lualine").setup({ options = { theme = "rose-pine" } })
	end,
	tokyonight = function()
		vim.g.tokyonight_transparent = true
		vim.g.tokyonight_italic_keywords = false
		vim.g.tokyonight_italic_comments = false
		vim.cmd([[colorscheme tokyonight]])
		require("lualine").setup({ options = { theme = "tokyonight" } })
	end,
	nightfox = function()
		require("nightfox").setup({
			fox = "nightfox",
			transparent = true,
		})
		require("nightfox").load()
		require("lualine").setup({ options = { theme = "nightfox" } })
	end,
	ayu = function()
		require("ayu").setup({ mirage = true, overrides = {
			Normal = { bg = "None" },
		} })
		vim.cmd([[colorscheme ayu]])
		require("lualine").setup({ options = { theme = "ayu" } })
	end,
}, {
	__call = function(color_schemes, scheme_name)
		if color_schemes[scheme_name] == nil then
			return
		end
		color_schemes[scheme_name]()
	end,
})

function Interface.toggle_tree()
	local view = require("nvim-tree.view")

	if view.is_visible() then
		return view.close()
	end

	require("nvim-tree").open_replacing_current_buffer()
end

return module.create(Interface)
