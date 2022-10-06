local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local validator = require("_shared.validator")
local settings = require("settings")

local Job = {}

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

local Jobs = {
	current = 0,
	list = {},
}

Jobs.get_job_by_buffer = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self.list, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return nil
	end

	return self.list[job_index]
end

Jobs.get_job_by_window = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, window)
	return self:get_job_by_buffer(vim.api.nvim_win_get_buf(window))
end

Jobs.register = validator.f.arguments({
	validator.f.equal(Jobs),
	validator.f.instance_of(Job),
}) .. function(self, job)
	table.insert(self.list, job)
	self.current = #self.list
end

Jobs.unregister = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self.list, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return
	end

	table.remove(self.list, job_index)

	if not self.list[self.current] then
		self.current = self.list[1] and 1 or 0
	end
end

function Jobs:get()
	return self.list
end

function Jobs:get_current()
	return self.list[self.current]
end

function Jobs:set_current(job_buffer)
	local job_index = fn.find_index(self.list, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return
	end

	self.current = job_index
end

function Jobs:count()
	return #self:get()
end

function Jobs:map(func)
	return fn.imap(self.list, func)
end

Jobs.cycle = validator.f.arguments({ validator.f.equal(Jobs), validator.f.one_of({ "forward", "backward" }) })
	.. function(self, direction)
		local next_job_index = ({
			forward = function()
				return self.list[self.current + 1] and self.current + 1 or 1
			end,
			backward = function()
				return self.list[self.current - 1] and self.current - 1 or #self.list
			end,
		})[direction]()

		self.current = next_job_index
	end

local Terminal = {}

Terminal.setup = function()
	Terminal._setup_keymaps()
	Terminal._setup_commands()
end

Terminal._setup_keymaps = function()
	local keymaps = settings.keymaps()
	-- Exiting term mode using esc
	key.tmap({ "<Esc>", "<C-\\><C-n>" })

	key.nmap({
		keymaps["terminal.next"],
		Terminal.next,
	}, {
		keymaps["terminal.prev"],
		Terminal.prev,
	}, {
		keymaps["terminal.create"],
		Terminal.create,
	}, {
		keymaps["terminal.jobs"],
		function()
			Terminal.jobs_menu()
		end,
	})
end

Terminal._setup_commands = function()
	au.group({
		"Terminal",
		{
			{
				"TermOpen",
				"term://*",
				function(autocmd)
					local buffer, file = autocmd.buf, autocmd.file
					-- No numbers
					vim.cmd("setlocal nonumber norelativenumber")
					-- vim.api.nvim_buf_set_option(buffer, "number", false)
					-- vim.api.nvim_buf_set_option(buffer, "relativenumber", false)
					-- Unlisting
					vim.api.nvim_buf_set_option(buffer, "buflisted", false)
					-- Allow closing a process directly from normal mode
					key.nmap({ "<C-c>", "i<C-c>", buffer = autocmd.buf })

					--[[ local test = Job:new({ buffer = buffer, file = file })
					print(getmetatable(test)) ]]
					Jobs:register(Job:new({ buffer = buffer, file = file }))
				end,
			},
			{
				"TermClose",
				"term://*",
				function(autocmd)
					local buffer = autocmd.buf
					Jobs:unregister(buffer)
				end,
			},
		},
	})
end

function Terminal.show()
	local current_job_index = Jobs.current
	local jobs_count = Jobs:count()
	local current_job_buffer = Jobs:get_current().buffer

	vim.api.nvim_command("buffer " .. current_job_buffer)
	print(string.format("Job %d/%d", current_job_index, jobs_count))
end

function Terminal.create()
	vim.api.nvim_command("terminal")
	vim.api.nvim_command("startinsert")
end

Terminal.next = function()
	local jobs_count = Jobs:count()

	print(jobs_count)

	if jobs_count < 1 then
		local create_job = vim.fn.confirm("No running jobs found, do you want to create one?", "&Yes\n&No", 1)

		if create_job == 1 then
			return Terminal.create()
		end

		return
	end

	local current_buffer_job = Jobs:get_job_by_buffer(vim.api.nvim_get_current_buf())

	print(current_buffer_job)

	if not current_buffer_job then
		return Terminal.show()
	end

	Jobs:set_current(current_buffer_job.buffer)
	Jobs:cycle("forward")
	Terminal.show()
end

Terminal.prev = function()
	local jobs_count = Jobs:count()

	if jobs_count < 1 then
		local create_job = vim.fn.confirm("No running jobs found, do you want to create one?", "&Yes\n&No", 1)

		if create_job == 1 then
			return Terminal.create()
		end

		return
	end

	local current_buffer_job = Jobs:get_job_by_buffer(vim.api.nvim_get_current_buf())

	if not current_buffer_job then
		return Terminal.show()
	end

	Jobs:set_current(current_buffer_job.buffer)
	Jobs:cycle("backward")
	Terminal.show()
end

Terminal.jobs_menu = function(options)
	local jobs_count = Jobs:count()

	if jobs_count < 1 then
		return
	end

	options = options or {}
	options = vim.tbl_extend("force", {
		prompt_title = "Terminal jobs",
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

	local menu = Jobs:map(function(job)
		return {
			job.file,
			job = job,
		}
	end)
	menu.on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		modal_menu.actions.close(modal_menu.buffer)
		Jobs:set_current(selection.value.job.buffer)
		Terminal.show()
	end

	require("finder.picker").menu(menu, options)
end

return Module:new(Terminal)
