local M = {}

M.plugins = {
	-- Color themes
	"shaunsingh/nord.nvim",
	"navarasu/onedark.nvim",
	"sainnhe/edge",
	-- Ayu is for the time being inconsistent with other themes
	-- as it doesn't support transparent background
	-- "Shatur/neovim-ayu",
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
}

function M.setup()
	-- NvimTree
	require("nvim-tree").setup({
		open_on_setup = true,
		hijack_cursor = true,
		update_cwd = true,
		diagnostics = {
			enable = true,
		},
		update_focused_file = {
			enable = true,
			update_cwd = true,
		},
		view = {
			auto_resize = true,
		},
	})

	-- Statusbar
	require("lualine").setup({
		options = {
			icons_enabled = true,
			theme = "auto",
			component_separators = { left = "/", right = "/" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {},
			always_divide_middle = true,
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				"branch",
				{ "diff", colored = false },
				{ "diagnostics", sources = { "coc" }, colored = false, update_in_insert = true },
			},
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		extensions = {},
	})
end

M.color_scheme = setmetatable({
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
		vim.g.edge_current_word = 'grey background'
		vim.g.edge_diagnostic_text_highlight = true
		vim.g.edge_style = "neon"
		vim.cmd([[colorscheme edge]])
	end,
	["rose-pine"] = function()
		vim.g.rose_pine_variant = "moon"
		-- vim.g.rose_pine_inactive_background = true
		vim.g.rose_pine_disable_background = true
		vim.g.rose_pine_disable_italics = true
		vim.g.rose_pine_bold_vertical_split_line = true
		vim.cmd([[colorscheme rose-pine]])
		require("lualine").setup({ options = { theme = "rose-pine" } })
	end,
}, {
	__call = function(color_schemes, scheme_name)
		if color_schemes[scheme_name] == nil then
			return
		end
		color_schemes[scheme_name]()
	end,
})

function M.toggle_tree()
	return vim.api.nvim_command("NvimTreeToggle")
end

function M.focus_tree()
	return vim.api.nvim_command("NvimTreeFocus")
end

return M
