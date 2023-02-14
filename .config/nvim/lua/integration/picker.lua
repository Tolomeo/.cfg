local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local settings = require("settings")

---@class Finder.Picker.Tab
---@field prompt_title string
---@field find function

---@class Finder.Picker.Tabs
local Tabs = {}

---@type fun(self: Finder.Picker.Tabs, tabs: Finder.Picker.Tab[]): Finder.Picker.Tabs
Tabs.new = validator.f.arguments({
	-- This would be cool but it is not possible because builtin pickers are launched directly
	-- validator.f.list({ validator.f.instance_of(require("telescope.pickers")._Picker) }),
	validator.f.equal(Tabs),
	validator.f.list({ validator.f.shape({ prompt_title = "string", find = "function" }) }),
})
	.. function(self, tabs)
		tabs._current = 1

		setmetatable(tabs, self)
		self.__index = self

		return tabs
	end

function Tabs:_prompt_title()
	-- NOTE: this is a lot of code just to calculate a fancy prompt title
	-- TODO: refactor
	local opt = settings.opt
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
		string.sub(string.reverse(table.concat(prev_picker_titles, " ")), 1, (20 - #opt.listchars.precedes))
	)
	local prompt_title_right = string.sub(table.concat(next_picker_titles, " "), 1, (20 - #opt.listchars.extends))
	local prompt_title = opt.listchars.precedes .. prompt_title_left .. prompt_title_right .. opt.listchars.extends

	return prompt_title
end

---@param buffer number
---@return boolean
function Tabs:_attach_mappings(buffer)
	local keymap = settings.keymap

	key.nmap({
		keymap["buffer.next"],
		fn.bind(self.next, self),
		buffer = buffer,
	}, {
		keymap["buffer.prev"],
		fn.bind(self.prev, self),
		buffer = buffer,
	})

	return true
end

---@type fun(self: Finder.Picker.Tabs, options?: { initial_mode: "normal" | "insert" })
Tabs._options = validator.f.arguments({
	validator.f.instance_of(Tabs),
	validator.f.optional(validator.f.shape({ initial_mode = validator.f.one_of({ "normal", "insert" }) })),
}) .. function(self, options)
	options = options or {}

	return vim.tbl_extend("force", options, {
		prompt_title = self:_prompt_title(),
		attach_mappings = fn.bind(self._attach_mappings, self),
	})
end

function Tabs:prev()
	self._current = self._current <= 1 and #self or self._current - 1

	local options = self:_options({ initial_mode = "normal" })
	local picker = self[self._current]

	return picker.find(options)
end

function Tabs:next()
	self._current = self._current >= #self and 1 or self._current + 1

	local options = self:_options({ initial_mode = "normal" })
	local picker = self[self._current]

	return picker.find(options)
end

function Tabs:find()
	local options = self:_options({ initial_mode = "normal" })
	local picker = self[self._current]

	return picker.find(options)
end

function Tabs:append(picker)
	table.insert(self, 1, picker)

	if self._current == 1 then
		self._current = self[2] and 2 or 1
	end
end

function Tabs:prepend(picker)
	table.insert(self, picker)

	if self._current == #self then
		self._current = self[#self - 1] and #self - 1 or #self
	end
end

-- function Tabs:remove(picker) end

local Picker = Module:extend({
	plugins = {
		{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		{ "nvim-telescope/telescope-project.nvim", dependencies = { "nvim-telescope/telescope.nvim" } },
		{
			"folke/todo-comments.nvim",
			dependencies = "nvim-lua/plenary.nvim",
		},
	},
})

function Picker:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

function Picker:_setup_keymaps()
	local keymap = settings.keymap

	key.nmap(
		{ keymap["find.files"], fn.bind(self.files, self) },
		{ keymap["find.projects"], fn.bind(self.projects, self) },
		{ keymap["find.search.buffer"], fn.bind(self.buffer_text, self) },
		{ keymap["find.search.directory"], fn.bind(self.text, self) },
		{ keymap["find.help"], fn.bind(self.help, self) },
		{ keymap["find.spelling"], fn.bind(self.spelling, self) },
		{ keymap["find.buffers"], fn.bind(self.buffers, self) },
		{ keymap["find.todos"], fn.bind(self.todos, self) }
	)
end

function Picker:_setup_plugins()
	local keymap = settings.keymap

	require("telescope").setup({
		defaults = {
			sorting_strategy = "ascending",
			dynamic_preview_title = true,
			layout_strategy = "flex",
			layout_config = {
				prompt_position = "top",
			},
			color_devicons = true,
			results_title = "",
			borderchars = {
				{ "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				prompt = { "─", "│", "─", "│", "┌", "┐", "┤", "├" },
				results = { " ", "│", "─", "│", "│", "│", "┘", "└" },
				preview = { "─", "│", "─", " ", "─", "┐", "┘", "─" },
			},
			mappings = {
				i = {
					[keymap["window.cursor.down"]] = require("telescope.actions").move_selection_next,
					[keymap["window.cursor.up"]] = require("telescope.actions").move_selection_previous,
					[keymap["window.cursor.left"]] = require("telescope.actions").cycle_history_prev,
					[keymap["window.cursor.right"]] = require("telescope.actions").cycle_history_next,
				},
				n = {},
			},
		},
		pickers = {
			find_files = {},
			current_buffer_fuzzy_find = {
				-- ordering results by line number
				tiebreak = function(current_entry, existing_entry)
					-- returning true means preferring current entry
					return current_entry.lnum < existing_entry.lnum
				end,
			},
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

---comment
---@param pickers any
---@return Finder.Picker.Tabs
function Picker:tabs(pickers)
	return Tabs:new(pickers)
end

function Picker:files()
	require("telescope.builtin").find_files()
end

---@type fun(self: Picker, directory: string | nil)
Picker.text = validator.f.arguments({ validator.f.instance_of(Picker), validator.f.optional("string") })
	.. function(_, directory)
		local root = vim.loop.cwd()
		local searchDirectory = directory or root
		local rootRelativeCwd = root == searchDirectory and "/" or string.gsub(searchDirectory, root, "")
		local options = {
			cwd = searchDirectory,
			prompt_title = "Search in " .. rootRelativeCwd,
		}

		require("telescope.builtin").live_grep(options)
	end

function Picker:buffer_text()
	require("telescope.builtin").current_buffer_fuzzy_find()
end

function Picker:buffers()
	require("telescope.builtin").buffers()
end

function Picker:help()
	return self:tabs({
		{ prompt_title = "Help", find = require("telescope.builtin").help_tags },
		{ prompt_title = "Commands", find = require("telescope.builtin").commands },
		{ prompt_title = "Options", find = require("telescope.builtin").vim_options },
		{ prompt_title = "Autocommands", find = require("telescope.builtin").autocommands },
		{ prompt_title = "Keymaps", find = require("telescope.builtin").keymaps },
		{ prompt_title = "Filetypes", find = require("telescope.builtin").filetypes },
		{ prompt_title = "Highlights", find = require("telescope.builtin").highlights },
	}):find()
end

function Picker:projects()
	require("telescope").extensions.project.project({ display_type = "full" })
end

function Picker:todos()
	key.input(":TodoTelescope<CR>")
end

function Picker:qflist()
	require("telescope.builtin").quickfix()
end

function Picker:loclist()
	require("telescope.builtin").loclist()
end

function Picker:commands()
	require("telescope.builtin").commands()
end

function Picker:find_diagnostics()
	require("telescope.builtin").diagnostics()
end

function Picker:spelling()
	require("telescope.builtin").spell_suggest()
end

---@type fun(self: Picker, menu: { [number]: string, on_select: function }, options: { prompt_title: string } | nil)
Picker.menu = validator.f.arguments({
	validator.f.instance_of(Picker),
	validator.f.shape({
		validator.f.list({ "string", validator.f.optional("string") }),
		on_select = "function",
	}),
	validator.f.optional(validator.f.shape({
		prompt_title = "string",
	})),
}) .. function(_, menu, options)
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

---@type fun(self: Picker, menu: { [number]: string, on_select: function }, options: { prompt_title: string } | nil)
function Picker:context_menu(menu, options)
	local theme = require("telescope.themes").get_cursor()
	options = vim.tbl_extend("force", theme, options or {})

	return self:menu(menu, options)
end

return Picker:new()
