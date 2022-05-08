local fn = require("_shared.fn")
local validator = require("_shared.validator")
local M = {}

---Creates an augroup
---If autocmds are specified, they are created associating them with the created augroup
---@type fun(config: table): number
M.group = validator.f.arguments({ validator.f.shape({ "string", "table", clear = validator.f.optional("boolean") }) })
	.. function(config)
		local name, autocmds = config[1], config[2]
		local opts = fn.kreduce(config, function(o, v, k)
			o[k] = v
			return o
		end, { clear = true })

		local group = vim.api.nvim_create_augroup(name, opts)

		for _, autocmd in ipairs(autocmds) do
			autocmd.group = group
			M.command(autocmd)
		end

		return group
	end

---Creates an aucmd
---@type fun(config: table): number
M.command = validator.f.arguments({
	validator.f.shape({ { "string", "table" }, { "string", "table", "number" }, { "string", "function" } }),
}) .. function(config)
	local event, selector, handler = config[1], config[2], config[3]
	local opts = fn.kreduce(config, function(o, v, k)
		o[k] = v
		return o
	end, {})

	local selectorType = type(selector)
	local handlerType = type(handler)
	opts.pattern = (selectorType == "string" or selectorType == "table") and selector or nil
	opts.buffer = selectorType == "number" and selector or nil
	opts.command = handlerType ~= "function" and handler or nil
	opts.callback = handlerType == "function" and handler or nil

	return vim.api.nvim_create_autocmd(event, opts)
end

return M
