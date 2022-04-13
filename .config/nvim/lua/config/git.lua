local Module = require("utils.module")
local key = require("utils.key")
local Git = {}

Git.plugins = {
	-- Git integration
	"tpope/vim-fugitive",
	-- Add git related info in the signs columns and popups
	{ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } },
	-- Github issues and reviews
	"pwntester/octo.nvim",
}

function Git:setup()
	-- GitSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
	require("gitsigns").setup({
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
	})

	require("octo").setup()
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
