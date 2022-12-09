local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local settings = require("settings")

local List = {}

List.plugins = {
	"stevearc/qf_helper.nvim",
	"https://gitlab.com/yorickpeterse/nvim-pqf.git",
}

List.setup = function()
	List._setup_keymaps()
	List._setup_plugins()
end

List.actions = function(mode)
	mode = mode or "n"
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
				keymap = keymaps["list.item.preview"],
				handler = fn.bind(key.input, "<CR><C-W>p"),
			},
			{
				name = "Open previous item preview",
				keymap = keymaps["list.item.preview.prev"],
				handler = fn.bind(key.input, "k<CR><C-W>p"),
			},
			{
				name = "Open next item preview",
				keymap = keymaps["list.item.preview.next"],
				handler = fn.bind(key.input, "j<CR><C-W>p"),
			},
			{
				name = "Navigate to first entry",
				keymap = keymaps["list.item.first"],
				handler = fn.bind(navigate, -1, { by_file = true }),
			},
			{
				name = "Navigate to last entry",
				keymap = keymaps["list.item.first"],
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
		},
		-- NOTE: These actions don't work properly when triggered through the menu
		-- TODO: investigate why
		V = {
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

	return actions[mode]
end

List._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["list.open"], List.open },
		{ keymaps["list.close"], List.close },
		{ keymaps["list.item.next"], List.next },
		{ keymaps["list.item.prev"], List.prev }
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
					local n_actions = List.actions("n")
					local n_keymaps = fn.imap(n_actions, function(n_action)
						return { n_action.keymap, n_action.handler, buffer = buffer }
					end)
					local V_actions = List.actions("V")
					local V_keymaps = fn.imap(V_actions, function(V_action)
						return { V_action.keymap, V_action.handler, buffer = buffer }
					end)

					key.nmap(unpack(n_keymaps))
					key.nmap({
						keymaps["dropdown.open"],
						function()
							List.actions_menu()
						end,
						buffer = buffer,
					})
					key.vmap(unpack(V_keymaps))
					key.vmap({
						keymaps["dropdown.open"],
						function()
							List.actions_menu()
						end,
						buffer = buffer,
					})
				end,
			},
		},
	})
end

List._setup_plugins = function()
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

function List.is_loclist(window)
	window = window or vim.api.nvim_get_current_win()
	local window_info = vim.fn.getwininfo(window)[1]

	return window_info.quickfix == 1 and window_info.loclist == 1
end

function List.is_loclist_open(window)
	window = window or 0

	return vim.fn.getloclist(window, { winid = 0 }).winid ~= 0
end

function List.get_loclist(window)
	window = window or 0

	return vim.fn.getloclist(window)
end

function List.has_loclist_items(window)
	local loclist = List.get_loclist(window)
	return #loclist > 1
end

function List.clear_loclist(window)
	window = window or 0

	vim.fn.setloclist(window, {})
end

function List.is_qflist(window)
	window = window or vim.api.nvim_get_current_win()
	local window_info = vim.fn.getwininfo(window)[1]

	return window_info.quickfix == 1 and window_info.loclist == 0
end

function List.is_qflist_open()
	return vim.fn.getqflist({ winid = 0 }).winid ~= 0
end

function List.get_qflist()
	return vim.fn.getqflist()
end

function List.has_qflist_items()
	local qflist = List.get_qflist()

	return #qflist > 1
end

function List.clear_qflist()
	vim.fn.setqflist({})
end

function List.open()
	local qf_helper = require("qf_helper")

	if List.has_loclist_items() then
		return qf_helper.open("l", { enter = true })
	elseif List.has_qflist_items() then
		return qf_helper.open("c", { enter = true })
	end
end

function List.close()
	local qf_helper = require("qf_helper")

	if List.is_loclist_open() then
		qf_helper.close("l")
		List.clear_loclist()
		return
	elseif List.is_qflist_open() then
		qf_helper.close("c")
		List.clear_qflist()
		return
	end
end

function List.next()
	vim.fn.execute("QNext")
end

function List.prev()
	vim.fn.execute("QPrev")
end

function List.actions_menu()
	local mode = vim.api.nvim_get_mode().mode
	local actions = List.actions(mode)

	if not actions then
		return
	end

	local is_loclist = List.is_loclist()
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

	require("finder.picker").context_menu(menu, options)
end

return Module:new(List)
