local Module = require("_shared.module")
local key = require("_shared.key")

local List = {}

local default_keymaps = {
	["toggle"] = "<C-c>",
	["jump"] = "<leader>c",
	["item.next"] = "<C-]>",
	["item.prev"] = "<C-[>",
}

List.plugins = {
	"romainl/vim-qf",
}

List.setup = function()
	List._setup_keymaps()
	List._setup_plugins()
end

List._setup_keymaps = function()
	key.nmap(
		{ default_keymaps["toggle"], List.toggle },
		{ default_keymaps["jump"], List.jump },
		{ default_keymaps["item.next"], List.next },
		{ default_keymaps["item.prev"], List.prev }
	)
end

List._setup_plugins = function()
	vim.api.nvim_set_var("g:qf_save_win_view", false)
	vim.api.nvim_set_var("qf_mapping_ack_style", true)
end

local function toggle_location_list()
	key.input("<Plug>(qf_loc_toggle)", "m")
end

local function next_location()
	key.input("<Plug>(qf_loc_next)", "m")
end

local function prev_location()
	key.input("<Plug>(qf_loc_previous)", "m")
end

local function toggle_quickfix_list()
	key.input("<Plug>(qf_qf_toggle)", "m")
end

local function next_quickfix()
	key.input("<Plug>(qf_qf_next)", "m")
end

local function prev_quickfix()
	key.input("<Plug>(qf_qf_previous)", "m")
end

--[[ local function next_quickfix_group()
	key.input("<Plug>(qf_qf_next_file)", "m")
end

local function prev_quickfix_group()
	key.input("<Plug>(qf_qf_previous_file)", "m")
end ]]

local function is_quickfix_window_open()
	return vim.fn["qf#IsQfWindowOpen"]() ~= 0
end

function List.toggle()
	if is_quickfix_window_open() then
		return toggle_quickfix_list()
	end

	return toggle_location_list()
end

function List.next()
	if is_quickfix_window_open() then
		return next_quickfix()
	end

	return next_location()
end

function List.prev()
	if is_quickfix_window_open() then
		return prev_quickfix()
	end

	return prev_location()
end

function List.jump()
	key.input("<Plug>(qf_qf_switch)", "m")
end

return Module:new(List)
