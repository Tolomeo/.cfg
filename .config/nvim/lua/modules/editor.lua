local M = {}

M.plugins = {
	-- Highlight, edit, and code navigation parsing library
	'nvim-treesitter/nvim-treesitter',
	'nvim-treesitter/nvim-treesitter-textobjects',
	-- Indentation guides
	'lukas-reineke/indent-blankline.nvim',
	-- Comments
	'b3nj5m1n/kommentary',
	'JoosepAlviste/nvim-ts-context-commentstring',
	-- Auto closing tags
	'windwp/nvim-ts-autotag',
	-- Parentheses, brackets, quotes, XML tags
	'tpope/vim-surround',
	-- Shows where your cursor moves
	'edluffy/specs.nvim'
}

function M.setup ()
	--Remap for dealing with word wrap
	vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
	vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

	-- Highlight on yank
	vim.cmd [[
	augroup YankHighlight
	autocmd!
	autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
	]]

	-- Join lines and restore cursor location
	vim.api.nvim_set_keymap("n", "J", "mjJ`j", { noremap = true })

	-- Yank until the end of line  (note: this is now a default on master)
	-- vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })
	-- Select all
	vim.api.nvim_set_keymap('n', 'YY', ':%y<CR>', { silent = true, noremap = true })

	-- Opening new lines with Enter in normal mode
	vim.api.nvim_set_keymap('n', '<Enter>', 'o<ESC>', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('n', '<S-Enter>', 'O<ESC>', { noremap = true, silent = true })
	-- Moving lines with ALT key
	-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
	vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true, silent = true })
	vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
	vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

	-- Moving among windows with arrows
	vim.api.nvim_set_keymap('n', '<up>', '<C-w><up>', { noremap = false, silent = true })
	vim.api.nvim_set_keymap('n', '<down>', '<C-w><down>', { noremap = false, silent = true })
	vim.api.nvim_set_keymap('n', '<left>', '<C-w><left>', { noremap = false, silent = true })
	vim.api.nvim_set_keymap('n', '<right>', '<C-w><right>', { noremap = false, silent = true })

	-- Replace word under cursor in buffer
	vim.api.nvim_set_keymap('n', '<leader>sr', ':%s/<C-r><C-w>//gI<left><left><left>', { noremap = false, silent = false })
	vim.api.nvim_set_keymap('n', '<leader>sl', ':s/<C-r><C-w>//gI<left><left><left>', { noremap = false, silent = false })

	--Map blankline
	vim.opt.list = true
	vim.opt.listchars:append("space:⋅")

	require("indent_blankline").setup {
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = true,
		use_treesitter = true,
		strict_tabs = true,
		context_char = '┃'
	}

	-- KOMMENTARY
	-- see https://github.com/b3nj5m1n/kommentary
	vim.g.kommentary_create_default_mappings = false
	vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
	-- vim.api.nvim_set_keymap("n", "<leader>C", "<Plug>kommentary_motion_default", {})
	vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {})

	-- Treesitter configuration
	-- Parsers must be installed manually via :TSInstall
	require('nvim-treesitter.configs').setup {
		ensure_installed = {'lua', 'html', 'css', 'scss', 'dockerfile', 'dot', 'json', 'jsdoc', 'yaml', 'javascript', 'typescript', 'tsx' },
		sync_install = true,
		highlight = {
			enable = true, -- false will disable the whole extension
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = 'gnn',
				node_incremental = 'grn',
				scope_incremental = 'grc',
				node_decremental = 'grm',
			},
		},
		indent = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					['af'] = '@function.outer',
					['if'] = '@function.inner',
					['ac'] = '@class.outer',
					['ic'] = '@class.inner',
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					[']m'] = '@function.outer',
					[']]'] = '@class.outer',
				},
				goto_next_end = {
					[']M'] = '@function.outer',
					[']['] = '@class.outer',
				},
				goto_previous_start = {
					['[m'] = '@function.outer',
					['[['] = '@class.outer',
				},
				goto_previous_end = {
					['[M'] = '@function.outer',
					['[]'] = '@class.outer',
				},
			},
		},
		context_commentstring = {
			enable = true
		}
	}

	-- Autotag
	require('nvim-ts-autotag').setup()

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
