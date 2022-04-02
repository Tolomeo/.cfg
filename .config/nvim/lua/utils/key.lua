local Keymap = {}

function Keymap.set(mode, ...)
	local bindings = { ... }

	for _, binding in ipairs(bindings) do
		local lhs, rhs = binding[1], binding[2]
		local opts = { remap = false, silent = true }

		-- Overriding default opts
		for i, v in pairs(binding) do
			if type(i) == "string" then
				opts[i] = v
			end
		end

		vim.keymap.set(mode, lhs, rhs, opts)
	end
end

local M = {}

function M.map(...)
	return Keymap.set("", ...)
end

function M.nmap(...)
	return Keymap.set("n", ...)
end

function M.icmap(...)
	return Keymap.set("!", ...)
end

function M.vmap(...)
	return Keymap.set("v", ...)
end

function M.imap(...)
	return Keymap.set("i", ...)
end

function M.tmap(...)
	return Keymap.set("t", ...)
end

function M.omap(...)
	return Keymap.set("o", ...)
end

function M.cmap(...)
	return Keymap.set("c", ...)
end

function M.xmap(...)
	return Keymap.set("x", ...)
end

function M.smap(...)
	return Keymap.set("s", ...)
end

function M.lmap(...)
	return Keymap.set("l", ...)
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
