local key = require('utils.key')
local M = {}

M.plugins = {
	-- UI to select things (files, grep results, open buffers...)
	{ 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } },
	'nvim-telescope/telescope-project.nvim',
	{ "AckslD/nvim-neoclip.lua", config = function() require('neoclip').setup {
		content_spec_column = true,
		preview = true,
		default_register = 'unnamedplus',
		keys = {
			i = {
				paste = '<CR>',
				paste_behind = '<A-CR>',
				custom = {},
			},
			n = {
				paste = '<CR>',
				paste_behind = '<A-CR>',
				custom = {},
			},
		}
	} end },
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
			dynamic_preview_title = true,
			color_devicons = true,
			layout_strategy = 'vertical',
			layout_config = { prompt_position = 'bottom' },
			mappings = {
				i = {
					["<esc>"] = require("telescope.actions").close
				},
				n = {},
			},
		},
		pickers = {
			find_files = {},
			live_grep = {},
			current_buffer_fuzzy_find = {
				layout_strategy = 'horizontal'
			},
			buffers = {
				sort_lastused = true
			},
			commands = {},
			spell_suggest = {
				theme = 'cursor'
			},
			help_tags = {},
		},
	}

	-- Telescope extensions
	require'telescope'.load_extension 'neoclip'
	require'telescope'.load_extension 'project'
end

function M.find_files()
	require('telescope.builtin').find_files()
end

function M.find_in_files()
	require('telescope.builtin').live_grep()

end

function M.find_in_buffer()
	require('telescope.builtin').current_buffer_fuzzy_find()
end

function M.find_buffers()
	require('telescope.builtin').buffers()
end

function M.find_in_documentation()
	require'telescope.builtin'.help_tags()
end

function M.find_projects()
	require'telescope'.extensions.project.project { display_type = 'full' }
end

function M.find_yanks()
	require('telescope').extensions.neoclip.default()
end

function M.find_todos()
	key.input(':TodoTelescope<CR>')
end

function M.find_commands()
	require('telescope.builtin').commands()
end

function M.find_spelling()
	require('telescope.builtin').spell_suggest()
end

return M
