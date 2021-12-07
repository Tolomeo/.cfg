local M = {}

M.plugins = {
	-- Automatic management of tags
	'ludovicchabant/vim-gutentags',
	-- Reload and restard commands
	'famiu/nvim-reload',
	-- Automatically changes cwd based on the root of the project
	{ 'airblade/vim-rooter', setup = function ()
		-- Setting files/dirs to look for to understand what the root dir is
		vim.api.nvim_set_var('rooter_patterns', {'=nvim', '.git', 'package.json' })
	end },
	-- Shows where your cursor moves
	'edluffy/specs.nvim'
}

function M.setup()
	-- write only if changed
	vim.api.nvim_set_keymap("n", "<Leader>w", ":up<CR>", { noremap = true })
	-- quit (or close window)
	vim.api.nvim_set_keymap("n", "<Leader>q", ":q<CR>", { noremap = true, silent = true })
	-- Discard all changed buffers & quit
	vim.api.nvim_set_keymap("n", "<Leader>Q", ":qall!<CR>", { noremap = true, silent = true })
	-- write all and quit
	vim.api.nvim_set_keymap("n", "<Leader>W", ":wqall<CR>", { noremap = true, silent = true })

	-- Using system clipbard as default register
	vim.o.clipboard = 'unnamedplus'

	-- Spellcheck
	vim.o.spell = false
	vim.o.spelllang = 'en_gb'

	vim.cmd [[
	autocmd BufRead,BufNewFile *.md setlocal spell
	]]

	-- Specs
	require('specs').setup({
		show_jumps  = true,
		min_jump = 30,
		popup = {
			delay_ms = 100, -- delay before popup displays
			inc_ms = 15, -- time increments used for fade/resize effects
			blend = 15, -- starting blend, between 0-100 (fully transparent), see :h winblend
			width = 10,
			winhl = "PMenu",
			fader = require('specs').pulse_fader,
			resizer = require('specs').slide_resizer
		},
		ignore_filetypes = {},
		ignore_buftypes = {
			nofile = true,
		}
	})
	vim.api.nvim_set_keymap('n', '<leader><space>', ':lua require("specs").show_specs()<CR>', { noremap = true, silent = true })
end

return M
