local valid = require("_shared.validate")
local M = {}

M.group = valid.arguments(valid.types.shape({ "string", "table", clear = valid.types.optional("boolean") }))
	.. function(config)
		local name, autocmds = config[1], config[2]
		local opts = { clear = true }

		-- Overriding default opts
		for i, v in pairs(config) do
			if type(i) == "string" then
				opts[i] = v
			end
		end

		local group = vim.api.nvim_create_augroup(name, opts)

		for _, autocmd in ipairs(autocmds) do
			autocmd.group = group
			M.command(autocmd)
		end
	end

M.command = valid.arguments(
	valid.types.shape({ { "string", "table" }, { "string", "table", "number" }, { "string", "function" } })
)
	.. function(config)
		local event, selector, handler = config[1], config[2], config[3]
		local opts = {}

		-- Overriding default opts
		for i, v in pairs(config) do
			if type(i) == "string" then
				opts[i] = v
			end
		end

		local selectorType = type(selector)
		local handlerType = type(handler)
		opts.pattern = (selectorType == "string" or selectorType == "table") and selector or nil
		opts.buffer = selectorType == "number" and selector or nil
		opts.command = handlerType ~= "function" and handler or nil
		opts.callback = handlerType == "function" and handler or nil

		vim.api.nvim_create_autocmd(event, opts)
	end

return M
