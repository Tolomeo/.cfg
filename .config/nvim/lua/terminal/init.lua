local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
-- local validator = require("_shared.validator")

local Job = {}

function Job:new(job)
	setmetatable(job, {
		__index = self,
	})
	self.__index = self

	return job
end

local Jobs = {}

Jobs.list = {}

Jobs.current = 0

function Jobs:_find_index(job)
	local index = nil

	-- TODO: move to fn._find_index
	for job_index, job_buffer in ipairs(self.list) do
		if job.buffer == job_buffer then
			return job_index
		end
	end

	return index
end

function Jobs:register(job)
	vim.api.nvim_buf_set_option(job.buffer, "buflisted", false)
	table.insert(self.list, job.buffer)
	self.list[tostring(job.buffer)] = Job:new(job)
	self.current = #self.list

	print(vim.inspect(self))
end

function Jobs:unregister(job)
	local index = self:_find_index(job)

	if not index then
		return
	end

	table.remove(self.list, index)
	self.list[tostring(job.buffer)] = nil

	if not self.list[self.current] then
		self.current = self.list[1] and 1 or 0
	end

	print(vim.inspect(self))
end

function Jobs:_get_displayed()
	local window_to_job = function(window)
		local buffer = vim.api.nvim_win_get_buf(window)
		local job = self.list[tostring(buffer)]

		if job then
			return job
		end

		return nil
	end

	local windows = vim.api.nvim_list_wins()

	return vim.tbl_filter(function(job)
		return job and true or false
	end, vim.tbl_map(window_to_job, windows))
end

function Jobs:show() end

function Jobs:hide(job) end

function Jobs:toggle()
	for _, displayed_job in ipairs(self:_get_displayed()) do
		self:hide(displayed_job)
	end
end

function Jobs:next() end
--[[ function Job:new(job)
	job = vim.tbl_extend("force", job, {
		id = nil, buffer = nil, window = nil,
	})
	setmetatable(job, {
		__index = self,
		__call = self.spawn,
	})
	self.__index = self

	return job
end

function Job:_start()
	if self.id then
		self:_stop()
	end

	local cmd = self[1]

	self.id = vim.fn.termopen(cmd, {
		on_stdout = self.on_stdout,
		on_stderr = self.on_stderr,
		-- Closing everything as soon as the job exits
		on_exit = function()
			self.id = nil
			self:_hide()

			if self.on_exit then
				self.on_exit()
			end
		end,
	})
end

function Job:_stop()
	if not self.id then
		return
	end

	vim.fn.jobstop(self.id)
	self.id = nil
end

function Job:_show()
	if self.buffer or self.window then
		self:_hide()
	end

	self.buffer = vim.api.nvim_create_buf(false, false)
	self.window = require("interface.window").modal({
		self.buffer,
		on_resized = function(update)
			vim.fn.jobresize(self.id, update.width, update.height)
		end,
	})

	-- When the window gets closed, close the job as well
	-- on_exit will be triggered and clean all the rest
	au.command({
		{ "WinClosed", "BufLeave" },
		self.buffer,
		function()
			self:_stop()
		end,
	})

	-- some programs use esc to cancel operations
	-- TODO: make these passed as an option for the command or annull all terminal custom mappings
	key.tmap({ "<Esc>", "<Esc>", buffer = self.buffer })
end

function Job:_hide()
	if self.window and vim.api.nvim_win_is_valid(self.window) then
		vim.api.nvim_win_close(self.window, true)
	end

	if self.buffer and vim.api.nvim_buf_is_loaded(self.buffer) then
		vim.api.nvim_buf_delete(self.buffer, { force = true })
	end

	self.window = nil
	self.buffer = nil
end

function Job:spawn()
	self:_show()
	self:_start()
end ]]

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
			print(vim.inspect(Jobs:_get_displayed()))
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
