local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local fs = require("_shared.fs")
local bf = require("_shared.buffer")
local tb = require("_shared.tab")
local settings = require("settings")

local Workspace = Module:extend({
	plugins = {
		{ "https://github.com/backdround/tabscope.nvim" },
	},
	list = {},
})

function Workspace:setup()
	-- require("tabscope").setup({})

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
		bf.delete({ bf.get_by_name({ directory_path }), force = true })
	end)

	fn.ieach(buffer_args, function(buffer_path)
		local dir_path = vim.fs.dirname(buffer_path)
		local root = self:find_root(dir_path, cwd)

		local buffer_workspaces = self:get_by_root(root)

		if not next(buffer_workspaces) then
			self:create(root)
			buffer_workspaces = self:get_by_root(root)
		end

		bf.update({ bf.get_by_name({ buffer_path }), vars = { workspaces = fn.keys(buffer_workspaces) } })
	end)

	self:on_tab_enter()
end

function Workspace:on_tab_enter()
	vim.schedule(function()
		local tab = tostring(vim.api.nvim_get_current_tabpage())
		local buffers = bf.get_buffers({ vars = { "workspaces" } })

		fn.ieach(buffers, function(buffer)
			if buffer.vars.workspaces == nil then
				return
			end

			local buflisted = fn.ifind(buffer.vars.workspaces, function(ws)
				return ws == tab
			end) ~= nil

			bf.update({ buffer.bufnr, options = { buflisted = buflisted } })
		end)
	end)
end

function Workspace:create(root, tab, dashboard)
	tab = tab and tab or self:create_tab(root)
	dashboard = dashboard and dashboard or self:create_dashboard(tab, bf.find_by_name(""))

	self.list[tostring(tab)] = { root = root, dashboard = dashboard }

	return self.list[tab], tab
end

function Workspace:create_dashboard(tab, buf)
	local config = {
		name = string.format("ws:%d", tab),
		options = { buftype = "nofile", swapfile = false, buflisted = true },
		vars = { workspaces = { tostring(tab) } },
	}

	if buf then
		config[1] = buf
		return bf.update(config)
	end

	return bf.create(config)
end

function Workspace:get_by_root(root)
	return fn.kfilter(self.list, function(workspace)
		return workspace.root == root
	end)
end

function Workspace:create_tab(root, tab)
	local config = { vars = { workspace = root } }

	if tab then
		return tb.update(tab, config)
	end

	return tb.create(config)
end

function Workspace:find_root(dir_start, dir_stop)
	local config = settings.config

	local root_file = vim.fs.find(config["workspace.root"], { path = dir_start, upward = true, stop = dir_stop })[1]

	if not root_file then
		return dir_stop
	end

	return vim.fn.fnamemodify(vim.fs.dirname(root_file), ":p")
end

return Workspace:new()
