local validator = require("_shared.validator")

local Key = {}

--- Sets a keymap
---@param mode string
---@vararg table the keymap description
Key.map = validator.f.arguments({
	validator.f.one_of({ "", "n", "!", "v", "i", "t", "o", "c", "l" }),
	validator.f.shape({ "string", { "string", "function" } }),
})
	.. function(mode, ...)
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

--- Sets a keymap for normal mode
---@vararg table the keymap description
Key.nmap = function(...)
	return Key.map("n", ...)
end

--- Sets a keymap for insert and command line modes
---@vararg table the keymap description
Key.icmap = function(...)
	return Key.map("!", ...)
end

--- Sets a keymap for visual mode
---@vararg table the keymap description
Key.vmap = function(...)
	return Key.map("v", ...)
end

--- Sets a keymap for visual mode
---@vararg table the keymap description
Key.imap = function(...)
	return Key.map("i", ...)
end

--- Sets a keymap for terminal mode
---@vararg table the keymap description
Key.tmap = function(...)
	return Key.map("t", ...)
end

--- Sets a keymap for operator pending mode
---@vararg table the keymap description
Key.omap = function(...)
	return Key.map("o", ...)
end

--- Sets a keymap for command line mode
---@vararg table the keymap description
Key.cmap = function(...)
	return Key.map("c", ...)
end

--- Sets a keymap for visual and select mode
---@vararg table the keymap description
Key.xmap = function(...)
	return Key.map("x", ...)
end

--- Sets a keymap for select mode
---@vararg table the keymap description
Key.smap = function(...)
	return Key.map("s", ...)
end

--- Sets a keymap for l mode, see :h mapmode-l
---@vararg table the keymap description
Key.lmap = function(...)
	return Key.map("l", ...)
end

--- Replaces terminal codes and keycodes (<CR>, <Esc>, ...) in a
--- string with the internal representation.
---@param keys string
Key.to_term_code = validator.f.arguments({ "string" })
	.. function(keys)
		return vim.api.nvim_replace_termcodes(keys, true, true, true)
	end

--- Characters in keys are queued for processing as if they
--- come from a mapping or were typed by the user.
---@param keys string
---@param mode string
---@return number
Key.feed = validator.f.arguments({ "string", validator.f.optional(validator.f.pattern("^[mntix!]+$")) })
	.. function(keys, mode)
		return vim.fn.feedkeys(keys, mode)
	end

--- Characters in keys are queued for processing as if they
--- come from a mapping or were typed by the user.
--- Replaces terminal codes and keycodes (<CR>, <Esc>, ...) in a
--- string with the internal representation.
---@param keys string
---@param mode string
---@return number
Key.input = validator.f.arguments({ "string", validator.f.optional(validator.f.pattern("^[mntix!]+$")) })
	.. function(keys, input_mode)
		local mode = input_mode or "n" -- Noremap mode by default
		return Key.feed(Key.to_term_code(keys), mode)
	end

--- Sets the leader key
---@param leader string
Key.map_leader = validator.f.arguments({ "string" })
	.. function(leader)
		Key.map("", { leader, "<Nop>" })
		vim.g.mapleader = leader
		vim.g.maplocalleader = leader
	end

return Key
