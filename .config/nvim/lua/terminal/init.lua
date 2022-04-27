local Module = require("utils.module")
local au = require("utils.au")

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
		local window = require("interface").modal({
			buffer,
			on_resize = function(update)
				vim.api.jobresize(job, update.row, update.col)
			end,
		})
		job = vim.fn.termopen(cmd, {
			on_stdout = on_stdout,
			on_stderr = on_stderr,
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

		return job
	end
end

--[[ local function setup_buffer_autocommands(term)
  local conf = config.get()
  local commands = {
    {
      "TermClose",
      fmt("<buffer=%d>", term.bufnr),
      fmt('lua require"toggleterm.terminal".delete(%d)', term.id),
    },
    term:is_float() and {
      "VimResized",
      fmt("<buffer=%d>", term.bufnr),
      fmt('lua require"toggleterm.terminal".__on_vim_resized(%d)', term.id),
    } or nil,
  }

  if conf.start_in_insert then
    vim.cmd("startinsert")
    table.insert(commands, {
      "BufEnter",
      fmt("<buffer=%d>", term.bufnr),
      "startinsert",
    })
  end

  utils.create_augroups({ ["ToggleTerm" .. term.bufnr] = commands })
end ]]

--- Handle when a terminal process exits
---@param term Terminal
--[[ local function __handle_exit(term)
	return function(...)
		if term.on_exit then
			term:on_exit(...)
		end
		if term.close_on_exit then
			term:close()
			if api.nvim_buf_is_loaded(term.bufnr) then
				api.nvim_buf_delete(term.bufnr, { force = true })
			end
		end
	end
end ]]

--[[ function M.open_float(term)
  local opts = term.float_opts or {}
  local valid_buf = term.bufnr and api.nvim_buf_is_valid(term.bufnr)
  local buf = valid_buf and term.bufnr or api.nvim_create_buf(false, false)
  local win = api.nvim_open_win(buf, true, M._get_float_config(term, true))

  term.window, term.bufnr = win, buf

  if opts.winblend then
    vim.wo[win].winblend = opts.winblend
  end
  M.set_options(term.window, term.bufnr, term)
end ]]

--[[ function M._get_float_config(term, opening)
  local opts = term.float_opts or {}
  local width = M._resolve_size(opts.width, term)
    or math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
  local height = M._resolve_size(opts.height, term)
    or math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
  local border = opts.border == "curved" and curved or opts.border or "single"

  return {
    row = (opts.row or math.ceil(vim.o.lines - height) / 2) - 1,
    col = (opts.col or math.ceil(vim.o.columns - width) / 2) - 1,
    relative = opts.relative or "editor",
    style = opening and "minimal" or nil,
    width = width,
    height = height,
    border = opening and border or nil,
  }
end ]]

--[[ ---@private
---Pass self as first parameter to callback
function Terminal:__stdout()
  if self.on_stdout then
    return function(...)
      self.on_stdout(self, ...)
    end
  end
end

---@private
---Pass self as first parameter to callback
function Terminal:__stderr()
  if self.on_stderr then
    return function(...)
      self.on_stderr(self, ...)
    end
  end
end ]]

--[[ self.job_id = fn.termopen(cmd, {
    detach = 1,
    cwd = _get_dir(self.dir),
    on_exit = __handle_exit(self),
    on_stdout = self:__stdout(),
    on_stderr = self:__stderr(),
  }) ]]

--[[ local opts = term.float_opts or {}
  local width = M._resolve_size(opts.width, term)
    or math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
  local height = M._resolve_size(opts.height, term)
    or math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
  local border = opts.border == "curved" and curved or opts.border or "single"

  return {
    row = (opts.row or math.ceil(vim.o.lines - height) / 2) - 1,
    col = (opts.col or math.ceil(vim.o.columns - width) / 2) - 1,
    relative = opts.relative or "editor",
    style = opening and "minimal" or nil,
    width = width,
    height = height,
    border = opening and border or nil,
  } ]]

return Terminal
