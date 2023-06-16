local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local fs = require("_shared.fs")
local bf = require("_shared.buffer")
local tb = require("_shared.tab")
local pt = require("_shared.path")
local str = require("_shared.str")
local key = require("_shared.key")
local settings = require("settings")

local Workspace = Module:extend({})

function Workspace:setup()
	local keymap = settings.keymap

	key.nmap({ keymap["tab.next"], "<Cmd>tabnext<Cr>" }, { keymap["tab.prev"], "<Cmd>tabprevious<Cr>" })

	au.group({
		"Workspace",
	}, {
		"VimEnter",
		"*",
		fn.bind(self.on_vim_enter, self),
	}, {
		"TabEnter",
		"*",
		fn.bind(self.on_tab_enter, self),
	}, {
		"TabClosed",
		"*",
		fn.bind(self.on_tab_closed, self),
	}, {
		{ "BufNew", "BufNewFile" },
		"*",
		fn.bind(self.on_buf_new, self),
	}, {
		"TermOpen",
		"*",
		fn.bind(self.on_term_open, self),
	})
end

function Workspace:on_tab_closed()
	local tabs = fn.imap(tb.get_all(), function(tab)
		return tab.tabpage
	end)
	local buffers = fn.ifilter(bf.get_all({ vars = { "workspaces" } }), function(buffer)
		return buffer.vars.workspaces ~= nil
	end)

	fn.ieach(buffers, function(buffer)
		local buffer_workspaces = fn.iintersection(buffer.vars.workspaces, tabs)

		if #buffer_workspaces < 1 then
			return bf.delete({ buffer.bufnr })
		end

		bf.update({ buffer.bufnr, vars = { workspaces = buffer_workspaces } })
	end)
end

function Workspace:get_all()
	return fn.ifilter(tb.get_all({ vars = { "workspace" } }), function(tab)
		return tab.vars.workspace ~= nil
	end)
end

function Workspace:on_term_open(evt)
	local buffer = bf.get({ evt.buf })

	self:term_to_workspace(buffer)
end

function Workspace:term_to_workspace(buffer)
	local current_ws = tb.get_current({ vars = { "workspace" } })

	bf.update({
		buffer.bufnr,
		vars = {
			workspaces = { current_ws.tabpage },
		},
	})
end

function Workspace:on_vim_enter()
	local args = vim.fn.argv()
	local cwd = vim.fn.fnamemodify(vim.loop.cwd(), ":p")
	local initial_tab = vim.api.nvim_get_current_tabpage()

	tb.update({ initial_tab, vars = { workspace = cwd } })
	bf.create({
		name = cwd,
		vars = { workspaces = { initial_tab } },
		options = { modifiable = false, readonly = true, buflisted = true },
	})

	local directory_args = fn.imap(
		fn.ifilter(args, function(arg)
			local file_stat = fs.statSync(arg)

			if not file_stat then
				return false
			end

			return file_stat.type == "directory"
		end),
		function(dir_arg)
			return vim.fn.fnamemodify(dir_arg, ":p")
		end
	)
	local file_args = fn.imap(
		fn.ifilter(args, function(arg)
			local file_stat = fs.statSync(arg)

			if not file_stat then
				return false
			end

			return file_stat.type == "file"
		end),
		function(file_arg)
			return vim.fn.fnamemodify(file_arg, ":p")
		end
	)
	--TODO: Take care of not yet existing args

	fn.ieach(directory_args, function(directory_path)
		self:create(directory_path)
	end)

	fn.ieach(file_args, function(file_path)
		self:create_from_file(file_path)
	end)

	tb.go_to(1)
	self:on_tab_enter()
end

function Workspace:create_from_file(file_path)
	local file_dir = pt.dirname({ file_path })
	local root_dir = self:find_root(file_dir)
	local workspaces = self:get_by_root(root_dir)

	if #workspaces < 1 then
		self:create(root_dir)
		workspaces = self:get_by_root(root_dir)
	end

	bf.update({
		bf.get_id_by_name({ file_path }),
		vars = { workspaces = fn.imap(workspaces, function(ws)
			return ws.tabpage
		end) },
	})
end

function Workspace:on_buf_new(evt)
	local buffer = bf.get({ evt.buf })

	if bf.is_unnamed(buffer) then
		return
	end

	local file_stat = fs.statSync(buffer.name)

	if not file_stat then
		return
	end

	fn.switch(file_stat.type)({
		file = function()
			self:on_file_buf_new(buffer)
		end,
		directory = function()
			self:on_directory_buf_new(buffer)
		end,
	})
end

function Workspace:on_directory_buf_new(buffer)
	self:create(buffer.name)
	self:on_tab_enter()
end

function Workspace:on_file_buf_new(buffer)
	local current_ws = tb.get_current({ vars = { "workspace" } })
	local buffer_workspaces = fn.imap(
		fn.ifilter(self:get_all(), function(ws)
			return str.starts_with(buffer.name, ws.vars.workspace)
		end),
		function(buf_ws)
			return buf_ws.tabpage
		end
	)

	if #buffer_workspaces < 1 then
		return
	end

	bf.update({
		buffer.bufnr,
		vars = {
			workspaces = buffer_workspaces,
		},
	})

	if fn.iincludes(buffer_workspaces, current_ws.tabpage) then
		return
	end

	tb.go_to(buffer_workspaces[1])
	self:on_tab_enter()
end

function Workspace:on_tab_enter()
	local tab = tb.get_current({ vars = { "workspace" } })

	self:display_workspace_buffers(tab)

	if not tab.vars.workspace then
		return
	end

	tb.cd(tab.vars.workspace)
end

function Workspace:display_workspace_buffers(tab)
	local ws_id = tab.tabpage
	local ws_buffers = fn.ifilter(bf.get_all({ vars = { "workspaces" } }), function(buffer)
		return buffer.vars.workspaces ~= nil
	end)

	fn.ieach(ws_buffers, function(buffer)
		bf.update({ buffer.bufnr, options = { buflisted = fn.iincludes(buffer.vars.workspaces, ws_id) } })
	end)
end

function Workspace:create(root, tab)
	if not tab then
		vim.fn.execute(string.format("tabnew %s", root))
		tab = vim.api.nvim_get_current_tabpage()
	end

	local dashboard = bf.get_id_by_name({ root })

	tb.update({ tab, vars = { workspace = root } })
	bf.update({
		dashboard,
		vars = { workspaces = { tab } },
		options = { modifiable = false, readonly = true },
	})

	return tab, dashboard
end

function Workspace:get_by_root(root)
	return fn.ifilter(tb.get_all({ vars = { "workspace" } }), function(ws)
		return ws.vars.workspace == root
	end)
end

function Workspace:find_root(dir_start, dir_stop)
	local config = settings.config

	local root_file = fs.find({ config["workspace.root"], path = dir_start, upward = true, stop = dir_stop })[1]

	if not root_file then
		return dir_start
	end

	return pt.format({ pt.dirname({ root_file }), ":p" })
end

return Workspace:new()
