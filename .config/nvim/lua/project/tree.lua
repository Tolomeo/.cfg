local Module = require("_shared.module")
local key = require("_shared.key")
local validator = require("_shared.validator")
local settings = require("settings")

local Tree = {}

Tree.plugins = {
	-- File tree
	{
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
	},
}

Tree.setup = function()
	Tree._setup_keymaps()
	Tree._setup_plugins()
end

Tree._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap({ keymaps["project.tree.toggle"], Tree.toggle })
end

Tree._setup_plugins = function()
	local keymaps = settings.keymaps()

	-- NvimTree
	require("nvim-tree").setup({
		hijack_netrw = true,
		hijack_cursor = true,
		update_cwd = false,
		open_on_tab = false,
		open_on_setup = false,
		open_on_setup_file = false,
		auto_reload_on_write = true,
		hijack_unnamed_buffer_when_opening = true,
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
				resize_window = false,
				quit_on_open = true,
			},
			change_dir = {
				enable = false,
				restrict_above_cwd = false,
			},
			expand_all = {
				exclude = {
					".git",
					"node_modules",
				},
			},
		},
		renderer = {
			highlight_opened_files = "all",
			highlight_git = true,
			group_empty = true,
			full_name = true,
		},
		view = {
			preserve_window_proportions = true,
			mappings = {
				custom_only = true,
				list = {
					{ key = keymaps["project.tree.node.info"], action = "toggle_file_info" },
					{ key = keymaps["project.tree.node.open.vertical"], action = "vsplit" },
					{ key = keymaps["project.tree.node.open.horizontal"], action = "split" },
					{ key = keymaps["project.tree.node.collapse"], action = "close_node" },
					{ key = keymaps["project.tree.node.open"], action = "edit_in_place" },
					{ key = keymaps["project.tree.node.open.tab"], action = "tabnew" },
					{ key = keymaps["project.tree.fs.enter"], action = "cd" },
					{ key = keymaps["project.tree.fs.open.system"], action = "system_open" },
					{ key = keymaps["project.tree.fs.create"], action = "create" },
					{ key = keymaps["project.tree.fs.remove"], action = "remove" },
					{ key = keymaps["project.tree.fs.trash"], action = "trash" },
					{ key = keymaps["project.tree.fs.rename"], action = "rename" },
					{ key = keymaps["project.tree.fs.rename.full"], action = "full_rename" },
					{ key = keymaps["project.tree.fs.copy.node"], action = "copy" },
					{ key = keymaps["project.tree.fs.cut"], action = "cut" },
					{ key = keymaps["project.tree.fs.paste"], action = "paste" },
					{ key = keymaps["project.tree.fs.copy.filename"], action = "copy_name" },
					{ key = keymaps["project.tree.fs.copy.path.relative"], action = "copy_path" },
					{ key = keymaps["project.tree.fs.copy.path.absolute"], action = "copy_absolute_path" },
					{ key = keymaps["project.tree.refresh"], action = "refresh" },
					{ key = keymaps["project.tree.collapse.all"], action = "collapse_all" },
					{ key = keymaps["project.tree.navigate.parent"], action = "parent_node" },
					{ key = keymaps["project.tree.navigate.sibling.first"], action = "first_sibling" },
					{ key = keymaps["project.tree.navigate.sibling.last"], action = "last_sibling" },
					{ key = keymaps["project.tree.help"], action = "toggle_help" },
					{ key = keymaps["project.tree.close"], action = "close" },
					{ key = keymaps["project.tree.root.parent"], action = "dir_up" },
					{ key = keymaps["project.tree.toggle.filter.custom"], action = "toggle_custom" },
					{ key = keymaps["project.tree.toggle.filter.gitignore"], action = "toggle_git_ignored" },
					{ key = keymaps["project.tree.toggle.filter.dotfiles"], action = "toggle_dotfiles" },
					{
						key = keymaps["project.tree.actions"],
						action = "show_node_actions",
						action_cb = Tree.tree_actions_menu,
					},
					{
						key = keymaps["project.tree.search.node.content"],
						action = "search_in_node",
						action_cb = Tree.search_in_node,
					},
					{
						key = keymaps["project.tree.search.node"],
						action = "search_node",
					},
				},
			},
		},
	})
end

local validate_node = validator.f.any_of({
	-- Directory or file
	validator.f.shape({
		absolute_path = "string",
		fs_stat = validator.f.shape({
			type = "string",
		}),
	}),
	-- Upper directory
	validator.f.shape({
		name = "string",
	}),
})

Tree.search_in_node = validator.f.arguments({ validate_node })
	.. function(node)
		-- when the selected node is the one pointing at the parent director absolute_path will not be present
		if not node.absolute_path then
			return require("finder").find_in_directory()
		end

		if node.fs_stat.type == "directory" then
			return require("finder").find_in_directory(node.absolute_path)
		end

		if node.fs_stat.type == "file" then
			require("nvim-tree.actions.node.open-file").fn("edit_in_place", node.absolute_path)
			return require("finder").find_in_buffer()
		end
	end

-- https://github.com/kyazdani42/nvim-tree.lua/blob/master/lua/nvim-tree/actions/init.lua
Tree.tree_actions = {
	{ "Create", require("nvim-tree.actions.fs.create-file").fn },
	{ "Rename", require("nvim-tree.actions.fs.rename-file").fn(false) },
	{ "Rename full", require("nvim-tree.actions.fs.rename-file").fn(true) },
	{ "Copy relative path", require("nvim-tree.actions.fs.copy-paste").copy_path },
	{ "Copy absolute path", require("nvim-tree.actions.fs.copy-paste").copy_absolute_path },
	{ "Copy name", require("nvim-tree.actions.fs.copy-paste").copy_filename },
	{ "Copy", require("nvim-tree.actions.fs.copy-paste").copy },
	{ "Cut", require("nvim-tree.actions.fs.copy-paste").cut },
	{ "Paste", require("nvim-tree.actions.fs.copy-paste").paste },
	{ "Delete", require("nvim-tree.actions.fs.remove-file").fn },
	{ "Move to trash", require("nvim-tree.actions.fs.trash").fn },
	{ "Open in file manager", require("nvim-tree.actions.node.system-open").fn },
	{ "Run command", require("nvim-tree.actions.node.run-command").run_file_command },
	{ "View info", require("nvim-tree.actions.node.file-popup").toggle_file_info },
	{ "Toggle git.ignored files visibility", require("nvim-tree.actions.tree-modifiers.toggles").git_ignored },
	{ "Toggle dotfiles visibility", require("nvim-tree.actions.tree-modifiers.toggles").dotfiles },
	{ "Toggle custom filtered files visibility", require("nvim-tree.actions.tree-modifiers.toggles").custom },
	{ "Refresh tree", require("nvim-tree.actions.reloaders.reloaders").reload_explorer },
	{ "Search file", require("nvim-tree.actions.finders.search-node").fn },
	{ "Search here", Tree.search_in_node },
	{ "Directory up", require("nvim-tree.actions.root.dir-up").fn },
	-- { "Close tree", require("nvim-tree.view").close },
	-- toggle_help = require("nvim-tree.actions.toggles").help,
	-- search_node = require("nvim-tree.actions.search-node").fn,
	-- close_node = require("nvim-tree.actions.movements").parent_node(true),
	-- collapse_all = require("nvim-tree.actions.collapse-all").fn,
	-- first_sibling = require("nvim-tree.actions.movements").sibling(-math.huge),
	-- last_sibling = require("nvim-tree.actions.movements").sibling(math.huge),
	-- next_git_item = require("nvim-tree.actions.movements").find_git_item "next",
	-- next_sibling = require("nvim-tree.actions.movements").sibling(1),
	-- parent_node = require("nvim-tree.actions.movements").parent_node(false),
	-- prev_git_item = require("nvim-tree.actions.movements").find_git_item "prev",
	-- prev_sibling = require("nvim-tree.actions.movements").sibling(-1),
}

Tree.tree_actions_menu = validator.f.arguments({ validate_node })
	.. function(node)
		local items = {
			results = Tree.tree_actions,
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

Tree.toggle = function()
	local tree_view = require("nvim-tree.view")

	if tree_view.is_visible() then
		return tree_view.close()
	end

	local tree = require("nvim-tree.core")
	local tree_renderer = require("nvim-tree.renderer")
	local find_tree_file = require("nvim-tree.actions.finders.find-file").fn
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

return Module:new(Tree)
