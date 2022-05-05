local valid = require("_shared.validate")

local Key = {}

Key.map = valid.arguments(
	valid.t.one_of("", "n", "!", "v", "i", "t", "o", "c", "l"),
	valid.t.shape({ "string", { "string", "function" } })
)
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

Key.nmap = function(...)
	return Key.map("n", ...)
end

Key.icmap = function(...)
	return Key.map("!", ...)
end

Key.vmap = function(...)
	return Key.map("v", ...)
end

Key.imap = function(...)
	return Key.map("i", ...)
end

Key.tmap = function(...)
	return Key.map("t", ...)
end

Key.omap = function(...)
	return Key.map("o", ...)
end

Key.cmap = function(...)
	return Key.map("c", ...)
end

Key.xmap = function(...)
	return Key.map("x", ...)
end

Key.smap = function(...)
	return Key.map("s", ...)
end

Key.lmap = function(...)
	return Key.map("l", ...)
end

Key.feed = valid.arguments("string", valid.t.pattern("^[mntix!]+$"))
	.. function(keys, mode)
		return vim.fn.feedkeys(keys, mode)
	end

Key.to_term_code = valid.arguments("string")
	.. function(keys)
		return vim.api.nvim_replace_termcodes(keys, true, true, true)
	end

Key.input = valid.arguments("string", valid.t.pattern("^[mntix!]+$"))
	.. function(keys, input_mode)
		local mode = input_mode or "n" -- Noremap mode by default
		return Key.feed(Key.to_term_code(keys), mode)
	end

Key.map_leader = valid.arguments("string")
	.. function(leader)
		Key.map("", { leader, "<Nop>" })
		-- vim.api.nvim_set_keymap("", leader, "<Nop>", { noremap = true, silent = true })
		vim.g.mapleader = leader
		vim.g.maplocalleader = leader
	end

return Key
