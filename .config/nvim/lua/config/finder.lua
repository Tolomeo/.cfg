local Module = require("utils.module")
local key = require("utils.key")

local Finder = Module:new({
	plugins = {
		-- UI to select things (files, grep results, open buffers...)
		{ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } },
		"nvim-telescope/telescope-project.nvim",
		"AckslD/nvim-neoclip.lua",
		{
			"folke/todo-comments.nvim",
			requires = "nvim-lua/plenary.nvim",
		},
	},
	setup = function()
		require("telescope").setup({
			defaults = {
				dynamic_preview_title = true,
				color_devicons = true,
				layout_strategy = "vertical",
				layout_config = { prompt_position = "top" },
				mappings = {
					i = {
						["<esc>"] = require("telescope.actions").close,
					},
					n = {},
				},
			},
			pickers = {
				find_files = {},
				live_grep = {
					layout_strategy = "horizontal",
				},
				current_buffer_fuzzy_find = {
					layout_strategy = "horizontal",
				},
				buffers = {
					sort_lastused = true,
				},
				commands = {},
				spell_suggest = {
					theme = "cursor",
				},
				help_tags = {},
			},
		})

		-- Telescope extensions
		require("telescope").load_extension("project")
		-- Todo comments
		require("todo-comments").setup({})
	end,
})

function Finder.find_files()
	require("telescope.builtin").find_files()
end

function Finder.find_in_files()
	require("telescope.builtin").live_grep()
end

function Finder.find_in_buffer()
	require("telescope.builtin").current_buffer_fuzzy_find()
end

function Finder.find_buffers()
	require("telescope.builtin").buffers()
end

function Finder.find_in_documentation()
	require("telescope.builtin").help_tags()
end

function Finder.find_projects()
	require("telescope").extensions.project.project({ display_type = "full" })
end

function Finder.find_yanks()
	require("telescope").extensions.neoclip.default()
end

function Finder.find_todos()
	key.input(":TodoTelescope<CR>")
end

function Finder.find_commands()
	require("telescope.builtin").commands()
end

function Finder.find_spelling()
	require("telescope.builtin").spell_suggest()
end

return Finder
