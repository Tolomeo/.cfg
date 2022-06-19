local Module = require("_shared.module")
local au = require("_shared.au")
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

local Jobs = {}

Jobs.list = {}

Jobs.current = 0

Jobs._find_index = validator.f.arguments({
	validator.f.equal(Jobs),
	Job.validator,
})
	.. function(self, job)
		-- TODO: move to fn._find_index
		for job_index, job_buffer in ipairs(self.list) do
			if job.buffer == job_buffer then
				return job_index
			end
		end

		return nil
	end

Jobs.register = validator.f.arguments({
	validator.f.equal(Jobs),
	Job.validator,
})
	.. function(self, job)
		table.insert(self.list, job.buffer)
		self.list[tostring(job.buffer)] = Job:new(job)
		vim.api.nvim_buf_set_option(job.buffer, "buflisted", false)
		--NOTE: Changing the buffer name would require to dynamically change every job buffer name on creation/deletion of a job
		--[[ vim.api.nvim_buf_set_name(
		job.buffer,
		string.format("%s %d of %d", vim.api.nvim_buf_get_name(job.buffer), #self.list, #self.list)
	) ]]
		self.current = #self.list
	end

Jobs.unregister = validator.f.arguments({
	validator.f.equal(Jobs),
	Job.validator,
}) .. function(self, job)
	local index = self:_find_index(job)

	if not index then
		return
	end

	table.remove(self.list, index)
	self.list[tostring(job.buffer)] = nil

	if not self.list[self.current] then
		self.current = self.list[1] and 1 or 0
	end
end

Jobs._get_window_job = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, window_handler)
	local buffer_handler = vim.api.nvim_win_get_buf(window_handler)
	local job = self.list[tostring(buffer_handler)]

	if job then
		return job
	end

	return nil
end

function Jobs:get_displayed()
	local windows = vim.api.nvim_list_wins()
	local windows_jobs = vim.tbl_map(function(window_handler)
		return self:_get_window_job(window_handler)
	end, windows)

	return vim.tbl_filter(function(job)
		return job and true or false
	end, windows_jobs)
end

function Jobs:create()
	return vim.api.nvim_command("terminal")
end

function Jobs:next()
	local jobs_count = #self.list

	if jobs_count < 1 then
		print("No running jobs found")
	end

	local current_buffer = vim.api.nvim_get_current_buf()
	local current_buffer_job = self.list[tostring(current_buffer)]

	if current_buffer_job and jobs_count == 1 then
		print("Job 1/1")
		return
	end

	if current_buffer_job then
		local current_buffer_job_index = self:_find_index(current_buffer_job)
		local next_job_index = self.list[current_buffer_job_index + 1] and current_buffer_job_index + 1 or 1

		vim.api.nvim_command("buffer " .. tostring(self.list[next_job_index]))
		-- TODO: replace with emitting an event
		-- this stopinsert shouldn't be here as it refers to a specific way to use the terminals
		-- replace with self:emit("job_next") and letting subscribers execute business logic
		vim.api.nvim_command("stopinsert")
		self.current = next_job_index
		print(string.format("Job %d/%d", self.current, jobs_count))
		return
	end

	vim.api.nvim_command("buffer " .. self.list[self.current])
	print(string.format("Job %d/%d", self.current, jobs_count))
end

local Terminal = {}

Terminal.setup = function()
	Terminal._setup_keymaps()
	Terminal._setup_commands()
end

Terminal._setup_keymaps = function()
	-- Exiting term mode using esc
	key.tmap({ "<Esc>", "<C-\\><C-n>" })
	-- TODO: pass jobs from settings
	--[[ key.nmap({
		"<C-g>",
		Terminal.job({ "lazygit" }),
	}) ]]
	key.nmap({
		"<leader>t",
		function()
			Jobs:next()
		end,
	})
	key.nmap({
		"<leader>T",
		function()
			Jobs:create()
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
					Jobs:register({ buffer = autocmd.buf, file = autocmd.file })
					vim.cmd("setlocal nonumber norelativenumber")
					vim.cmd("startinsert")
					-- Allow closing a process directly from normal mode
					key.nmap({ "<C-c>", "i<C-c>" })
				end,
			},
			{
				"BufEnter",
				"term://*",
				"if &buftype == 'terminal' | :startinsert | endif",
				nested = true,
			},
			{
				"TermClose",
				"term://*",
				function(autocmd)
					Jobs:unregister({ buffer = autocmd.buf, file = autocmd.file })
				end,
			},
		},
	})

	-- TODO: verify if possible to do this in lua
	vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
end

--[[ Terminal.job = validator.f.arguments({ validator.f.shape({ "string" }) })
	.. function(job)
		job = Job:new(job)

		return function()
			job:spawn()
		end
	end ]]

return Module:new(Terminal)
