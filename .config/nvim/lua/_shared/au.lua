local fn = require("_shared.fn")
local validator = require("_shared.validator")

---@class Au
local M = {}

---@class Au.Group
---@field [1] string
---@field clear? boolean

local validate_group = validator.f.shape({ "string", clear = validator.f.optional("boolean") })

---@class Au.Command
---@field [1] string | string[]
---@field [2] string | string[] | number
---@field [3] string | function
---@field once? boolean
---@field group? integer

local validate_command = validator.f.shape({
	{ "string", "table" },
	{ "string", "table", "number" },
	{ "string", "function" },
	group = validator.f.optional("number"),
	once = validator.f.optional("boolean"),
})

---Creates an augroup
---If autocmds are specified, they are created associating them with the created augroup
---@type fun(group: Au.Group, ...?: Au.Command): integer, integer[]
M.group = validator.f.arguments({
	validate_group,
	validator.f.optional(validate_command),
}) .. function(group, ...)
	local name = group[1]
	local opts = fn.kreduce(group, function(o, v, k)
		o[k] = v
		return o
	end, { clear = true })
	local autocmds = { ... }

	local group_id = vim.api.nvim_create_augroup(name, opts)
	local commands_ids = fn.imap(autocmds, function(autocmd)
		autocmd.group = group_id
		return M.command(autocmd)
	end)

	return group_id, unpack(commands_ids)
end

---Creates an aucmd
---@type fun(config: Au.Command): integer
M.command = validator.f.arguments({ validate_command })
	.. function(config)
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

M.delete_command = vim.api.nvim_del_autocmd

return M
