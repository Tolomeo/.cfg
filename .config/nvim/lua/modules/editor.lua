local key = require('utils.key')
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
	-- Autoclosing pair of chars
	'windwp/nvim-autopairs',
	-- Parentheses, brackets, quotes, XML tags
	'tpope/vim-surround',
	-- Shows where your cursor moves
	'edluffy/specs.nvim'
}

function M.setup ()

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

	-- Autopairs
	require('nvim-autopairs').setup({
		disable_filetype = { "TelescopePrompt" , "vim" },
	})

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
end

-- vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
function M.comment_line()
	key.input('<Plug>kommentary_line_default', 'm')
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function M.comment_selection()
	key.input('<Plug>kommentary_visual_default', 'm')
end

-- key.map { 'n', '<leader><space>', ':lua require("specs").show_specs()<CR>' }
function M.find_cursor()
	require("specs").show_specs()
end

-- Replace word under cursor in line
function M.replace_current_word_in_buffer()
	key.input(':%s/<C-r><C-w>//gI<left><left><left>')
end

-- Replace word under cursor in line
function M.replace_current_word_in_line()
	key.input(':s/<C-r><C-w>//gI<left><left><left>')
end

-- vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true })
function M.move_line_down()
	key.input ':m .+1<CR>=='
end

-- vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true })
function M.move_line_up()
	key.input ':m .-2<CR>=='
end

-- vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
function M.move_selected_lines_up()
	key.input ":m '<-2<CR>gv=gv"
end

-- vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
function M.move_selected_lines_down()
	key.input ":m '>+1<CR>gv=gv"
end

return M
