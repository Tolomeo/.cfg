local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local settings = require("settings")

local Finder = {}

Finder.plugins = {
	-- UI to select things (files, grep results, open buffers...)
	{ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } },
	"nvim-telescope/telescope-project.nvim",
	"AckslD/nvim-neoclip.lua",
	{
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	},
	"romainl/vim-cool",
}

Finder.modules = {
	list = require("finder.list"),
}

Finder.setup = function()
	Finder._setup_keymaps()
	Finder._setup_plugins()
end

Finder._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		-- Keep search results centered
		{ "n", "nzzzv" },
		{ "N", "Nzzzv" },
		-- finder
		{ keymaps["finder.files"], Finder.find_files },
		{ keymaps["finder.commands"], Finder.find_commands },
		{ keymaps["finder.projects"], Finder.find_projects },
		{ keymaps["finder.search.buffer"], Finder.find_in_buffer },
		{ keymaps["finder.search.directory"], Finder.find_in_directory },
		{ keymaps["finder.help"], Finder.find_in_documentation },
		{ keymaps["finder.spelling"], Finder.find_spelling },
		{ keymaps["finder.buffers"], Finder.find_buffers }
		-- { "<C-y>", Finder.find_yanks },
		-- { "<C-t>", modules.finder.find_todos }
	)
end

Finder._setup_plugins = function()
	require("telescope").setup({
		defaults = {
			layout_strategy = "flex",
			layout_config = {
				prompt_position = "top",
			},
			sorting_strategy = "ascending",
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
			current_buffer_fuzzy_find = {},
			buffers = {
				sort_lastused = true,
			},
			commands = {},
			spell_suggest = {},
			help_tags = {},
		},
	})

	-- Telescope extensions
	require("telescope").load_extension("project")
	-- Todo comments
	require("todo-comments").setup({})

	-- Vim-cool
	vim.g.CoolTotalMatches = 1
end

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

local Finders = {}

Finders.new = validator.f.arguments({
	-- This would be cool but it is not possible because builtin pickers are launched directly
	-- validator.f.list({ validator.f.instance_of(require("telescope.pickers")._Picker) }),
	validator.f.equal(Finders),
	validator.f.list({ validator.f.shape({ prompt_title = "string", find = "function" }) }),
})
	.. function(self, finders)
		finders._current = 1

		setmetatable(finders, self)
		self.__index = self

		return finders
	end

function Finders:_prompt_title()
	local globals = settings.globals()

	-- NOTE: this is a lot of code just to calculate a fancy prompt title
	-- TODO: refactor
	local current_picker_title = self[self._current].prompt_title
	current_picker_title = "[ " .. current_picker_title .. (#current_picker_title % 2 == 0 and " ]" or "  ]")

	local i_left = self._current - 1
	local prev_picker_titles = { string.sub(current_picker_title, 1, #current_picker_title / 2) }
	repeat
		if i_left < 1 then
			i_left = #self
			goto continue_left
		end

		table.insert(prev_picker_titles, 1, self[i_left].prompt_title)
		i_left = i_left - 1

		::continue_left::
	until i_left == self._current

	local i_right = self._current + 1
	local next_picker_titles = { string.sub(current_picker_title, (#current_picker_title / 2) + 1, #current_picker_title) }
	repeat
		if i_right > #self then
			i_right = 1
			goto continue_right
		end

		table.insert(next_picker_titles, self[i_right].prompt_title)
		i_right = i_right + 1

		::continue_right::
	until i_right == self._current

	local prompt_title_left = string.reverse(string.sub(string.reverse(table.concat(prev_picker_titles, globals.listchars.space)), 1, 19))
	local prompt_title_right = string.sub(table.concat(next_picker_titles, globals.listchars.space), 1, 19)
	local prompt_title = globals.listchars.precedes .. prompt_title_left .. prompt_title_right .. globals.listchars.extends

	return prompt_title
end

function Finders:_attach_mappings(buffer)
	local keymaps = settings.keymaps()

	key.imap({
		keymaps["buffer.next"],
		fn.bind(self.next, self),
		buffer = buffer,
	}, {
		keymaps["buffer.prev"],
		fn.bind(self.prev, self),
		buffer = buffer,
	})

	return true
end

function Finders:_options()
	return {
		prompt_title = self:_prompt_title(),
		attach_mappings = fn.bind(self._attach_mappings, self),
	}
end

function Finders:prev()
	self._current = self._current <= 1 and #self or self._current - 1

	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

function Finders:next()
	self._current = self._current >= #self and 1 or self._current + 1

	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

function Finders:find()
	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

Finder.find_in_documentation = function()
	local finders = {
		{ prompt_title = "Help", find = require("telescope.builtin").help_tags },
		{ prompt_title = "Commands", find = require("telescope.builtin").commands },
		{ prompt_title = "Options", find = require("telescope.builtin").vim_options },
		{ prompt_title = "Autocommands", find = require("telescope.builtin").autocommands },
		{ prompt_title = "Keymaps", find = require("telescope.builtin").keymaps },
		{ prompt_title = "Filetypes", find = require("telescope.builtin").filetypes },
		{ prompt_title = "Highlights", find = require("telescope.builtin").highlights },
	}

	return Finders:new(finders):find()
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

return Module:new(Finder)
