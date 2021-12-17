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
end

function M.toggle_location_list()
	key.input('<Plug>(qf_loc_toggle)', 'm')
end

function M.next_location()
	key.input('<Plug>(qf_loc_next)', 'm')
end

function M.prev_location()
	key.input('<Plug>(qf_loc_previous)', 'm')
end

function M.toggle_quickfix_list()
	key.input('<Plug>(qf_qf_toggle)', 'm')
end

function M.jump_to_quickfix_list()
	key.input( '<Plug>(qf_qf_switch)', 'm')
end

function M.next_quickfix()
	key.input( '<Plug>(qf_qf_next)', 'm')
end

function M.prev_quickfix()
	key.input( '<Plug>(qf_qf_previous)', 'm')
end

function M.next_quickfix_group()
	key.input( '<Plug>(qf_qf_next_file)', 'm')
end

function M.prev_quickfix_group()
	key.input( '<Plug>(qf_qf_previous_file)', 'm')
end

-- the followings are inspired by https://github.com/romainl/vim-qf/pull/90/files

function M.next_list_item()
	if vim.fn['qf#IsQfWindowOpen']() ~= 0 then
		M.next_quickfix()
	else
		M.next_location()
	end
end

function M.prev_list_item()
	if vim.fn['qf#IsQfWindowOpen']() ~= 0 then
		M.prev_quickfix()
	else
		M.prev_location()
	end
end

return M
