local key = require('utils.key')
local M = {}

M.plugins = {
	-- Automatic management of tags
	'ludovicchabant/vim-gutentags',
	-- Reload and restard commands
	'famiu/nvim-reload',
	-- Automatically changes cwd based on the root of the project
	'airblade/vim-rooter',
	-- General qf and loc lists improvements
	{ 'romainl/vim-qf', setup = function() vim.api.nvim_set_var('qf_mapping_ack_style', true) end },
}

function M.setup()
	-- Setting files/dirs to look for to understand what the root dir is
	vim.api.nvim_set_var('rooter_patterns', {'=nvim', '.git', 'package.json' })
  -- Ack style keybindings when in quickfix list buffer
	vim.api.nvim_set_var('qf_mapping_ack_style', true)
end

function M.toggle_quickfixes()
	key.input('<Plug>(qf_qf_toggle)', 'm')
end

function M.jump_to_quickfixes()
	key.input( '<Plug>(qf_qf_switch)', 'm')
end

function M.next_quickfix()
	key.input( '<Plug>(qf_qf_next)', 'm')
end

function M.prev_quickfix()
	key.input( '<Plug>(qf_qf_previous)', 'm')
end

function M.next_quickfixes_file()
	key.input( '<Plug>(qf_qf_next_file)', 'm')
end

function M.prev_quickfixes_file()
	key.input( '<Plug>(qf_qf_previous_file)', 'm')
end

return M
