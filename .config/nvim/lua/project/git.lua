local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

---@class Project.Git
local Git = {}

Git.plugins = {
	{ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } },
}

function Git:setup()
	self:_setup_plugins()
end

function Git:_setup_plugins()
	local keymaps = settings.keymaps()
	-- GitSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
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
			key.nmap(
				{ keymaps["git.blame"], fn.bind(self.blame, self), buffer = buffer },
				{ keymaps["git.diff"], fn.bind(self.diff, self), buffer = buffer },
				{ keymaps["git.hunk"], fn.bind(self.show_hunk_preview, self), buffer = buffer },
				{
					keymaps["git.hunk.next"],
					fn.bind(self.next_hunk_preview, self),
					buffer = buffer,
				},
				{
					keymaps["git.hunk.prev"],
					fn.bind(self.prev_hunk_preview, self),
					buffer = buffer,
				}
			)
		end,
	})
end

function Git:blame()
	return require("gitsigns").blame_line()
end

function Git:diff()
	return require("gitsigns").diffthis()
end

--[[ function Git:has_diff()
	return vim.api.nvim_win_get_option(0, "diff") ~= 0
end ]]

function Git:show_hunk_preview()
	return require("gitsigns").preview_hunk()
end

function Git:next_hunk_preview()
	return require("gitsigns.actions").next_hunk()
end

function Git:prev_hunk_preview()
	return require("gitsigns.actions").prev_hunk()
end

return Module:new(Git)
