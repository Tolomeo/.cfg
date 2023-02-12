local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local validator = require("_shared.validator")
local logger = require("_shared.logger")
local settings = require("settings")

---@class TerminalJob
---@field buffer number
---@field file string
local Job = {}

---@type fun(self: TerminalJob, job: { file: string, buffer: number }): TerminalJob
Job.new = validator.f.arguments({
	validator.f.equal(Job),
	validator.f.shape({
		file = "string",
		buffer = "number",
	}),
}) .. function(self, job)
	setmetatable(job, self)
	self.__index = self

	return job
end

---@class TerminalJobs
local Jobs = {
	_current = 0,
}

---@type fun(self: TerminalJobs, job_buffer: number): TerminalJob | nil
Jobs.find_index_by_buffer = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return nil
	end

	return self[job_index]
end

---@type fun(self: TerminalJobs, window: number): TerminalJob | nil
Jobs.find_index_by_window = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, window)
	return self:find_index_by_buffer(vim.api.nvim_win_get_buf(window))
end

---@type fun(self: TerminalJobs, job: TerminalJob)
Jobs.register = validator.f.arguments({
	validator.f.equal(Jobs),
	validator.f.instance_of(Job),
}) .. function(self, job)
	table.insert(self, job)
	self._current = #self
end

---@type fun(self: TerminalJobs, job_buffer: number)
Jobs.unregister = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return
	end

	table.remove(self, job_index)

	if not self[self._current] then
		self._current = self[1] and 1 or 0
	end
end

function Jobs:count()
	return #self
end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.current = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_buffer)
		if not job_buffer then
			return self[self._current], self._current
		end

		self._current = fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current

		return self[self._current], self._current
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.next = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_buffer)
		local index = job_buffer and fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current
		local next_index = self[index + 1] and index + 1 or 1

		self._current = next_index
		return self:current()
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.prev = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_buffer)
		local index = job_buffer and fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current
		local next_index = self[index - 1] and index - 1 or #self

		self._current = next_index
		return self:current()
	end

local Terminal = Module:extend({
	plugins = {
		{ "samjwill/nvim-unception" },
	},
})

function Terminal:setup()
	self:_setup_keymaps()
	self:_setup_commands()
end

function Terminal:_setup_keymaps()
	local keymap = settings.keymap
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
end

function Terminal:_setup_commands()
	au.group({
		"Terminal",
	}, {
		"TermOpen",
		"*",
		function(autocmd)
			local buffer, file = autocmd.buf, autocmd.file
			-- No numbers
			vim.cmd("setlocal nonumber norelativenumber")
			-- Unlisting
			vim.api.nvim_buf_set_option(buffer, "buflisted", false)

			-- Allowing to close a process directly from normal mode
			key.nmap({ "<C-c>", "i<C-c>", buffer = autocmd.buf })

			Jobs:register(Job:new({ buffer = buffer, file = file }))
		end,
	}, {
		"TermClose",
		"*",
		function(autocmd)
			local buffer = autocmd.buf
			Jobs:unregister(buffer)
		end,
	})
end

function Terminal:toggle()
	local jobs_count = Jobs:count()

	if jobs_count < 1 then
		return self:create()
	end

	local current_buffer_job = Jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if current_buffer_job then
		return self:menu()
	end

	local windows = vim.fn.getwininfo()
	local displayed_job_window = fn.ifind(windows, function(window)
		return Jobs:find_index_by_buffer(window.bufnr)
	end)

	if displayed_job_window then
		return vim.api.nvim_set_current_win(displayed_job_window.winid)
	end

	self:show()
end

function Terminal:show()
	local job, index = Jobs:current()
	local count = Jobs:count()

	if not job then
		return
	end

	vim.api.nvim_command("buffer " .. job.buffer)
	print(string.format("Job %d/%d", index, count))
end

function Terminal:create(command)
	if command then
		vim.api.nvim_command("terminal " .. command)
	else
		vim.api.nvim_command("terminal")
	end

	vim.schedule(function()
		vim.api.nvim_command("startinsert")
	end)
end

function Terminal:next()
	local jobs_count = Jobs:count()

	if jobs_count < 1 then
		return
	end

	local current_buffer_job = Jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if not current_buffer_job then
		return self:show()
	end

	Jobs:next(current_buffer_job.buffer)
	self:show()
end

function Terminal:prev()
	local jobs_count = Jobs:count()

	if jobs_count < 1 then
		return
	end

	local current_buffer_job = Jobs:find_index_by_buffer(vim.api.nvim_get_current_buf())

	if not current_buffer_job then
		return self:show()
	end

	Jobs:prev(current_buffer_job.buffer)
	self:show()
end

function Terminal:jobs_menu(options)
	local jobs_count = Jobs:count()

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

	local menu = fn.imap(Jobs, function(job)
		return {
			job.file,
			job = job,
		}
	end)
	menu.on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		modal_menu.actions.close(modal_menu.buffer)
		Jobs:current(selection.value.job.buffer)
		self:show()
	end

	require("integration.picker"):menu(menu, options)
end

function Terminal:menu(options)
	local keymap = settings.keymap
	local config = settings.config
	options = options or {}
	options = vim.tbl_extend("force", { prompt_title = "Terminal actions" }, options)

	local menu = {}
	local jobs_count = Jobs:count()

	if jobs_count > 0 then
		table.insert(menu, {
			jobs_count .. " job" .. (jobs_count > 1 and "s" or "") .. " running",
			handler = fn.bind(self.jobs_menu, self),
		})
	end

	-- TODO: We need a util which makes it possible inserting multiple values in a tbl
	table.insert(menu, {
		"Create a new terminal",
		":term[inal]",
		handler = fn.bind(self.create, self),
	})
	table.insert(menu, {
		"Next terminal",
		keymap["terminal.next"],
		handler = fn.bind(self.next, self),
	})
	table.insert(menu, {
		"Previous terminal",
		keymap["terminal.prev"],
		handler = fn.bind(self.prev, self),
	})
	table.insert(menu, {
		"Launch ...",
		":terminal ...",
		handler = function()
			local command = vim.fn.input({ prompt = "> ", cancelreturn = "", completion = "shellcmd" })
			self:create(command)
		end,
	})

	for _, user_job in ipairs(config["terminal.jobs"]) do
		table.insert(menu, {
			"Launch " .. user_job.command,
			":terminal " .. user_job.command,
			handler = function()
				self:create(user_job.command)
			end,
		})
	end

	menu.on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		modal_menu.actions.close(modal_menu.buffer)
		selection.value.handler()
	end

	require("integration.picker"):menu(menu, options)
end

return Terminal:new()
