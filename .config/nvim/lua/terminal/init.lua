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

Jobs.current = #Jobs.list

function Jobs:_find_index(job)
	local index = nil

	for list_index, list_value in ipairs(self.list) do
		if job.file == list_value.file then
			return list_index
		end
	end

	return index
end

function Jobs:register(job)
	table.insert(self.list, Job:new(job))
	-- vim.api.nvim_buf_set_option(job.buffer, "buflisted", false)
	print(vim.inspect(self.list))
end

function Jobs:unregister(job)
	table.remove(self.list, self:_find_index(job))
	print(vim.inspect(self.list))
end

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
