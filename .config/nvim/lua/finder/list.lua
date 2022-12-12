local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local validator = require("_shared.validator")
local key = require("_shared.key")
local settings = require("settings")

---@class Finder.List
local List = {}

List.plugins = {
	"stevearc/qf_helper.nvim",
	"https://gitlab.com/yorickpeterse/nvim-pqf.git",
}

function List:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

---@type fun(self: Finder.List, mode?: "n" | "v" | "V"): table
List.actions = validator.f.arguments({
	validator.f.equal(List),
	validator.f.optional(validator.f.one_of({ "n", "v", "V" })),
})
	.. function(self, mode)
		local keymaps = settings.keymaps()
		local open = require("qf_helper").open_split
		local navigate = require("qf_helper").navigate

		local actions = {
			n = {
				{
					name = "Open item in new tab",
					keymap = keymaps["list.item.open.tab"],
					handler = fn.bind(key.input, "<C-W><CR><C-W>T"),
				},
				{
					name = "Open item in vertical split",
					keymap = keymaps["list.item.open.vertical"],
					handler = fn.bind(open, "vsplit"),
				},
				{
					name = "Open entry in horizontal split",
					keymap = keymaps["list.item.open.horizontal"],
					handler = fn.bind(open, "split"),
				},
				{
					name = "Open item preview",
					keymap = keymaps["list.item.open.preview"],
					handler = fn.bind(key.input, "<CR><C-W>p"),
				},
				{
					name = "Open previous item preview",
					keymap = keymaps["list.item.prev.open.preview"],
					handler = fn.bind(key.input, "k<CR><C-W>p"),
				},
				{
					name = "Open next item preview",
					keymap = keymaps["list.item.next.open.preview"],
					handler = fn.bind(key.input, "j<CR><C-W>p"),
				},
				-- NOTE: Navigate methods don't work properly
				-- TODO: Debug
				{
					name = "Navigate to first entry",
					keymap = keymaps["list.navigate.first"],
					handler = fn.bind(navigate, -1, { by_file = true }),
				},
				{
					name = "Navigate to last entry",
					keymap = keymaps["list.navigate.last"],
					handler = fn.bind(navigate, 1, { by_file = true }),
				},
				{
					name = "Remove item",
					keymap = keymaps["list.item.remove"],
					handler = fn.bind(vim.fn.execute, "Reject"),
				},
				{
					name = "Keep item",
					keymap = keymaps["list.item.keep"],
					handler = fn.bind(vim.fn.execute, "Keep"),
				},
				{
					name = "Search items",
					keymap = keymaps["list.search"],
					handler = function()
						local is_loclist = self:is_loclist()

						if is_loclist then
							return require("finder.picker"):loclist()
						end

						require("finder.picker"):qflist()
					end,
				},
				{
					name = "Load older list",
					keymap = keymaps["window.cursor.left"],
					handler = function()
						local is_loclist = self:is_loclist()

						if is_loclist then
							return vim.fn.execute("lolder")
						end

						vim.fn.execute("colder")
					end,
				},
				{
					name = "Load newer list",
					keymap = keymaps["window.cursor.right"],
					handler = function()
						local is_loclist = self:is_loclist()

						if is_loclist then
							return vim.fn.execute("lnewer")
						end

						vim.fn.execute("cnewer")
					end,
				},
			},
			-- NOTE: These actions don't work properly when triggered through the menu
			-- TODO: investigate why
			v = {
				{
					name = "Remove items selection",
					keymap = keymaps["list.item.remove"],
					handler = fn.bind(key.input, ":Reject<Cr>"),
				},
				{
					name = "Keep items selection",
					keymap = keymaps["list.item.keep"],
					handler = fn.bind(key.input, ":Keep<Cr>"),
				},
			},
		}

		if mode then
			-- NOTE: the mode returned by vim.api.nvim_get_mode() contains more values than those allowed for setting keymaps
			-- see :h nvim_set_keymap and :h mode()
			-- so we lowercase to transform visual line (V) into visual (v) which will work for any visual mode
			return actions[string.lower(mode)]
		end

		return actions
	end

function List:_setup_keymaps()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["list.open"], fn.bind(self.open, self) },
		{ keymaps["list.close"], fn.bind(self.close, self) },
		{ keymaps["list.next"], fn.bind(self.next, self) },
		{ keymaps["list.prev"], fn.bind(self.prev, self) }
	)

	au.group({
		"OnQFFileType",
		{
			{
				"FileType",
				"qf",
				-- TODO: refactor, we could cycle over all actions keys
				-- and automatically set keymaps
				function(autocmd)
					local buffer = autocmd.buf
					local actions = self:actions()

					for mode, mode_actions in fn.kpairs(actions) do
						local mode_keymaps = fn.imap(mode_actions, function(mode_action)
							return { mode_action.keymap, mode_action.handler, buffer = buffer }
						end)

						table.insert(mode_keymaps, {
							keymaps["dropdown.open"],
							function()
								self:actions_menu()
							end,
							buffer = buffer,
						})

						key.map(mode, unpack(mode_keymaps))
					end
				end,
			},
		},
	})
end

function List:_setup_plugins()
	require("pqf").setup()
	require("qf_helper").setup({
		prefer_loclist = true,
		quickfix = {
			default_bindings = false,
		},
		loclist = {
			default_bindings = false,
		},
	})
end

---@type fun(self: List, window: number | nil): boolean
List.is_loclist = validator.f.arguments({ validator.f.equal(List), validator.f.optional("number") })
	.. function(_, window)
		window = window or vim.api.nvim_get_current_win()
		local window_info = vim.fn.getwininfo(window)[1]

		return window_info.quickfix == 1 and window_info.loclist == 1
	end

---@type fun(self: List, window: number | nil): boolean
List.is_loclist_open = validator.f.arguments({ validator.f.equal(List), validator.f.optional("number") })
	.. function(_, window)
		window = window or 0

		return vim.fn.getloclist(window, { winid = 0 }).winid ~= 0
	end

---@type fun(self: List, window: number | nil): table
List.get_loclist = validator.f.arguments({ validator.f.equal(List), validator.f.optional("number") })
	.. function(_, window)
		window = window or 0

		return vim.fn.getloclist(window)
	end

---@param window number | nil
---@return boolean
function List:has_loclist_items(window)
	local loclist = self:get_loclist(window)
	return #loclist > 1
end

---@type fun(self: List, window: number | nil): table
List.clear_loclist = validator.f.arguments({ validator.f.equal(List), validator.f.optional("number") })
	.. function(_, window)
		window = window or 0

		vim.fn.setloclist(window, {})
	end

---@type fun(self: List, window: number | nil): table
List.is_qflist = validator.f.arguments({ validator.f.equal(List), validator.f.optional("number") })
	.. function(_, window)
		window = window or vim.api.nvim_get_current_win()
		local window_info = vim.fn.getwininfo(window)[1]

		return window_info.quickfix == 1 and window_info.loclist == 0
	end

function List:is_qflist_open()
	return vim.fn.getqflist({ winid = 0 }).winid ~= 0
end

function List:get_qflist()
	return vim.fn.getqflist()
end

function List:has_qflist_items()
	local qflist = self:get_qflist()

	return #qflist > 1
end

function List:clear_qflist()
	vim.fn.setqflist({})
end

--NOTE: since we check whether the lists contains any elements
--it becomes impossible to open a list with this method with the purpose of reaching for an older list
--TODO: create a new method catering for the use case
function List:open()
	local qf_helper = require("qf_helper")

	if self:has_loclist_items() then
		return qf_helper.open("l", { enter = true })
	elseif self:has_qflist_items() then
		return qf_helper.open("c", { enter = true })
	end
end

function List:close()
	local qf_helper = require("qf_helper")

	if self:is_loclist_open() then
		qf_helper.close("l")
		self:clear_loclist()
		return
	elseif self:is_qflist_open() then
		qf_helper.close("c")
		self:clear_qflist()
		return
	end
end

function List:next()
	vim.fn.execute("QNext")
end

function List:prev()
	vim.fn.execute("QPrev")
end

function List:actions_menu()
	local mode = vim.api.nvim_get_mode().mode
	local actions = self:actions(mode)

	if not actions then
		return
	end

	local is_loclist = self:is_loclist()
	local menu = vim.tbl_extend(
		"error",
		fn.imap(actions, function(action)
			return { action.name, action.keymap, handler = action.handler }
		end),
		{
			on_select = function(modal_menu)
				local selection = modal_menu.state.get_selected_entry()
				modal_menu.actions.close(modal_menu.buffer)
				selection.value.handler()
			end,
		}
	)
	local options = {
		prompt_title = is_loclist and "Location list" or "Quickfix list",
	}

	require("finder.picker"):context_menu(menu, options)
end

return Module:new(List)
