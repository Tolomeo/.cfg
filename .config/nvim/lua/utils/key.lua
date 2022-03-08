local Keymap = {
	_set = {},
}

function Keymap.set(fn)
	local id = string.format("%p", fn)
	Keymap._set[id] = fn
	return string.format('<Cmd>lua require("utils.key")._maps.exec("%s")<CR>', id)
end

function Keymap.exec(id)
	return Keymap._set[id]()
end

function Keymap.clear(id)
	if id then
		Keymap._set[id] = nil
		return
	end

	Keymap._set = {}
end

function Keymap.create(mode, binding)
	local lhs, rhs = binding[1], binding[2]
	local opts = { noremap = true, silent = true }

	-- Overriding default opts
	for i, v in pairs(binding) do
		if type(i) == "string" then
			opts[i] = v
		end
	end

	-- Registering handler in case a function was passed
	if type(rhs) == "function" then
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

M._maps = setmetatable({}, {
	__index = Keymap,
})

function M.map(...)
	return Keymap.create("", ...)
end

function M.nmap(...)
	return Keymap.create("n", ...)
end

function M.icmap(...)
	return Keymap.create("!", ...)
end

function M.vmap(...)
	return Keymap.create("v", ...)
end

function M.imap(...)
	return Keymap.create("i", ...)
end

function M.tmap(...)
	return Keymap.create("t", ...)
end

function M.omap(...)
	return Keymap.create("o", ...)
end

function M.cmap(...)
	return Keymap.create("c", ...)
end

function M.xmap(...)
	return Keymap.create("x", ...)
end

function M.smap(...)
	return Keymap.create("s", ...)
end

function M.lmap(...)
	return Keymap.create("l", ...)
end

function M.feed(keys, mode)
	return vim.fn.feedkeys(keys, mode)
end

function M.to_term_code(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.input(keys, input_mode)
	local mode = input_mode or "n" -- Noremap mode by default
	return M.feed(M.to_term_code(keys), mode)
end

return M
