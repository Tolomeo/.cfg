local Module = require("_shared.module")
local key = require("_shared.key")
local settings = require("settings")

local Git = {}

Git.plugins = {
	-- Add git related info in the signs columns and popups
	{ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } },
}

Git.setup = function()
	Git._setup_keymaps()
	Git._setup_plugins()
end

Git._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["git.blame"], Git.blame },
		{ keymaps["git.log"], Git.log },
		{ keymaps["git.diff"], Git.diff },
		{ keymaps["git.merge"], Git.mergetool },
		{ keymaps["git.hunk"], Git.show_hunk_preview },
		{ keymaps["git.hunk.next"], Git.next_hunk_preview(keymaps["git.hunk.next"]) },
		{ keymaps["git.hunk.prev"], Git.prev_hunk_preview(keymaps["git.hunk.prev"]) }
	)

end

Git._setup_plugins = function()
	-- GitSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
	require("gitsigns").setup({
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
	})
end

function Git.blame()
	key.input(":Git blame<CR>")
end

function Git.log()
	key.input(":Git log<CR>")
end

function Git.diff()
	key.input(":Git diff<CR>")
end

function Git.mergetool()
	key.input(":Git mergetool<CR>")
end

-- TODO: move to core?
function Git.has_diff()
	return vim.api.nvim_win_get_option(0, "diff") ~= 0
end

function Git.show_hunk_preview()
	require("gitsigns").preview_hunk()
end

-- vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git.next_hunk_preview(next)
	return function()
		if not Git.has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").next_hunk()
	end
end

-- vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git.prev_hunk_preview(next)
	return function()
		if not Git.has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").prev_hunk()
	end
end

return Module:new(Git)
