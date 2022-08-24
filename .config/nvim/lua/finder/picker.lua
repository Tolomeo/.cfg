local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local settings = require("settings")

local Pickers = {}

Pickers.new = validator.f.arguments({
	-- This would be cool but it is not possible because builtin pickers are launched directly
	-- validator.f.list({ validator.f.instance_of(require("telescope.pickers")._Picker) }),
	validator.f.equal(Pickers),
	validator.f.list({ validator.f.shape({ prompt_title = "string", find = "function" }) }),
})
	.. function(self, finders)
		finders._current = 1

		setmetatable(finders, self)
		self.__index = self

		return finders
	end

function Pickers:_prompt_title()
	-- NOTE: this is a lot of code just to calculate a fancy prompt title
	-- TODO: refactor
	local globals = settings.globals()
	local current_picker_title = "[ " .. self[self._current].prompt_title .. " ]"

	-- Creating a table containing all titles making up for the left half of the title
	-- starting from the left half of the current picker title and looping backward
	local i_left = self._current - 1
	local prev_picker_titles = { string.sub(current_picker_title, 1, math.floor(#current_picker_title / 2)) }
	repeat
		if i_left < 1 then
			i_left = #self
		else
			table.insert(prev_picker_titles, 1, self[i_left].prompt_title)
			i_left = i_left - 1
		end
	until i_left == self._current

	-- Creating a table containing all titles making up for the right half of the title
	-- starting from the right half of the current picker title and looping onward
	local i_right = self._current + 1
	local next_picker_titles = {
		string.sub(current_picker_title, (math.floor(#current_picker_title / 2)) + 1, #current_picker_title),
	}
	repeat
		if i_right > #self then
			i_right = 1
		else
			table.insert(next_picker_titles, self[i_right].prompt_title)
			i_right = i_right + 1
		end
	until i_right == self._current

	-- Merging left and right, capping at 40 chars length
	local prompt_title_left = string.reverse(
		string.sub(string.reverse(table.concat(prev_picker_titles, " ")), 1, (20 - #globals.listchars.precedes))
	)
	local prompt_title_right = string.sub(table.concat(next_picker_titles, " "), 1, (20 - #globals.listchars.extends))
	local prompt_title = globals.listchars.precedes
		.. prompt_title_left
		.. prompt_title_right
		.. globals.listchars.extends

	return prompt_title
end

function Pickers:_attach_mappings(buffer)
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

function Pickers:_options()
	return {
		prompt_title = self:_prompt_title(),
		attach_mappings = fn.bind(self._attach_mappings, self),
	}
end

function Pickers:prev()
	self._current = self._current <= 1 and #self or self._current - 1

	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

function Pickers:next()
	self._current = self._current >= #self and 1 or self._current + 1

	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

function Pickers:find()
	local options = self:_options()
	local picker = self[self._current]

	return picker.find(options)
end

local Picker = {}

Picker.plugins = {
	{ "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } },
	{ "nvim-telescope/telescope-project.nvim", requires = { "nvim-telescope/telescope.nvim" } },
	{
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
	},
}

Picker.setup = function()
	Picker._setup_keymaps()
	Picker._setup_plugins()
end

Picker._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["find.files"], Picker.files },
		{ keymaps["find.projects"], Picker.projects },
		{ keymaps["find.search.buffer"], Picker.buffer_text },
		{ keymaps["find.search.directory"], Picker.text },
		{ keymaps["find.help"], Picker.help },
		{ keymaps["find.spelling"], Picker.spelling },
		{ keymaps["find.buffers"], Picker.buffers },
		{ keymaps["find.todos"], Picker.todos }
	)
end

Picker._setup_plugins = function()
	local keymaps = settings.keymaps()
	 
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
					[keymaps["window.cursor.down"]] = require('telescope.actions').move_selection_next,
					[keymaps["window.cursor.up"]] = require("telescope.actions").move_selection_previous,
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

	-- Todo comments
	require("todo-comments").setup({})
end

Picker.Pickers = function(pickers)
	return Pickers:new(pickers)
end

Picker.files = function()
	require("telescope.builtin").find_files()
end

Picker.text = validator.f.arguments({ validator.f.optional("string") })
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

Picker.buffer_text = function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end

Picker.buffers = function()
	require("telescope.builtin").buffers()
end

Picker.help = function()
	return Picker.Pickers({
		{ prompt_title = "Help", find = require("telescope.builtin").help_tags },
		{ prompt_title = "Commands", find = require("telescope.builtin").commands },
		{ prompt_title = "Options", find = require("telescope.builtin").vim_options },
		{ prompt_title = "Autocommands", find = require("telescope.builtin").autocommands },
		{ prompt_title = "Keymaps", find = require("telescope.builtin").keymaps },
		{ prompt_title = "Filetypes", find = require("telescope.builtin").filetypes },
		{ prompt_title = "Highlights", find = require("telescope.builtin").highlights },
	}):find()
end

Picker.projects = function()
	require("telescope").extensions.project.project({ display_type = "full" })
end

Picker.todos = function()
	key.input(":TodoTelescope<CR>")
end

Picker.commands = function()
	require("telescope.builtin").commands()
end

Picker.find_diagnostics = function()
	require("telescope.builtin").diagnostics()
end

Picker.spelling = function()
	require("telescope.builtin").spell_suggest()
end

Picker.menu = validator.f.arguments({
	validator.f.shape({
		validator.f.list({ "string", validator.f.optional("string") }),
		on_select = "function",
	}),
	validator.f.optional(validator.f.shape({
		prompt_title = "string",
	})),
})
	.. function(menu, options)
		options = options or {}

		local entry_display = require("telescope.pickers.entry_display")
		local displayer = entry_display.create({
			separator = " ",
			items = {
				-- calculating the max with needed for the column
				fn.ireduce(menu, function(item, result)
					item.width = math.max(item.width, #result[1])
					return item
				end, { width = 10 }),
				{ remaining = true },
			},
		})
		local make_display = function(entry)
			return displayer({
				entry.value[1],
				{ entry.value[2] or "", "Comment" },
			})
		end
		local entry_maker = function(menu_item)
			return {
				value = menu_item,
				ordinal = menu_item[1],
				display = make_display,
			}
		end

		local finder = require("telescope.finders").new_table({
			results = fn.imap(menu, function(menu_item)
				return menu_item
			end),
			entry_maker = entry_maker,
		})
		local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()
		local default_options = {
			finder = finder,
			sorter = sorter,
			attach_mappings = function(prompt_buffer_number)
				local actions = require("telescope.actions")
				local state = require("telescope.actions.state")
				-- On select item
				actions.select_default:replace(function()
					menu.on_select({ buffer = prompt_buffer_number, state = state, actions = actions })
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

		require("telescope.pickers").new(options, default_options):find()
	end

Picker.context_menu = function(menu, options)
	local theme = require("telescope.themes").get_cursor()
	options = vim.tbl_extend("force", theme, options or {})

	return Picker.menu(menu, options)
end

return Module:new(Picker)
