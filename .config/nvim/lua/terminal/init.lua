local Module = require("utils.module")
local au = require("utils.au")
local key = require("utils.key")

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

function Terminal.job(options)
	local cmd = options[1]
	local on_stdout = options.on_stdout
	local on_stderr = options.on_stderr
	local on_exit = options.on_exit
	local on_exited = options.on_exited

	return function()
		local job
		local buffer = vim.api.nvim_create_buf(false, false)
		local window = require("interface.window").modal({
			buffer,
			on_resized = function(update)
				vim.fn.jobresize(job, update.width, update.height)
			end,
		})
		job = vim.fn.termopen(cmd, {
			on_stdout = on_stdout,
			on_stderr = on_stderr,
			-- Closing everything as soon as the job exits
			on_exit = function()
				if on_exit then
					on_exit()
				end

				if vim.api.nvim_win_is_valid(window) then
					vim.api.nvim_win_close(window, true)
				end

				if vim.api.nvim_buf_is_loaded(buffer) then
					vim.api.nvim_buf_delete(buffer, { force = true })
				end

				if on_exited then
					on_exited()
				end
			end,
		})

		-- When the window gets closed, close the job as well
		-- on_exit will be triggered and clean all the rest
		au.group({
			"Terminal.Job",
			{
				{
					"WinClosed",
					nil,
					function()
						vim.fn.jobstop(job)
					end,
					buffer = buffer,
				},
			},
		})

		-- some programs use esc to cancel operations
		-- TODO: make these passed as an option for the command or annull all terminal custom mappings
		key.tmap({ "<Esc>", "<Esc>", buffer = buffer })

		return job
	end
end

return Terminal
