local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local fs = require("_shared.fs")
local settings = require("settings")

local Workspace = Module:extend({
	plugins = {
		{ "https://github.com/backdround/tabscope.nvim" },
	},
})

function Workspace:setup()
	-- require("tabscope").setup({})

	au.group({
		"OnVimEnter",
	}, {
		"VimEnter",
		"*",
		fn.bind(self.on_vim_enter, self),
	})
end

Workspace.list = {}

function Workspace:create(tab, root)
	self.list[tostring(tab)] = { root = root }
	return self.list[tab]
end

function Workspace:get_by_root(root)
	return fn.kfilter(self.list, function(workspace)
		return workspace.root == root
	end)
end

function Workspace:on_vim_enter()
	local args = vim.fn.argv()
	local cwd = vim.fn.fnamemodify(vim.loop.cwd(), ":p")

	self:create(vim.api.nvim_get_current_tabpage(), cwd)

	if #args < 1 then
		return
	end

	local directories = fn.imap(
		fn.ifilter(args, function(arg)
			local arg_type = fs.statSync(arg).type
			return arg_type == "directory" and arg ~= "."
		end),
		function(directory)
			return vim.fn.fnamemodify(directory, ":p")
		end
	)

	fn.ieach(directories, function(directory)
		vim.api.nvim_command("tabnew")
		local tab = vim.api.nvim_get_current_tabpage()
		self:create(tab, directory)
	end)

	local buffers = fn.imap(
		fn.ifilter(args, function(arg)
			local arg_type = fs.statSync(arg).type
			return arg_type == "file"
		end),
		function(buffer)
			return vim.fn.fnamemodify(buffer, ":p")
		end
	)

	fn.ieach(buffers, function(buffer)
		local root = self:find_root(buffer, cwd)

		if next(self:get_by_root(root)) then
			goto continue
		end

		vim.api.nvim_command("tabnew")
		local tab = vim.api.nvim_get_current_tabpage()
		self:create(tab, root)

		::continue::
	end)

	vim.print(self.list)
end

function Workspace:find_root(start, stop)
	start = vim.fs.dirname(start)
	local config = settings.config

	local root_file = vim.fs.find(config["workspace.root"], { path = start, upward = true, stop = stop })[1]

	if not root_file then
		return stop
	end

	return vim.fn.fnamemodify(vim.fs.dirname(root_file), ":p")
end

return Workspace:new()
