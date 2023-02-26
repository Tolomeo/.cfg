local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local logger = require("_shared.logger")
local settings = require("settings")
local jobs = require("integration.terminal._jobs")

local Terminal = Module:extend({
	plugins = {
		{ "samjwill/nvim-unception" },
	},
})

function Terminal:setup()
	local keymap = settings.keymap
	local config = settings.config

	-- Exiting term mode using double esc
	-- to avoid interfering with TUIs keymaps
	key.tmap({ "<Esc><Esc>", "<C-\\><C-n>" })

	key.nmap({
		keymap["terminal.next"],
		fn.bind(self.next, self),
	}, {
		keymap["terminal.prev"],
		fn.bind(self.prev, self),
	}, {
		keymap["terminal.open"],
		fn.bind(self.toggle, self),
	}, {
		keymap["terminal.menu"],
		fn.bind(self.menu, self),
	})

	for _, user_job in ipairs(config["terminal.jobs"]) do
		if not user_job.keymap then
			goto continue
		end

		key.nmap({
			user_job.keymap,
			fn.bind(self.toggle_command, self, user_job.command),
		})

		::continue::
	end
end

function Terminal:toggle_command(cmd)
	local job, job_index = jobs:find_by_cmd(cmd)

	if not job then
		return self:create(cmd)
	end

	local windows = vim.fn.getwininfo()
	local displayed_job = fn.ifind(windows, function(window)
		return window.bufnr == job.buffer
	end)

	if displayed_job then
		return vim.api.nvim_set_current_win(displayed_job.winid)
	end

	return self:show(job_index)
end

function Terminal:toggle()
	local jobs_count = jobs:count()

	if jobs_count < 1 then
		return self:create()
	end

	local current_buffer_job = jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if current_buffer_job then
		return self:menu()
	end

	local windows = vim.fn.getwininfo()
	local job_window = fn.ifind(windows, function(window)
		return jobs:find_index_by_buffer(window.bufnr)
	end)

	if job_window then
		return vim.api.nvim_set_current_win(job_window.winid)
	end

	self:show()
end

function Terminal:show(job_index)
	local current_job, current_job_index = jobs:current(job_index)
	local count = jobs:count()

	if not current_job then
		return
	end

	vim.api.nvim_command("buffer " .. current_job.buffer)
	print(string.format("Job %d/%d", current_job_index, count))
end

function Terminal:create(command)
	if command then
		return vim.api.nvim_command("terminal " .. command)
	end

	return vim.api.nvim_command("terminal")
end

function Terminal:next()
	local jobs_count = jobs:count()

	if jobs_count < 1 then
		return
	end

	local current_buffer_job_index = jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if not current_buffer_job_index then
		return self:show()
	end

	jobs:next(current_buffer_job_index)
	self:show()
end

function Terminal:prev()
	local jobs_count = jobs:count()

	if jobs_count < 1 then
		return
	end

	local current_buffer_job_index = jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if not current_buffer_job_index then
		return self:show()
	end

	jobs:prev(current_buffer_job_index)
	self:show()
end

function Terminal:get_actions()
	local keymap = settings.keymap
	local config = settings.config

	return {
		{
			name = "Create a new terminal",
			command = ":term[inal]",
			handler = fn.bind(self.create, self),
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
		unpack(fn.imap(config["terminal.jobs"], function(user_job)
			return {
				name = "Launch " .. user_job.command,
				command = ":terminal " .. user_job.command,
				keymap = user_job.keymap,
				handler = fn.bind(self.toggle_command, self, user_job.command),
			}
		end)),
	}
end

function Terminal:menu(options)
	options = options or {}
	options = vim.tbl_extend("force", { prompt_title = "Terminal actions" }, options)

	local menu = {}
	local jobs_count = jobs:count()

	if jobs_count > 0 then
		fn.push(menu, {
			jobs_count .. " job" .. (jobs_count > 1 and "s" or "") .. " running",
			handler = fn.bind(self.jobs_menu, self),
		})
	end

	local actions = self:get_actions()
	fn.push(
		menu,
		unpack(fn.imap(actions, function(action)
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

function Terminal:jobs_menu(options)
	local jobs_count = jobs:count()

	if jobs_count < 1 then
		return logger.info("No jobs running at the minute")
	end

	options = options or {}
	options = vim.tbl_extend("force", {
		prompt_title = "Running jobs",
		previewer = require("telescope.previewers").new_buffer_previewer({
			define_preview = function(previewer, entry)
				local job_buffer = entry.value.job.buffer
				local job_lines = vim.api.nvim_buf_get_lines(job_buffer, 0, -1, false)
				local preview_lines = fn.slice(
					job_lines,
					1,
					fn.find_last_index(job_lines, function(line)
						return line ~= ""
					end)
				)
				local preview_buffer = previewer.state.bufnr
				local preview_window = previewer.state.winid

				vim.api.nvim_buf_set_lines(preview_buffer, 0, 0, false, preview_lines)
				vim.schedule(function()
					vim.api.nvim_win_set_cursor(preview_window, { #preview_lines, 0 })
				end)
			end,
		}),
	}, options)

	local menu = fn.imap(jobs, function(registerd_job, registerd_job_index)
		return {
			registerd_job.file,
			job = registerd_job,
			job_index = registerd_job_index,
		}
	end)
	menu.on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		modal_menu.actions.close(modal_menu.buffer)
		jobs:current(selection.value.job_index)
		self:show()
	end

	require("integration.finder"):create_menu(menu, options)
end

return Terminal:new()
