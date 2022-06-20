local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Job = {}

Job.validator = validator.f.shape({
	file = "string",
	buffer = "number",
})

Job.new = validator.f.arguments({
	validator.f.equal(Job),
	Job.validator,
}) .. function(self, job)
	setmetatable(job, {
		__index = self,
	})
	self.__index = self

	return job
end

local Terminal = {}

Terminal.setup = function()
	Terminal._setup_keymaps()
	Terminal._setup_commands()
end

Terminal._setup_keymaps = function()
	-- Exiting term mode using esc
	key.tmap({ "<Esc>", "<C-\\><C-n>" })

	key.nmap({
		"<leader>t",
		function()
			Terminal:next()
		end,
	})

	key.nmap({
		"<leader>T",
		function()
			Terminal:create()
		end,
	})
end

Terminal._setup_commands = function()
	-- In the terminal emulator, insert mode becomes the default mode
	-- see https://github.com/neovim/neovim/issues/8816
	-- NOTE: there are some caveats and related workarounds documented at the link
	-- TODO: enter insert mode even when the buffer reloaded from being hidden
	-- also, no line numbers in the terminal
	au.group({
		"Terminal",
		{
			{
				"TermOpen",
				"term://*",
				function(autocmd)
					Terminal:register({ buffer = autocmd.buf, file = autocmd.file })
					vim.cmd("setlocal nonumber norelativenumber")
					-- Allow closing a process directly from normal mode
					key.nmap({ "<C-c>", "i<C-c>", buffer = autocmd.buf })
				end,
			},
			{
				"TermClose",
				"term://*",
				function(autocmd)
					Terminal:unregister({ buffer = autocmd.buf, file = autocmd.file })
				end,
			},
		},
	})

	-- TODO: verify if possible to do this in lua
	vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
end

Terminal.jobs = {}

Terminal.current = 0

Terminal.register = validator.f.arguments({
	validator.f.equal(Terminal),
	Job.validator,
})
	.. function(self, job)
		table.insert(self.jobs, job.buffer)
		self.jobs[tostring(job.buffer)] = Job:new(job)
		vim.api.nvim_buf_set_option(job.buffer, "buflisted", false)
		--NOTE: Changing the buffer name would require to dynamically change every job buffer name on creation/deletion of a job
		--[[ vim.api.nvim_buf_set_name(
		job.buffer,
		string.format("%s %d of %d", vim.api.nvim_buf_get_name(job.buffer), #self.jobs, #self.jobs)
	) ]]
		self.current = #self.jobs
	end

Terminal.unregister = validator.f.arguments({
	validator.f.equal(Terminal),
	Job.validator,
}) .. function(self, job)
	local job_index = fn.find_index(self.jobs, function(registered_job)
		return registered_job == job.buffer
	end)

	if not job_index then
		return
	end

	table.remove(self.jobs, job_index)
	self.jobs[tostring(job.buffer)] = nil

	if not self.jobs[self.current] then
		self.current = self.jobs[1] and 1 or 0
	end
end

Terminal._get_window_job = validator.f.arguments({
	validator.f.equal(Terminal),
	"number",
}) .. function(self, window_handler)
	local buffer_handler = vim.api.nvim_win_get_buf(window_handler)
	local job = self.jobs[tostring(buffer_handler)]

	if job then
		return job
	end

	return nil
end

function Terminal:visible_jobs()
	local windows = vim.api.nvim_list_wins()
	return fn.reduce(windows, function(visible_jobs, window_handler)
		local job = self:_get_window_job(window_handler)

		if not job then
			return visible_jobs
		end

		local visible_job = vim.tbl_extend("force", {}, job, { window = window_handler })
		table.insert(visible_jobs, visible_job)

		return visible_jobs
	end, {})
end

function Terminal:jump()
	local visible_jobs = self:visible_jobs()

	if #visible_jobs < 1 then
		Terminal:next()
		return
	end

	local current_buffer = vim.api.nvim_get_current_buf()
	local current_window = vim.api.nvim_get_current_win()
	local current_buffer_job = self.jobs[tostring(current_buffer)]

	if current_buffer_job and #visible_jobs == 1 then
		return
	end

	if current_buffer_job then
		local current_job_window_index = fn.find_index(visible_jobs, function(visible_job)
			return visible_job.window == current_window
		end)
		local next_job_window_index = visible_jobs[current_job_window_index + 1] and current_job_window_index + 1 or 1
		local next_job_window = visible_jobs[next_job_window_index]
		vim.api.nvim_set_current_win(next_job_window.window)
		return
	end

	local next_job_window = visible_jobs[1]
	vim.api.nvim_set_current_win(next_job_window.window)
end

function Terminal:create()
	return vim.api.nvim_command("terminal")
end

function Terminal:next()
	local jobs_count = #self.jobs

	if jobs_count < 1 then
		print("No running jobs found")
		return
	end

	local current_buffer = vim.api.nvim_get_current_buf()
	local current_buffer_job = self.jobs[tostring(current_buffer)]

	if current_buffer_job and jobs_count == 1 then
		print("Job 1/1")
		return
	end

	if current_buffer_job then
		local current_buffer_job_index = fn.find_index(self.jobs, function(registered_job)
			return registered_job == current_buffer_job.buffer
		end)
		local next_job_index = self.jobs[current_buffer_job_index + 1] and current_buffer_job_index + 1 or 1

		vim.api.nvim_command("buffer " .. tostring(self.jobs[next_job_index]))
		-- TODO: replace with emitting an event
		-- this stopinsert shouldn't be here as it refers to a specific way to use the terminals
		-- replace with self:emit("jobs:next") and letting subscribers execute business logic
		vim.api.nvim_command("stopinsert")
		self.current = next_job_index
		print(string.format("Job %d/%d", self.current, jobs_count))
		return
	end

	vim.api.nvim_command("buffer " .. self.jobs[self.current])
	print(string.format("Job %d/%d", self.current, jobs_count))
end

return Module:new(Terminal)
