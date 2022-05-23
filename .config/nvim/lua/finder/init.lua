local Module = require("_shared.module")
local key = require("_shared.key")
local validator = require("_shared.validator")

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
	modules = {
		list = require("finder.list"),
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

Finder.find_files = function()
	require("telescope.builtin").find_files()
end

Finder.find_in_directory = validator.f.arguments({ validator.f.optional("string") })
	.. function(directory)
		local root = vim.loop.cwd()
		local searchDirectory = directory or root
		local rootRelativeCwd = root == searchDirectory and "/" or string.gsub(searchDirectory, root, "")
		local options = {
			cwd = searchDirectory,
			prompt_title = "Search in " .. rootRelativeCwd,
		}

		require("telescope.builtin").live_grep(options)
	end

Finder.find_in_buffer = function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end

Finder.find_buffers = function()
	require("telescope.builtin").buffers()
end

Finder.find_in_documentation = function()
	require("telescope.builtin").help_tags()
end

Finder.find_projects = function()
	require("telescope").extensions.project.project({ display_type = "full" })
end

Finder.find_yanks = function()
	require("telescope").extensions.neoclip.default()
end

Finder.find_todos = function()
	key.input(":TodoTelescope<CR>")
end

Finder.find_commands = function()
	require("telescope.builtin").commands()
end

Finder.find_diagnostics = function()
	require("telescope.builtin").diagnostics()
end

Finder.find_spelling = function()
	require("telescope.builtin").spell_suggest()
end

Finder.contex_menu = validator.f.arguments({
	validator.f.shape({
		results = validator.f.list({ validator.f.list({ "string", "function" }) }),
		entry_maker = "function",
	}),
	"function",
	validator.f.optional(validator.f.shape({
		prompt_title = "string",
	})),
})
	.. function(items, on_select, options)
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
