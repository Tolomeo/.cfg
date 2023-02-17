local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local settings = require("settings")
local Tabs = require("integration.finder.picker")

local pickers = setmetatable({
	projects = function()
		require("telescope").extensions.project.project({ display_type = "full" })
	end,
	live_grep = validator.f.arguments({ validator.f.optional("string") }) .. function(directory)
		local root = vim.loop.cwd()
		local searchDirectory = directory or root
		local rootRelativeCwd = root == searchDirectory and "/" or string.gsub(searchDirectory, root, "")
		local options = {
			cwd = searchDirectory,
			prompt_title = "Search in " .. rootRelativeCwd,
		}

		require("telescope.builtin").live_grep(options)
	end,
	todos = function()
		key.input(":TodoTelescope<CR>")
	end,
	help = function()
		return Tabs:new({
			{ prompt_title = "Help", find = require("telescope.builtin").help_tags },
			{ prompt_title = "Commands", find = require("telescope.builtin").commands },
			{ prompt_title = "Options", find = require("telescope.builtin").vim_options },
			{ prompt_title = "Autocommands", find = require("telescope.builtin").autocommands },
			{ prompt_title = "Keymaps", find = require("telescope.builtin").keymaps },
			{ prompt_title = "Filetypes", find = require("telescope.builtin").filetypes },
			{ prompt_title = "Highlights", find = require("telescope.builtin").highlights },
		}):find()
	end,
}, {
	__index = function(_, picker_name)
		local picker = require("telescope.builtin")[picker_name]

		if not picker then
			error(string.format("'%s' picker not found", vim.inspect(picker_name)))
		end

		return picker
	end,
})

local Finder = Module:extend({
	plugins = {
		{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		{ "nvim-telescope/telescope-project.nvim", dependencies = { "nvim-telescope/telescope.nvim" } },
		{
			"folke/todo-comments.nvim",
			dependencies = "nvim-lua/plenary.nvim",
		},
	},
})

function Finder:setup()
	local keymap = settings.keymap

	require("telescope").setup({
		defaults = fn.merge(self:get_default_theme(), {
			mappings = {
				i = {
					[keymap["window.cursor.down"]] = require("telescope.actions").move_selection_next,
					[keymap["window.cursor.up"]] = require("telescope.actions").move_selection_previous,
					[keymap["window.cursor.left"]] = require("telescope.actions").cycle_history_prev,
					[keymap["window.cursor.right"]] = require("telescope.actions").cycle_history_next,
				},
				n = {},
			},
		}),
		pickers = {
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
		},
	})

	-- Todo comments
	require("todo-comments").setup({})

	key.nmap(
		{ keymap["find.files"], fn.bind(self.find, self, "find_files") },
		{ keymap["find.projects"], fn.bind(self.find, self, "projects") },
		{ keymap["find.search.buffer"], fn.bind(self.find, self, "current_buffer_fuzzy_find") },
		{ keymap["find.search.directory"], fn.bind(self.find, self, "live_grep") },
		{ keymap["find.help"], fn.bind(self.find, self, "help") },
		{ keymap["find.spelling"], fn.bind(self.find, self, "spell_suggest") },
		{ keymap["find.buffers"], fn.bind(self.find, self, "buffers") },
		{ keymap["find.todos"], fn.bind(self.find, self, "todos") }
	)
end

---@private
function Finder:get_default_theme()
	return {
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
	}
end

---@private
function Finder:get_cursor_theme()
	return require("telescope.themes").get_cursor({
		borderchars = {
			prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
			results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
			preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		},
	})
end

---@param picker_name string
---@return fun(...: unknown)
function Finder:get(picker_name)
	return pickers[picker_name]
end

function Finder:find(picker_name, ...)
	return self:get(picker_name)(...)
end

function Finder:tabs(tabs)
	return Tabs:new(tabs)
end

---@type fun(self: Picker, menu: { [number]: string, on_select: function }, options: { prompt_title: string } | nil)
Finder.menu = validator.f.arguments({
	validator.f.instance_of(Finder),
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
function Finder:context_menu(menu, options)
	options = options or {}

	return self:menu(menu, fn.merge(self:get_cursor_theme(), options))
end

return Finder:new()
