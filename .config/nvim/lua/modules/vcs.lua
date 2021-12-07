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

	-- Git blame
	vim.api.nvim_set_keymap(
		"n",
		"gb",
		':Git blame<CR>',
		{ noremap = true, silent = true }
	)

	-- Git log
	vim.api.nvim_set_keymap(
		"n",
		"gl",
		':Git log<CR>',
		{ noremap = true, silent = true }
	)

	-- Git diff
	vim.api.nvim_set_keymap(
		"n",
		"gd",
		':Git diff<CR>',
		{ noremap = true, silent = true }
	)

	-- Git merge
	vim.api.nvim_set_keymap(
		"n",
		"gm",
		':Git mergetool<CR>',
		{ noremap = true, silent = true }
	)

	-- Toggle hunk preview
	vim.api.nvim_set_keymap(
		"n",
		"gh",
		[[<Cmd>lua require'gitsigns'.preview_hunk()<CR>]],
		{ noremap = true, silent = true }
	)
	-- Cycling through hunks with TAB and S-TAB
	vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
	vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
end

return M
