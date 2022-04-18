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
				mappings = {
					i = {
						["<esc>"] = require("telescope.actions").close,
					},
					n = {},
				},
			},
			pickers = {
				find_files = {},
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

function Finder.find_in_directory(directory)
	local root = vim.loop.cwd()
	local searchDirectory = directory or root
	local rootRelativeCwd = root == searchDirectory and "/" or string.gsub(searchDirectory, root, "")

	local options = require("telescope.themes").get_dropdown()
	options.cwd = searchDirectory
	options.prompt_title = "Search in " .. rootRelativeCwd

	require("telescope.builtin").live_grep(options)
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

function Finder.contex_menu(items, on_select, options)
	options = options or {}
	local finder = require("telescope.finders").new_table(items)
	local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()
	local theme = require("telescope.themes").get_cursor()
	local actions = require("telescope.actions")
	local state = require("telescope.actions.state")
	local opts = {
		prompt_title = options.prompt_title,
		finder = finder,
		sorter = sorter,
		attach_mappings = function(prompt_buffer_number)
			-- On select item
			actions.select_default:replace(function()
				on_select({ buffer = prompt_buffer_number, state = state, actions = actions })
			end)
			-- Disabling any kind of multiple selection
			actions.add_selection:replace(function() end)
			actions.remove_selection:replace(function() end)
			actions.toggle_selection:replace(function() end)
			actions.select_all:replace(function() end)
			actions.drop_all:replace(function() end)
			actions.toggle_all:replace(function() end)

			return true
		end,
	}

	require("telescope.pickers").new(theme, opts):find()
end

return Finder
