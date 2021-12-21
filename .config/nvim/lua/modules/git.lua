local key = require('utils.key')
local M  = {}

M.plugins = {
	-- Git integration
	'tpope/vim-fugitive',
	-- Add git related info in the signs columns and popups
	{ 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
}

function M.setup()
	-- GitSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
	require('gitsigns').setup {
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		}
	}
end

function M.blame()
	key.input(':Git blame<CR>')
end

function M.log()
	key.input(':Git log<CR>')
end

function M.diff()
	key.input(':Git diff<CR>')
end

function M.mergetool()
	key.input(':Git mergetool<CR>')
end

-- TODO: move to core?
function M.has_diff()
 return vim.api.nvim_win_get_option(0, "diff") ~= 0
end

function M.show_hunk_preview()
	require'gitsigns'.preview_hunk()
end

-- vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function M.next_hunk_preview(next)
	return function ()
		if (not M.has_diff()) then
			key.input(next)
			return
		end

		require'gitsigns.actions'.next_hunk()
	end
end

-- vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function M.prev_hunk_preview(next)
	return function ()
		if (not M.has_diff()) then
			key.input(next)
			return
		end

		require'gitsigns.actions'.prev_hunk()
	end
end

return M
