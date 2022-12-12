local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

---@class Project.Git
local Git = {}

Git.plugins = {
	-- Add git related info in the signs columns and popups
	{ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } },
}

function Git:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

function Git:_setup_keymaps()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["git.blame"], fn.bind(self.blame, self) },
		{ keymaps["git.log"], fn.bind(self.log, self) },
		{ keymaps["git.diff"], fn.bind(self.diff, self) },
		{ keymaps["git.merge"], fn.bind(self.mergetool, self) },
		{ keymaps["git.hunk"], fn.bind(self.show_hunk_preview, self) },
		{ keymaps["git.hunk.next"], fn.bind(self.next_hunk_preview, self, keymaps["git.hunk.next"]) },
		{ keymaps["git.hunk.prev"], fn.bind(self.prev_hunk_preview, self, keymaps["git.hunk.prev"]) }
	)
end

function Git:_setup_plugins()
	-- GitSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
	require("gitsigns").setup({
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
	})
end

function Git:blame()
	key.input(":Git blame<CR>")
end

function Git:log()
	key.input(":Git log<CR>")
end

function Git:diff()
	key.input(":Git diff<CR>")
end

function Git:mergetool()
	key.input(":Git mergetool<CR>")
end

-- TODO: move to core?
function Git:has_diff()
	return vim.api.nvim_win_get_option(0, "diff") ~= 0
end

function Git:show_hunk_preview()
	require("gitsigns").preview_hunk()
end

-- vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git:next_hunk_preview(next)
	return function()
		if not self:has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").next_hunk()
	end
end

-- vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git:prev_hunk_preview(next)
	return function()
		if not self:has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").prev_hunk()
	end
end

return Module:new(Git)
