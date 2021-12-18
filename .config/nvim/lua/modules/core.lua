local au = require('utils.au')
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

	-- Attaching additional commands to qf lists
	-- TODO: completely migrate to lua syntax
	au.group('CoreQFListAdditionalCommands', {
		{
			{'BufRead','BufNewFile'},
			'quickfix',
			function()
				vim.cmd [[command! -buffer -nargs=0 RejectAll lua require('modules.core').clear_list()]]
			end
		}
	})
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

function M.jump_to_from_list()
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

function M.has_locations()
	return #(vim.fn.getloclist(0)) > 0
end

function M.toggle_list()
	if ((vim.fn['qf#IsLocWindowOpen'](0) ~= 0) or M.has_locations()) then
		M.toggle_location_list()
	end

	M.toggle_quickfix_list()
end

function M.next_list_item()
	if (M.has_locations()) then
		M.next_location()
	end

	M.next_quickfix()
end

function M.prev_list_item()
	if (M.has_locations()) then
		M.prev_location()
	end

	M.prev_quickfix()
end

function M.clear_list()
	vim.fn['qf#SetList']({})

	if(vim.fn['qf#IsLocWindow'](0)) ~= 0 then
		M.toggle_location_list()
	else
		M.toggle_quickfix_list()
	end
end

return M
