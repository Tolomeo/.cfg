local Module = require("utils.module")
-- local au = require("utils.au")

local ProjectExplorer = {}

ProjectExplorer.plugins = {
	{
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
	},
}

function ProjectExplorer:setup()
	vim.g.nvim_tree_highlight_opened_files = 3
	vim.g.nvim_tree_group_empty = 1
	-- NvimTree
	require("nvim-tree").setup({
		hijack_netrw = true,
		hijack_cursor = true,
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
				custom_only = true,
				list = {
					{ key = "o", action = "edit_in_place" },
					{ key = "O", action = "system_open" },
					{ key = "<C-v>", action = "vsplit" },
					{ key = "<C-x>", action = "split" },
					{ key = "<C-t>", action = "tabnew" },
					{ key = "h", action = "close_node" },
					{ key = "H", action = "collapse_all" },
					{ key = "K", action = "parent_node" },
					{ key = "l", action = "toggle_file_info" },
					{ key = "..", action = "dir_up" },
					{ key = "g?", action = "toggle_help" },

					-- { key = "<up>", action = "prev_sibling" },
					-- { key = "<down>", action = "next_sibling" },
					-- { key = "R", action = "refresh" },
					{ key = "a", action = "create" },
					-- { key = "d", action = "remove" },
					-- { key = "D", action = "trash" },
					{ key = "r", action = "rename" },
					-- { key = "<C-r>", action = "full_rename" },
					-- { key = "x", action = "cut" },
					-- { key = "c", action = "copy" },
					-- { key = "p", action = "paste" },
					-- { key = "y", action = "copy_name" },
					-- { key = "Y", action = "copy_path" },
					-- { key = "gy", action = "copy_absolute_path" },
					-- { key = "S", action = "search_node" },
					-- { key = ".", action = "run_file_command" },
					-- { key = "U", action = "toggle_custom" },
				},
			},
		},
	})
end

function ProjectExplorer.toggle()
	local view = require("nvim-tree.view")

	if view.is_visible() then
		return view.close()
	end

	require("nvim-tree").open_replacing_current_buffer()
end

return Module:new(ProjectExplorer)
