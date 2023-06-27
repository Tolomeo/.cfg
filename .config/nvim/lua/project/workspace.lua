local Module = require("_shared.module")
local au = require("_shared.au")
local ar = require("_shared.args")
local fn = require("_shared.fn")
local fs = require("_shared.fs")
local bf = require("_shared.buffer")
local tb = require("_shared.tab")
local pt = require("_shared.path")
local str = require("_shared.str")
local settings = require("settings")

local nvim_cwd = pt.format({ vim.loop.cwd(), ":p" })

local Workspace = Module:extend({})

function Workspace:setup()
	au.group({
		"Workspace",
	}, {
		"VimEnter",
		"*",
		fn.bind(self.on_vim_enter, self),
	}, {
		"TabNewEntered",
		"*",
		fn.bind(self.on_tab_new_entered, self),
	}, {
		"TabEnter",
		"*",
		fn.bind(self.on_tab_enter, self),
	}, {
		"TabLeave",
		"*",
		fn.bind(self.on_tab_leave, self),
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

function Workspace:on_vim_enter()
	local arglist = ar.arglist()
	local p = ar.find({ "-p" }) ~= nil
	local initial_tab = tb.current()

	self:create(nvim_cwd, initial_tab)

	--TODO: Take care of not yet existing args

	if p then
		fn.ieach(tb.list(), function(tab_handle)
			local buffer = bf.get({ tb.buffer(tab_handle) })

			if buffer.name == "" then
				return
			end

			local file_stat = fs.statSync(buffer.name)

			if not file_stat then
				return
			end

			fn.switch(file_stat.type)({
				directory = function()
					self:create(buffer.name, tab_handle)
				end,
				file = function()
					self:create(self:find_buffer_root(buffer.name), tab_handle)
				end,
			})
		end)
	else
		fn.ireduce(arglist, function(_workspaces, arg)
			local file_stat = fs.statSync(arg)

			if not file_stat then
				return
			end

			local _, root = fn.switch(file_stat.type)({
				directory = function()
					return arg
				end,
				file = function()
					return self:find_buffer_root(arg)
				end,
			})

			if root and not _workspaces[root] then
				_workspaces[root] = self:create(root)
			end

			return _workspaces
		end, { [nvim_cwd] = initial_tab })
	end

	fn.ieach(arglist, function(arg)
		local file_stat = fs.statSync(arg)

		if not file_stat then
			return
		end

		if file_stat.type == "file" then
			self:update_buffer_workspaces(arg)
		end
	end)

	tb.go_to(1)
	self:on_tab_enter()
end

function Workspace:on_tab_new_entered(evt)
	local file = evt.file
	local tab = tb.current()

	if file == "" then
		self:create(nvim_cwd, tab)
		self:on_tab_enter()
		return
	end

	local file_stat = fs.statSync(file)

	if not file_stat then
		return
	end

	fn.switch(file_stat.type)({
		file = function()
			self:create_from_file(file, tab)
		end,
		directory = function()
			self:create(file, tab)
		end,
	})

	self:on_tab_enter()
end

function Workspace:on_tab_enter()
	local current_ws = self:get_current()

	if not current_ws then
		return self:hide_buffers()
	end

	self:toggle_buffers(current_ws)
	tb.cd(current_ws.vars.workspace)
end

function Workspace:on_tab_leave()
	local leaving_ws = self:get_current()

	if not leaving_ws then
		return
	end

	au.command({
		"TabEnter",
		"*",
		function()
			local ws = self:get(leaving_ws.handle)

			if not ws then
				self:on_ws_closed(leaving_ws)
			end
		end,
		once = true,
	})
end

function Workspace:on_ws_closed(closed_ws)
	local ws_buffers = self:get_buffers_by_ws(closed_ws.handle)
	local ws_buffers_deletion_failed = fn.ireduce(ws_buffers, function(_cancelled, buffer)
		local buffer_workspaces = fn.ifilter(buffer.vars.workspaces, function(buffer_workspace)
			return buffer_workspace ~= closed_ws.handle
		end)

		if next(buffer_workspaces) then
			bf.update({ buffer.handle, vars = { workspaces = buffer_workspaces } })
			return _cancelled
		end

		local buffer_deletion_success = pcall(bf.delete, { buffer.handle })

		if buffer_deletion_success then
			return _cancelled
		end

		table.insert(_cancelled, buffer)
		return _cancelled
	end, {})

	if not next(ws_buffers_deletion_failed) then
		return
	end

	local ws_tab = self:create(closed_ws.vars.workspace)

	fn.ieach(ws_buffers_deletion_failed, function(buffer)
		bf.update({ buffer.handle, vars = { workspaces = { ws_tab } } })
	end)

	self:on_tab_enter()
end

function Workspace:on_buf_new(evt)
	local buffer = bf.get({ evt.buf })

	if buffer.name == "" then
		return
	end

	local current_ws = self:get_current()

	if not current_ws then
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
	--TODO: what happens when I open a file in a tab that is not a workspace?
	--TODO: replace with self:get_current()
	local current_ws = tb.get_current({ vars = { "workspace" } })
	local buffer_workspaces = fn.imap(
		fn.ifilter(self:get_all(), function(ws)
			return str.starts_with(buffer.name, ws.vars.workspace)
		end),
		function(buf_ws)
			return buf_ws.handle
		end
	)

	if not next(buffer_workspaces) then
		return
	end

	bf.update({
		buffer.handle,
		vars = {
			workspaces = buffer_workspaces,
		},
	})

	--TODO: find the best match to open the buffer in (closest ws root)
	if fn.iincludes(buffer_workspaces, current_ws.handle) then
		return
	end

	tb.go_to(buffer_workspaces[1])
	self:on_tab_enter()
end

function Workspace:on_term_open(evt)
	local current_ws = self:get_current()

	if not current_ws then
		return
	end

	bf.update({
		evt.buf,
		vars = {
			workspaces = { current_ws.handle },
		},
	})
end

function Workspace:create(root, tab)
	root = pt.format({ root, ":p" })
	local root_name = string.gsub(root, "/$", "")

	if not tab then
		tab = tb.create({ root })
	end

	local dashboard = bf.get_handle_by_name({ root_name })

	if not dashboard then
		dashboard = bf.create({ name = root_name })
	end

	tb.update({ tab, vars = { workspace = root } })
	require("interface.line"):set_tab_name(tab, pt.shorten({ root_name }))

	local dashboard_buffer = bf.get({ dashboard, vars = { "workspaces" } })
	local dashboard_workspaces = fn.iunion((dashboard_buffer.vars.workspaces or {}), { tab })

	bf.update({
		dashboard_buffer.handle,
		vars = { workspaces = dashboard_workspaces },
		options = { modifiable = false, readonly = true, swapfile = false },
	})

	return tab, dashboard
end

function Workspace:create_from_file(file_path, tab)
	local root_dir = self:find_buffer_root(file_path)

	self:create(root_dir, tab)
	self:update_buffer_workspaces(file_path)
end

function Workspace:get_all()
	return fn.ifilter(tb.get_list({ vars = { "workspace" } }), function(tab)
		return tab.vars.workspace ~= nil
	end)
end

function Workspace:get_current()
	local current_tab = tb.get_current({ vars = { "workspace" } })

	if not current_tab.vars.workspace then
		return nil
	end

	return current_tab
end

function Workspace:get(ws_handle)
	return fn.ifind(self:get_all(), function(ws)
		return ws.handle == ws_handle
	end)
end

function Workspace:get_by_root(root)
	return fn.ifilter(self:get_all(), function(ws)
		return ws.vars.workspace == root
	end)
end

function Workspace:get_buffers()
	return fn.ifilter(bf.get_all({ vars = { "workspaces" } }), function(buffer)
		return buffer.vars.workspaces ~= nil
	end)
end

function Workspace:get_buffers_by_ws(ws_handle)
	return fn.ifilter(self:get_buffers(), function(buffer)
		return fn.iincludes(buffer.vars.workspaces, ws_handle)
	end)
end

function Workspace:toggle_buffers(ws)
	local ws_buffers = self:get_buffers()

	fn.ieach(ws_buffers, function(buffer)
		bf.update({ buffer.handle, options = { buflisted = fn.iincludes(buffer.vars.workspaces, ws.handle) } })
	end)
end

function Workspace:hide_buffers()
	local ws_buffers = self:get_buffers()

	fn.ieach(ws_buffers, function(buffer)
		bf.update({ buffer.handle, options = { buflisted = false } })
	end)
end

function Workspace:find_buffer_root(file_path)
	local path_start = pt.dirname({ file_path })
	local config = settings.config

	local root_file = fs.find({ config["workspace.root"], path = path_start, upward = true })[1]

	if not root_file then
		return path_start
	end

	return pt.format({ pt.dirname({ root_file }), ":p" })
end

function Workspace:update_buffer_workspaces(file_path)
	local buffer_handle = bf.get_handle_by_name({ file_path })
	local buffer_workspaces = fn.ireduce(self:get_all(), function(_buffer_workspaces, ws)
		if str.starts_with(file_path, ws.vars.workspace) then
			table.insert(_buffer_workspaces, ws.handle)
		end

		return _buffer_workspaces
	end, {})

	bf.update({
		buffer_handle,
		vars = { workspaces = buffer_workspaces },
	})
end

return Workspace:new()
