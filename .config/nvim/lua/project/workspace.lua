local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local fs = require("_shared.fs")
local bf = require("_shared.buffer")
local tb = require("_shared.tab")
local pt = require("_shared.path")
local settings = require("settings")
local str = require("_shared.str")

local Workspace = Module:extend({})

function Workspace:setup()
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
		"TabNewEntered",
		"*",
		function()
			print("tab new entered")
		end,
	}, {
		{ "BufNew" },
		"*",
		fn.bind(self.on_buf_new, self),
	}, {
		"TermOpen",
		"*",
		fn.bind(self.on_term_open, self),
	}, {
		"BufNewFile",
		"*",
		function()
			vim.print("buf new file")
		end,
	})
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
	local tab = self:create_tab(cwd, vim.api.nvim_get_current_tabpage())
	local dashboard = self:create_dashboard(tab, bf.find_by_name(""))

	self:create(cwd, tab, dashboard)

	local directory_args = fn.imap(
		fn.ifilter(args, function(arg)
			return fs.statSync(arg).type == "directory"
		end),
		function(dir_arg)
			return vim.fn.fnamemodify(dir_arg, ":p")
		end
	)
	local buffer_args = fn.imap(
		fn.ifilter(args, function(arg)
			return fs.statSync(arg).type == "file"
		end),
		function(buf_arg)
			return vim.fn.fnamemodify(buf_arg, ":p")
		end
	)

	fn.ieach(directory_args, function(directory_path)
		self:create(directory_path)
		bf.delete({ bf.get_id_by_name({ directory_path }), force = true })
	end)

	fn.ieach(buffer_args, function(buffer_path)
		local dir_path = pt.dirname({ buffer_path })
		local root = self:find_root(dir_path, cwd)

		local buffer_workspaces = self:get_by_root(root)

		if not next(buffer_workspaces) then
			self:create(root)
			buffer_workspaces = self:get_by_root(root)
		end

		bf.update({
			bf.get_id_by_name({ buffer_path }),
			vars = { workspaces = fn.imap(buffer_workspaces, function(ws)
				return ws.tabpage
			end) },
		})
	end)

	self:on_tab_enter()
end

function Workspace:on_buf_new(evt)
	local buffer = bf.get({ evt.buf })

	self:buffer_to_workspace(buffer)
end

function Workspace:buffer_to_workspace(buffer)
	if bf.is_unnamed(buffer) then
		return
	end

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

	self:toggle_workspace_buffers(tab)
	tb.cd(tab.vars.workspace)
end

function Workspace:toggle_workspace_buffers(tab)
	local ws_id = tab.tabpage
	local ws_buffers = fn.ifilter(bf.get_all({ vars = { "workspaces" } }), function(buffer)
		return buffer.vars.workspaces ~= nil
	end)

	fn.ieach(ws_buffers, function(buffer)
		local buflisted = fn.ifind(buffer.vars.workspaces, function(ws)
			return ws == ws_id
		end) ~= nil

		bf.update({ buffer.bufnr, options = { buflisted = buflisted } })
	end)
end

function Workspace:create(root, tab, dashboard)
	tab = tab and tab or self:create_tab(root)
	dashboard = dashboard and dashboard or self:create_dashboard(tab, bf.find_by_name(""))

	return root, tab, dashboard
end

function Workspace:create_dashboard(tab, buf)
	local workspace_root = string.gsub(tb.get({ tab, vars = { "workspace" } }).vars.workspace, "/$", "")
	local workspace_name = string.format("ws:%d:%s", tab, pt.shorten({ workspace_root }))

	local config = {
		name = workspace_name,
		options = { buftype = "nofile", swapfile = false, buflisted = true },
		vars = { workspaces = { tab } },
	}

	if buf then
		config[1] = buf
		return bf.update(config)
	end

	return bf.create(config)
end

function Workspace:get_by_root(root)
	return fn.ifilter(tb.get_all({ vars = { "workspace" } }), function(ws)
		return ws.vars.workspace == root
	end)
end

function Workspace:create_tab(root, tab)
	local config = { vars = { workspace = root } }

	if tab then
		config[1] = tab
		return tb.update(config)
	end

	return tb.create(config)
end

function Workspace:find_root(dir_start, dir_stop)
	local config = settings.config

	local root_file = fs.find({ config["workspace.root"], path = dir_start, upward = true, stop = dir_stop })[1]

	if not root_file then
		return dir_stop
	end

	return pt.format({ pt.dirname({ root_file }), ":p" })
end

return Workspace:new()
