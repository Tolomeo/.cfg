local Module = require("_shared.module")
local au = require("_shared.au")
local fn = require("_shared.fn")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Job = {}

local default_keymaps = {
	["new"] = "<C-t>",
	["next"] = "<leader>t",
	["prev"] = "<leader>T",
}

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
		default_keymaps["next"],
		function()
			Terminal:cycle("forward")
		end,
	}, {
		default_keymaps["prev"],
		function()
			Terminal:cycle("backward")
		end,
	}, {
		default_keymaps["new"],
		function()
			Terminal:create()
			vim.api.nvim_command("startinsert")
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

					Terminal:register({ buffer = buffer, file = file })
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

Terminal._get_buffer_job = validator.f.arguments({
	validator.f.equal(Terminal),
	"number",
}) .. function(self, buffer_handler)
	local job = self.jobs[tostring(buffer_handler)]
	return job and job or nil
end

Terminal._get_window_job = validator.f.arguments({
	validator.f.equal(Terminal),
	"number",
}) .. function(self, window_handler)
	return self:_get_buffer_job(vim.api.nvim_win_get_buf(window_handler))
end

function Terminal:open_current()
	vim.api.nvim_command("buffer " .. self.jobs[self.current])
	print(string.format("Job %d/%d", self.current, #self.jobs))
end

function Terminal:create()
	return vim.api.nvim_command("terminal")
end

Terminal.cycle = validator.f.arguments({ validator.f.equal(Terminal), validator.f.one_of({ "forward", "backward" }) })
	.. function(self, direction)
		local jobs_count = #self.jobs

		if jobs_count < 1 then
			print("No running jobs found")
			return
		end

		local current_buffer = vim.api.nvim_get_current_buf()
		local current_buffer_job = self.jobs[tostring(current_buffer)]

		if not current_buffer_job then
			self:open_current()
			return
		end

		if jobs_count == 1 then
			print("Only 1 job present")
			return
		end

		local current_job_index = fn.find_index(self.jobs, function(registered_job)
			return registered_job == current_buffer_job.buffer
		end)
		local next_job_index = ({
			forward = function(current_index)
				return self.jobs[current_index + 1] and current_index + 1 or 1
			end,
			backward = function(current_index)
				return self.jobs[current_index - 1] and current_index - 1 or #self.jobs
			end,
		})[direction](current_job_index)

		self.current = next_job_index
		self:open_current()
	end

return Module:new(Terminal)
