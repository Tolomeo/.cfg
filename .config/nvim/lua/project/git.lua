local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

---@class Project.Git
local Git = {}

Git.plugins = {
	{ "lewis6991/gitsigns.nvim" },
}

function Git:setup()
	require("gitsigns").setup({
		signs = {
			add = { text = "├" },
			change = { text = "├" },
			delete = { text = "┤" },
			topdelete = { text = "┤" },
			changedelete = { text = "┼" },
			untracked = { text = "│" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
		preview_config = {
			border = "solid",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
		on_attach = function(buffer)
			local keymaps = settings.keymaps()
			local actions = self:actions()
			local mappings = fn.imap(actions, function(action)
				return { action.keymap, action.handler, buffer = buffer }
			end)

			key.nmap(unpack(mappings))
			key.nmap({
				keymaps["git.menu"],
				fn.bind(self.actions_context_menu, self),
			})
		end,
	})
end

function Git:actions()
	local keymaps = settings.keymaps()

	return {
		{
			name = "Show change",
			keymap = keymaps["git.hunk"],
			handler = fn.bind(self.hunk, self),
		},
		{
			name = "Select change",
			keymap = keymaps["git.hunk.select"],
			handler = fn.bind(self.select_hunk, self),
		},
		{
			name = "Go to next change",
			keymap = keymaps["git.hunk.next"],
			handler = fn.bind(self.next_hunk, self),
		},
		{
			name = "Go to prev change",
			keymap = keymaps["git.hunk.prev"],
			handler = fn.bind(self.prev_hunk, self),
		},
		{
			name = "Blame line",
			keymap = keymaps["git.blame"],
			handler = fn.bind(self.blame, self),
		},
		{
			name = "Show changes",
			keymap = keymaps["git.diff"],
			handler = fn.bind(self.diff, self),
		},
	}
end

function Git:actions_context_menu()
	local actions = self:actions()
	local menu = vim.tbl_extend(
		"error",
		fn.imap(actions, function(action)
			return { action.name, action.keymap, handler = action.handler }
		end),
		{
			on_select = function(modal_menu)
				local selection = modal_menu.state.get_selected_entry()
				modal_menu.actions.close(modal_menu.buffer)
				selection.value.handler()
			end,
		}
	)
	local options = {
		prompt_title = "Git changes",
	}

	require("interface.picker"):context_menu(menu, options)
end

function Git:blame()
	return require("gitsigns").blame_line()
end

function Git:diff()
	return require("gitsigns").diffthis()
end

--[[ function Git:has_diff()
	return vim.api.nvim_win_get_option(0, "diff")
end ]]

function Git:hunk()
	return require("gitsigns").preview_hunk()
end

function Git.select_hunk()
	return require("gitsigns").select_hunk()
end

function Git:next_hunk()
	return require("gitsigns.actions").next_hunk()
end

function Git:prev_hunk()
	return require("gitsigns.actions").prev_hunk()
end

return Module:new(Git)
