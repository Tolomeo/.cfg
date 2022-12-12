local Module = require("_shared.module")
local key = require("_shared.key")
local validator = require("_shared.validator")
local fn = require("_shared.fn")
local settings = require("settings")

---@class Project.Tree
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

function Tree:actions()
	local keymaps = settings.keymaps()

	return {
		{
			name = "View info",
			keymap = keymaps["project.tree.node.info"],
			handler = require("nvim-tree.api").node.show_info_popup,
		},
		{
			name = "Edit in vertical split",
			keymap = keymaps["project.tree.node.open.vertical"],
			handler = require("nvim-tree.api").node.open.vertical,
		},
		{
			name = "Edit in horizontal split",
			keymap = keymaps["project.tree.node.open.horizontal"],
			handler = require("nvim-tree.api").node.open.horizontal,
		},
		{
			name = "Edit in tab",
			keymap = keymaps["project.tree.node.open.tab"],
			handler = require("nvim-tree.api").node.open.tab,
		},
		{
			name = "Close node",
			keymap = keymaps["project.tree.node.collapse"],
			handler = require("nvim-tree.api").node.navigate.parent_close,
		},
		{
			name = "Open node",
			keymap = keymaps["project.tree.node.open"],
			handler = require("nvim-tree.api").node.open.replace_tree_buffer,
		},
		{
			name = "Change directory here",
			keymap = keymaps["project.tree.fs.enter"],
			handler = require("nvim-tree.api").tree.change_root_to_node,
		},
		{
			name = "Open with in OS",
			keymap = keymaps["project.tree.node.open.system"],
			handler = require("nvim-tree.api").node.run.system,
		},
		{
			name = "Create node",
			keymap = keymaps["project.tree.fs.create"],
			handler = require("nvim-tree.api").fs.create,
		},
		{
			name = "Remove node",
			keymap = keymaps["project.tree.fs.remove"],
			handler = require("nvim-tree.api").fs.remove,
		},
		{
			name = "Trash node",
			keymap = keymaps["project.tree.fs.trash"],
			handler = require("nvim-tree.api").fs.trash,
		},
		{
			name = "Rename node",
			keymap = keymaps["project.tree.fs.rename"],
			handler = require("nvim-tree.api").fs.rename,
		},
		{
			name = "Fully rename node",
			keymap = keymaps["project.tree.fs.rename.full"],
			handler = require("nvim-tree.api").fs.rename_sub,
		},
		{
			name = "Copy",
			keymap = keymaps["project.tree.fs.copy.node"],
			handler = require("nvim-tree.api").fs.copy.node,
		},
		{ name = "Cut", keymap = keymaps["project.tree.fs.cut"], handler = require("nvim-tree.api").fs.cut },
		{ name = "Paste", keymap = keymaps["project.tree.fs.paste"], handler = require("nvim-tree.api").fs.paste },
		{
			name = "Copy node name",
			keymap = keymaps["project.tree.fs.copy.filename"],
			handler = require("nvim-tree.api").fs.copy.filename,
		},
		{
			name = "Copy relative path",
			keymap = keymaps["project.tree.fs.copy.path.relative"],
			handler = require("nvim-tree.api").fs.copy.relative_path,
		},
		{
			name = "Copy absolute path",
			keymap = keymaps["project.tree.fs.copy.path.absolute"],
			handler = require("nvim-tree.api").fs.copy.absolute_path,
		},
		{ name = "Refresh", keymap = keymaps["project.tree.refresh"], handler = require("nvim-tree.api").tree.reload },
		{
			name = "Collapse all nodes",
			keymap = keymaps["project.tree.collapse.all"],
			handler = require("nvim-tree.api").tree.collapse_all,
		},
		-- { name = "Expand all nodes", keymap = keymaps["project.tree.expand.all"], handler = require("nvim-tree.api").tree.expand_all },
		{
			name = "Go to node parent",
			keymap = keymaps["project.tree.navigate.parent"],
			handler = require("nvim-tree.api").node.navigate.parent,
		},
		{
			name = "Go to first sibling",
			keymap = keymaps["project.tree.navigate.sibling.first"],
			handler = require("nvim-tree.api").node.navigate.sibling.first,
		},
		{
			name = "Go to last sibling",
			keymap = keymaps["project.tree.navigate.sibling.last"],
			handler = require("nvim-tree.api").node.navigate.sibling.last,
		},
		{
			name = "Toggle help",
			keymap = keymaps["project.tree.help"],
			handler = require("nvim-tree.api").tree.toggle_help,
		},
		{ name = "Close", keymap = keymaps["project.tree.close"], handler = require("nvim-tree.api").tree.close },
		{
			name = "Change root up one directory",
			keymap = keymaps["project.tree.root.parent"],
			handler = require("nvim-tree.api").tree.change_root_to_parent,
		},
		{
			name = "Toggle custom filter",
			keymap = keymaps["project.tree.toggle.filter.custom"],
			handler = require("nvim-tree.api").tree.toggle_custom_filter,
		},
		{
			name = "Toggle gitignore filter",
			keymap = keymaps["project.tree.toggle.filter.gitignore"],
			handler = require("nvim-tree.api").tree.toggle_gitignore_filter,
		},
		{
			name = "Toggle dotfiles filter",
			keymap = keymaps["project.tree.toggle.filter.dotfiles"],
			handler = require("nvim-tree.api").tree.toggle_hidden_filter,
		},
		{
			name = "Show actions",
			keymap = keymaps["project.tree.actions"],
			handler = require("nvim-tree.utils").inject_node(fn.bind(self.tree_actions_menu, self)),
		},
		{
			name = "Search node contents",
			keymap = keymaps["project.tree.search.node.content"],
			handler = require("nvim-tree.utils").inject_node(fn.bind(self.search_in_node, self)),
		},
		{
			name = "Search node",
			keymap = keymaps["project.tree.search.node"],
			handler = require("nvim-tree.api").tree.search_node,
		},
	}
end

function Tree:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

function Tree:_setup_keymaps()
	local keymaps = settings.keymaps()

	key.nmap({ keymaps["project.tree.toggle"], fn.bind(self.toggle, self) })
end

function Tree:_setup_plugins()
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
		},
		on_attach = function(tree_buffer)
			local actions = self:actions()
			local mappings = fn.imap(actions, function(action)
				return { action.keymap, action.handler, buffer = tree_buffer }
			end)

			key.nmap(unpack(mappings))
		end,
		remove_keymaps = true,
	})
end

---@alias TreeNode
--- | {name: string} # Node representing the parent directory
--- | {absolute_path: string, fs_stat: { type: string } } # Node

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

---@type fun(self: Project.Tree, node: TreeNode)
Tree.search_in_node = validator.f.arguments({ validator.f.equal(Tree), validate_node })
	.. function(_, node)
		-- when the selected node is the one pointing at the parent director absolute_path will not be present
		if not node.absolute_path then
			return require("finder.picker"):text()
		end

		if node.fs_stat.type == "directory" then
			return require("finder.picker"):text(node.absolute_path)
		end

		if node.fs_stat.type == "file" then
			require("nvim-tree.actions.node.open-file").fn("edit_in_place", node.absolute_path)
			return require("finder.picker"):buffer_text()
		end
	end

---@type fun(self: Project.Tree, node: TreeNode)
Tree.tree_actions_menu = validator.f.arguments({ validator.f.equal(Tree), validate_node })
	.. function(self, node)
		local actions = self:actions()
		local menu = vim.tbl_extend(
			"error",
			fn.imap(actions, function(action)
				return { action.name, action.keymap, handler = action.handler }
			end),
			{
				on_select = function(context_menu)
					local selection = context_menu.state.get_selected_entry()
					context_menu.actions.close(context_menu.buffer)
					selection.value.handler(node)
				end,
			}
		)
		local options = { prompt_title = node.name }

		require("finder.picker"):context_menu(menu, options)
	end

function Tree:toggle()
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
