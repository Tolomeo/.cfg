local Module = require("_shared.module")
local bf = require("_shared.buffer")
local fn = require("_shared.fn")
local arr = require("_shared.array")
local tb = require("_shared.tab")
local key = require("_shared.key")
local settings = require("settings")

local Terminal = Module:extend({
	plugins = {
		{ "samjwill/nvim-unception" },
	},
})

function Terminal:setup()
	local keymap = settings.keymap
	local config = settings.config

	-- TODO: grab from config
	local shell = vim.api.nvim_get_option("shell")

	-- Exiting term mode using double esc
	-- to avoid interfering with TUIs keymaps
	key.tmap({ "<Esc><Esc>", "<C-\\><C-n>" })

	key.nmap({
		keymap["terminal.next"],
		fn.bind(self.next, self, shell),
	}, {
		keymap["terminal.prev"],
		fn.bind(self.prev, self, shell),
	}, {
		keymap["terminal.open"],
		fn.bind(self.toggle, self, shell),
	}, {
		keymap["terminal.menu"],
		fn.bind(self.menu, self),
	})

	arr.each(config["terminal.jobs"], function(user_job)
		if not user_job.keymap then
			return
		end

		key.nmap({
			user_job.keymap,
			function()
				self:toggle(user_job.command)
			end,
		})
	end)
end

function Terminal:create(cmd)
	return vim.api.nvim_command(string.format("terminal %s", cmd))
end

function Terminal:toggle(cmd)
	-- `term://{cwd}//{pid}:{cmd}`
	local cmd_buffer = arr.find(bf.get_listed(), function(buffer)
		return string.match(buffer.name, "^term://.+//%d+:" .. cmd .. "$")
	end)

	if not cmd_buffer then
		return self:create(cmd)
	end

	local current_buffer = bf.get_current()

	if cmd_buffer.handle == current_buffer.handle then
		vim.fn.execute("buffer#")
		return
	end

	local displayed_cmd = arr.find(tb.get_windows({ 0 }), function(window)
		return window.buffer == cmd_buffer.handle
	end)

	if displayed_cmd then
		vim.api.nvim_set_current_win(displayed_cmd.winnr)
		return
	end

	return vim.api.nvim_command(string.format("buffer %s", cmd_buffer.handle))
end

function Terminal:next(cmd)
	-- `term://{cwd}//{pid}:{cmd}`
	local buffers = bf.get_listed()
	local term_buffers = arr.filter(buffers, function(buffer)
		return string.match(buffer.name, "^term://.+//%d+:" .. cmd .. "$")
	end)

	if #term_buffers < 2 then
		return
	end

	local current_buffer = bf.get_current()
	local current_buffer_index = arr.find_index(buffers, function(buffer)
		return buffer.handle == current_buffer.handle
	end)
	local buffers_rotation = fn.tail(arr.rotateRight(buffers, current_buffer_index))
	local next_buffer = arr.find(buffers_rotation, function(buffer)
		return string.match(buffer.name, "^term://.+//%d+:" .. cmd .. "$")
	end)

	if not next_buffer then
		return
	end

	return vim.api.nvim_command(string.format("buffer %s", next_buffer.handle))
end

function Terminal:prev(cmd)
	local buffers = bf.get_listed()
	local term_buffers = arr.filter(buffers, function(buffer)
		return string.match(buffer.name, "^term://.+//%d+:" .. cmd .. "$")
	end)

	if #term_buffers < 2 then
		return
	end

	buffers = fn.reverse(buffers)
	local current_buffer = bf.get_current()
	local current_buffer_index = arr.find_index(buffers, function(buffer)
		return buffer.handle == current_buffer.handle
	end)
	local buffers_rotation = fn.tail(arr.rotateRight(buffers, current_buffer_index))
	local next_buffer = arr.find(buffers_rotation, function(buffer)
		return string.match(buffer.name, "^term://.+//%d+:" .. cmd .. "$")
	end)

	if not next_buffer then
		return
	end

	return vim.api.nvim_command(string.format("buffer %s", next_buffer.handle))
end

function Terminal:get_actions()
	local keymap = settings.keymap
	local config = settings.config

	-- TODO: grab from config
	local shell = vim.api.nvim_get_option("shell")

	return {
		{
			name = "Create a new terminal",
			command = ":term[inal]",
			handler = fn.bind(self.create, self, shell),
		},
		{
			name = "Next terminal",
			keymap = keymap["terminal.next"],
			handler = fn.bind(self.next, self),
		},
		{
			name = "Previous terminal",
			keymap = keymap["terminal.prev"],
			handler = fn.bind(self.prev, self),
		},
		{
			name = "Launch ...",
			command = ":terminal ...",
			handler = function()
				local command = vim.fn.input({ prompt = "> ", cancelreturn = "", completion = "shellcmd" })
				self:create(command)
			end,
		},
		unpack(arr.map(config["terminal.jobs"], function(user_job)
			return {
				name = "Launch " .. user_job.command,
				command = ":terminal " .. user_job.command,
				keymap = user_job.keymap,
				handler = function()
					self:toggle(user_job.command)
				end,
			}
		end)),
	}
end

function Terminal:menu(options)
	options = options or {}
	options = vim.tbl_extend("force", { prompt_title = "Terminal actions" }, options)

	local menu = {}

	local actions = self:get_actions()
	arr.push(
		menu,
		unpack(arr.map(actions, function(action)
			return {
				action.name,
				fn.trim(table.concat({ action.keymap or "", action.command or "" }, " ")),
				handler = action.handler,
			}
		end))
	)

	menu.on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		modal_menu.actions.close(modal_menu.buffer)
		selection.value.handler()
	end

	require("integration.finder"):create_menu(menu, options)
end

return Terminal:new()
