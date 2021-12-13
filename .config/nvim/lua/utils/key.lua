local Maps = {
	_set = {}
}

function Maps.set(fn)
	local id = string.format('%p', fn)
	Maps._set[id] = fn
	return string.format('<Cmd>lua require("utils.key").exec("%s")<CR>', id)
end

function Maps.exec(id)
	return Maps._set[id]()
end

function Maps.clear()
	Maps._set = {}
end

local M = setmetatable({}, {
	__index = Maps
})

function M.feed(keys, mode)
	-- Noremap by default
	local m = mode or 'n'
	return vim.fn.feedkeys(keys, m)
end

function M.to_term_code(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.map(config)
	local mode, lhs, rhs = config[1], config[2], config[3]
	local opts = { noremap = true, silent = true }

	-- Overriding default opts
	for i, v in pairs(config) do
		if type(i) == 'string' then opts[i] = v end
	end

	-- Registering handler in case a function was passed
	if(type(rhs) == 'function') then
		rhs = Maps.set(rhs)
		opts.expr = false
	end

	-- Basic support for buffer-scoped keybindings
  local buffer = opts.buffer
  opts.buffer = nil

	if buffer then
    return vim.api.nvim_buf_set_keymap(buffer, mode, lhs, rhs, opts)
	end

  return vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

return M
