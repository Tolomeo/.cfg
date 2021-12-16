local key = require('utils.key')
local M = {}

M.plugins = {
	-- General qf and loc lists improvements
	{ 'romainl/vim-qf', setup = function() vim.api.nvim_set_var('qf_mapping_ack_style', true) end },
	-- UI to select things (files, grep results, open buffers...)
	{ 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } },
	"nvim-telescope/telescope-file-browser.nvim",
	'nvim-telescope/telescope-project.nvim',
	{ "AckslD/nvim-neoclip.lua", config = function() require('neoclip').setup() end },
	{
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function() require("todo-comments").setup {} end
	},
}

function M.setup()
	-- Telescope
	require('telescope').setup {
		defaults = {
			defaults = {
				color_devicons = true,
			},
			mappings = {
				i = {
					['<C-u>'] = false,
					['<C-d>'] = false,
				},
				n = {
				},
			},
		},
	}
	-- Telescope extensions
	require"telescope".load_extension "file_browser"
	require'telescope'.load_extension 'neoclip'
	require'telescope'.load_extension 'project'
end

function M.find_files()
	require('telescope.builtin').find_files()
end

function M.browse_files()
	require('telescope').extensions.file_browser.file_browser({ hidden = true })
end

-- vim.api.nvim_set_keymap('n', '<C-f>', "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap = true })
function M.find_in_files()
	require('telescope.builtin').live_grep()
end
-- vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({previewer = false})<CR>]], { noremap = true, silent = true })
function M.find_in_buffer()
	require('telescope.builtin').current_buffer_fuzzy_find()
end
-- vim.api.nvim_set_keymap('n', '<C-Tab>', "<cmd>lua require('telescope.builtin').buffers()<CR>", { noremap = true })
function M.find_buffers()
	require('telescope.builtin').buffers()
end

-- Project keybindings
--[[ vim.api.nvim_set_keymap(
	'n',
	'<C-o>',
	":lua require'telescope'.extensions.project.project{ display_type = 'full' }<CR>",
	{noremap = true, silent = true}
) ]]
function M.find_projects()
	require'telescope'.extensions.project.project { display_type = 'full' }
end

-- vim.api.nvim_set_keymap('n', '<C-y>', "<cmd>lua require('telescope').extensions.neoclip.default()<CR>", { silent = true })
function M.find_yanks()
	require('telescope').extensions.neoclip.default()
end

-- vim.api.nvim_set_keymap('n', '<C-t>', '<cmd>TodoTelescope<CR>', { silent = true, noremap = true })
function M.find_todos()
	key.input(':TodoTelescope<CR>')
end

-- vim.api.nvim_set_keymap('n', '<C-c>', '<Plug>(qf_qf_toggle_stay)', {})
function M.toggle_quickfixes()
	key.input('<Plug>(qf_qf_toggle', 'm')
end

-- vim.api.nvim_set_keymap('n', '<leader>c', '<Plug>(qf_qf_switch)', {})
function M.jump_to_quickfixes()
	key.input( '<Plug>(qf_qf_switch)', 'm')
end

-- vim.api.nvim_set_keymap('n', '<C-]>', '<Plug>(qf_qf_next)', {})
function M.next_quickfix()
	key.input( '<Plug>(qf_qf_next)', 'm')
end

-- vim.api.nvim_set_keymap('n', '<C-[>', '<Plug>(qf_qf_previous)', {})
function M.prev_quickfix()
	key.input( '<Plug>(qf_qf_previous)', 'm')
end

-- vim.api.nvim_set_keymap('n', '<C-}>', '<Plug>(qf_qf_next_file)', {})
function M.next_quickfixes_file()
	key.input( '<Plug>(qf_qf_next_file)', 'm')
end

-- vim.api.nvim_set_keymap('n', '<C-{>', '<Plug>(qf_qf_previous_file)', {}) ]]
function M.prev_quickfixes_file()
	key.input( '<Plug>(qf_qf_previous_file)', 'm')
end

return M
