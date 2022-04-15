-- local conf = require("telescope.config").values
-- local entry_display = require("telescope.pickers.entry_display")
local Module = require("utils.module")
-- local au = require("utils.au")

-- https://github.com/kyazdani42/nvim-tree.lua/blob/master/lua/nvim-tree/actions/init.lua
local tree_actions = {
	{ "Create", require("nvim-tree.actions.create-file").fn },
	{ "Rename", require("nvim-tree.actions.rename-file").fn(false) },
	{ "Copy", require("nvim-tree.actions.copy-paste").copy },
	{ "Cut", require("nvim-tree.actions.copy-paste").cut },
	{ "Paste", require("nvim-tree.actions.copy-paste").paste },
	{ "Delete", require("nvim-tree.actions.remove-file").fn },
	{ "Copy name", require("nvim-tree.actions.copy-paste").copy_filename },
	{ "Copy relative path", require("nvim-tree.actions.copy-paste").copy_path },
	{ "Copy absolute path", require("nvim-tree.actions.copy-paste").copy_absolute_path },
	{ "Toggle git.ignored files visibility", require("nvim-tree.actions.toggles").git_ignored },
	{ "Toggle dotfiles visibility", require("nvim-tree.actions.toggles").dotfiles },
	{ "Toggle custom filtered files visibility", require("nvim-tree.actions.toggles").custom },
	{ "Refresh tree", require("nvim-tree.actions.reloaders").reload_explorer },
	{ "Run command", require("nvim-tree.actions.run-command").run_file_command },
	{ "Move to trash", require("nvim-tree.actions.trash").fn },
	-- { "toggle_file_info", require("nvim-tree.actions.file-popup").toggle_file_info },
	-- { "Rename file full", require("nvim-tree.actions.rename-file").fn(true) },
	-- { "Open in file manager", require("nvim-tree.actions.system-open").fn },
	-- close = view.close,
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
	-- search_node = require("nvim-tree.actions.search-node").fn,
	-- toggle_help = require("nvim-tree.actions.toggles").help,
}

local ProjectExplorer = Module:new({
	plugins = {
		-- File tree
		{
			"kyazdani42/nvim-tree.lua",
			requires = {
				"kyazdani42/nvim-web-devicons", -- optional, for file icon
			},
		},
		{ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } },
	},
	setup = function(self)
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
						{ key = "<leader>k", action = "toggle_file_info" },
						{ key = "<C-o>", action = "system_open" },
						{ key = "<C-v>", action = "vsplit" },
						{ key = "<C-x>", action = "split" },
						{ key = "<C-t>", action = "tabnew" },
						{ key = "h", action = "close_node" },
						{ key = "H", action = "collapse_all" },
						{ key = "K", action = "parent_node" },
						{ key = "l", action = "edit_in_place" },
						{ key = "..", action = "dir_up" },
						{ key = "g?", action = "toggle_help" },
						{ key = "a", action = "create" },
						{ key = "d", action = "remove" },
						{ key = "r", action = "rename" },
						{ key = "<C-Space>", action = "show_node_actions", action_cb = self.show_node_actions },
					},
				},
			},
		})
	end,
})

function ProjectExplorer.show_node_actions(node)
	local finder = require("telescope.finders").new_table({
		results = tree_actions,
		entry_maker = function(tree_action)
			return {
				value = tree_action,
				ordinal = tree_action[1],
				display = tree_action[1],
			}
		end,
	})
	local sorter = require("telescope.sorters").get_generic_fuzzy_sorter({})
	local theme = require("telescope.themes").get_cursor()
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local opts = {
		prompt_title = node.name,
		finder = finder,
		sorter = sorter,
		attach_mappings = function(prompt_buffer_number)
			actions.select_default:replace(function()
				local selection = state.get_selected_entry()
				print(vim.inspect(selection))
				local tree_action = selection.value[2]
				actions.close(prompt_buffer_number)
				vim.defer_fn(function()
					tree_action(node)
				end, 50)
			end)

			return true
		end,
	}

	require("telescope.pickers").new(theme, opts):find()
end

function ProjectExplorer.toggle()
	local view = require("nvim-tree.view")

	if view.is_visible() then
		return view.close()
	end

	require("nvim-tree").open_replacing_current_buffer()
end

return ProjectExplorer
