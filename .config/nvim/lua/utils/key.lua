local Keymap = {
	_set = {}
}

function Keymap.set(fn)
	local id = string.format('%p', fn)
	Keymap._set[id] = fn
	return string.format('<Cmd>lua require("utils.key").map.exec("%s")<CR>', id)
end

function Keymap.exec(id)
	return Keymap._set[id]()
end

function Keymap.clear(id)
	if(id) then
		Keymap._set[id] = nil
		return
	end

	Keymap._set = {}
end

function Keymap.create(config)
	local mode, lhs, rhs = config[1], config[2], config[3]
	local opts = { noremap = true, silent = true }

	-- Overriding default opts
	for i, v in pairs(config) do
		if type(i) == 'string' then opts[i] = v end
	end

	-- Registering handler in case a function was passed
	if(type(rhs) == 'function') then
		rhs = Keymap.set(rhs)
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

local M = {}

M.map = setmetatable({}, {
	__index = Keymap,
	__call = function(_, config) return Keymap.create(config) end
})

function M.feed(keys, mode)
	return vim.fn.feedkeys(keys, mode)
end

function M.to_term_code(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.input(keys, input_mode)
	local mode = input_mode or 'n' -- Noremap mode by default
	return M.feed(M.to_term_code(keys), mode)
end

return M
