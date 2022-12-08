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

List._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["list.open"], List.open },
		{ keymaps["list.close"], List.close },
		{ keymaps["list.item.next"], List.next },
		{ keymaps["list.item.prev"], List.prev }
	)

	au.group({
		"OnListFileType",
		{
			{
				"FileType",
				"qf",
				function(autocmd)
					local buffer = autocmd.buf
					local open = require("qf_helper").open_split
					local navigate = require("qf_helper").navigate

					key.nmap({ keymaps["list.item.open.tab"], "<C-W><CR><C-W>T", buffer = buffer })
					key.nmap({ keymaps["list.item.open.vertical"], fn.bind(open, "vsplit"), buffer = buffer })
					key.nmap({ keymaps["list.item.open.horizontal"], fn.bind(open, "split"), buffer = buffer })
					key.nmap({ keymaps["list.item.preview"], "<CR><C-W>p", buffer = buffer })
					key.nmap({ keymaps["list.item.preview.prev"], "k<CR><C-W>p", buffer = buffer })
					key.nmap({ keymaps["list.item.preview.next"], "j<CR><C-W>p", buffer = buffer })
					key.nmap({ keymaps["list.item.first"], fn.bind(navigate, -1, { by_file = true }), buffer = buffer })
					key.nmap({ keymaps["list.item.last"], fn.bind(navigate, 1, { by_file = true }), buffer = buffer })
				end,
			},
		},
	})
end

List._setup_plugins = function()
	require("pqf").setup()
	require("qf_helper").setup({
		quickfix = {
			default_bindings = false,
		},
		loclist = {
			default_bindings = false,
		},
	})
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
	vim.fn.setloclist({})
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

return Module:new(List)
