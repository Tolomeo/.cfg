local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local valid = require("_shared.validate")

local Job = {}

function Job:new(job)
	job = vim.tbl_extend("force", job, {
		id = nil,
		buffer = nil,
		window = nil,
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
		nil,
		function()
			self:_stop()
		end,
		buffer = self.buffer,
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
end

local Terminal = Module:new({
	setup = function()
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
					function()
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
			},
		})

		-- TODO: verify if possible to do this in lua
		vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
	end,
})

Terminal.job = valid.arguments(valid.types.shape({ "string" }))
	.. function(job)
		job = Job:new(job)

		return function()
			job:spawn()
		end
	end

return Terminal
