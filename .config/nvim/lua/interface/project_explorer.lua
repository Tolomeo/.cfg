local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local ProjectExplorer = {}

ProjectExplorer.plugins = {
	-- File tree
	{
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
	},
}

ProjectExplorer.setup = function()
	ProjectExplorer._setup_keymaps()
	ProjectExplorer._setup_plugins()
end

ProjectExplorer._setup_keymaps = function()
	key.nmap({ "<leader>e", ProjectExplorer.toggle })
end

ProjectExplorer._setup_plugins = function()
	-- NvimTree
	require("nvim-tree").setup({
		hijack_netrw = true,
		hijack_cursor = true,
		update_cwd = false,
		auto_reload_on_write = true,
		open_on_tab = true,
		open_on_setup = true,
		diagnostics = {
			enable = true,
			show_on_dirs = true,
		},
		git = {
			enable = true,
			ignore = false,
		},
		filters = {
			dotfiles = false,
		},
		update_focused_file = {
			enable = true,
			update_cwd = false,
		},
		actions = {
			open_file = {
				resize_window = true,
			},
		},
		renderer = {
			highlight_opened_files = "all",
			highlight_git = true,
			group_empty = true,
		},
		view = {
			preserve_window_proportions = true,
			mappings = {
				custom_only = true,
				list = {
					{ key = "<leader>k", action = "toggle_file_info" },
					{ key = "<C-y>", action = "vsplit" },
					{ key = "<C-x>", action = "split" },
					{ key = "<C-t>", action = "tabnew" },
					{ key = "<C-r>", action = "refresh" },
					{ key = "h", action = "close_node" },
					{ key = "H", action = "collapse_all" },
					{ key = "K", action = "parent_node" },
					{ key = "l", action = "edit_in_place" },
					{ key = "gk", action = "dir_up" },
					{ key = "o", action = "cd" },
					{ key = "O", action = "system_open" },
					{ key = "[", action = "first_sibling" },
					{ key = "]", action = "last_sibling" },
					{ key = "g?", action = "toggle_help" },
					{ key = "a", action = "create" },
					{ key = "d", action = "remove" },
					{ key = "D", action = "trash" },
					{ key = "r", action = "rename" },
					{ key = "R", action = "full_rename" },
					{ key = "c", action = "copy" },
					{ key = "C", action = "cut" },
					{ key = "p", action = "paste" },
					{ key = "y", action = "copy_name" },
					{ key = "Y", action = "copy_path" },
					{ key = "gy", action = "copy_absolute_path" },
					{ key = "q", action = "close" },
					{ key = "u", action = "toggle_custom" },
					{ key = "i", action = "toggle_git_ignored" },
					{ key = ".", action = "toggle_dotfiles" },
					{
						key = "<C-Space>",
						action = "show_node_actions",
						action_cb = ProjectExplorer.tree_actions_menu,
					},
					{
						key = "<leader>f",
						action = "search_in_node",
						action_cb = ProjectExplorer.search_in_node,
					},
				},
			},
		},
	})
end

local validate_node = validator.f.shape({
	absolute_path = "string",
	fs_stat = validator.f.shape({
		type = "string",
	}),
})

ProjectExplorer.search_in_node = validator.f.arguments({ validate_node })
	.. function(node)
		if node.fs_stat.type == "directory" then
			require("finder").find_in_directory(node.absolute_path)
		end

		if node.fs_stat.type == "file" then
			require("nvim-tree.actions.open-file").fn("edit_in_place", node.absolute_path)
			require("finder").find_in_buffer()
		end
	end

-- https://github.com/kyazdani42/nvim-tree.lua/blob/master/lua/nvim-tree/actions/init.lua
ProjectExplorer.tree_actions = {
	{ "Create", require("nvim-tree.actions.create-file").fn },
	{ "Rename", require("nvim-tree.actions.rename-file").fn(false) },
	{ "Rename full", require("nvim-tree.actions.rename-file").fn(true) },
	{ "Copy", require("nvim-tree.actions.copy-paste").copy },
	{ "Cut", require("nvim-tree.actions.copy-paste").cut },
	{ "Paste", require("nvim-tree.actions.copy-paste").paste },
	{ "Delete", require("nvim-tree.actions.remove-file").fn },
	{ "Copy name", require("nvim-tree.actions.copy-paste").copy_filename },
	{ "Copy relative path", require("nvim-tree.actions.copy-paste").copy_path },
	{ "Copy absolute path", require("nvim-tree.actions.copy-paste").copy_absolute_path },
	{ "Search here", ProjectExplorer.search_in_node },
	{ "Open in file manager", require("nvim-tree.actions.system-open").fn },
	{ "Toggle git.ignored files visibility", require("nvim-tree.actions.toggles").git_ignored },
	{ "Toggle dotfiles visibility", require("nvim-tree.actions.toggles").dotfiles },
	{ "Toggle custom filtered files visibility", require("nvim-tree.actions.toggles").custom },
	{ "Refresh tree", require("nvim-tree.actions.reloaders").reload_explorer },
	{ "Run command", require("nvim-tree.actions.run-command").run_file_command },
	{ "Move to trash", require("nvim-tree.actions.trash").fn },
	{ "View info", require("nvim-tree.actions.file-popup").toggle_file_info },
	{ "Close tree", require("nvim-tree.view").close },
	-- toggle_help = require("nvim-tree.actions.toggles").help,
	-- search_node = require("nvim-tree.actions.search-node").fn,
	-- close_node = require("nvim-tree.actions.movements").parent_node(true),
	-- collapse_all = require("nvim-tree.actions.collapse-all").fn,
	-- dir_up = require("nvim-tree.actions.dir-up").fn,
	-- first_sibling = require("nvim-tree.actions.movements").sibling(-math.huge),
	-- last_sibling = require("nvim-tree.actions.movements").sibling(math.huge),
	-- next_git_item = require("nvim-tree.actions.movements").find_git_item "next",
	-- next_sibling = require("nvim-tree.actions.movements").sibling(1),
	-- parent_node = require("nvim-tree.actions.movements").parent_node(false),
	-- prev_git_item = require("nvim-tree.actions.movements").find_git_item "prev",
	-- prev_sibling = require("nvim-tree.actions.movements").sibling(-1),
}

ProjectExplorer.tree_actions_menu = validator.f.arguments({ validate_node })
	.. function(node)
		local items = {
			results = ProjectExplorer.tree_actions,
			entry_maker = function(tree_action)
				return {
					value = tree_action,
					ordinal = tree_action[1],
					display = tree_action[1],
				}
			end,
		}
		local on_select = function(contex_menu)
			local selection = contex_menu.state.get_selected_entry()
			local tree_action = selection.value[2]
			contex_menu.actions.close(contex_menu.buffer)
			vim.defer_fn(function()
				tree_action(node)
			end, 50)
		end
		local options = { prompt_title = node.name }

		require("finder").contex_menu(items, on_select, options)
	end

ProjectExplorer.toggle = function()
	local tree_view = require("nvim-tree.view")

	if tree_view.is_visible() then
		return tree_view.close()
	end

	local tree = require("nvim-tree.core")
	local tree_renderer = require("nvim-tree.renderer")
	local find_tree_file = require("nvim-tree.actions.find-file").fn
	local root = vim.loop.cwd()
	local buf = vim.api.nvim_get_current_buf()
	local bufname = vim.api.nvim_buf_get_name(buf)

	if not tree.get_explorer() then
		tree.init(root)
	end

	tree_view.open_in_current_win({ hijack_current_buf = false, resize = false })
	tree_renderer.draw()

	if bufname == "" or vim.loop.fs_stat(bufname) == nil then
		return
	end

	find_tree_file(bufname)
end

return Module:new(ProjectExplorer)
