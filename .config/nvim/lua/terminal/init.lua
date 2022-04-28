local Module = require("utils.module")
local au = require("utils.au")
local key = require("utils.key")

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
	if self.id then
		vim.fn.jobstop(self.id)
		self.id = nil
	end
end

function Job:_show()
	self.buffer = vim.api.nvim_create_buf(false, false)
	self.window = require("interface.window").modal({
		self.buffer,
		on_resized = function(update)
			vim.fn.jobresize(self.id, update.width, update.height)
		end,
	})

	-- When the window gets closed, close the job as well
	-- on_exit will be triggered and clean all the rest
	au.group({
		"Terminal.Job",
		{
			{
				{ "WinClosed", "BufLeave" },
				nil,
				function()
					self:_stop()
				end,
				buffer = self.buffer,
			},
		},
	})

	-- some programs use esc to cancel operations
	-- TODO: make these passed as an option for the command or annull all terminal custom mappings
	key.tmap({ "<Esc>", "<Esc>", buffer = self.buffer })
end

function Job:_hide()
	if self.window and vim.api.nvim_win_is_valid(self.window) then
		vim.api.nvim_win_close(self.window, true)
		self.window = nil
	end

	if self.buffer and vim.api.nvim_buf_is_loaded(self.buffer) then
		vim.api.nvim_buf_delete(self.buffer, { force = true })
		self.buffer = nil
	end
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
			"OnTerminalBufferEnter",
			{
				{
					"TermOpen",
					"term://*",
					"startinsert",
				},
				{
					"BufEnter",
					"term://*",
					"if &buftype == 'terminal' | :startinsert | endif",
					nested = true,
				},
				{
					"TermOpen",
					"term://*",
					"setlocal nonumber norelativenumber",
				},
			},
		})

		-- TODO: verify if possible to do this in lua
		vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
	end,
})

function Terminal.job(job)
	job = Job:new(job)

	return function()
		job:spawn()
	end
end

return Terminal
