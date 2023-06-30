local validator = require("_shared.validator")
local fn = require("_shared.fn")
local map = require("_shared.map")

local M = {}

--- Wrapper for vim.notify
--- see :h vim.notify
---@type fun(message: string, level: string | nil, options: table | nil): nil
M.log = validator.f.arguments({
	"string",
	validator.f.optional(validator.f.one_of(map.keys(vim.log.levels))),
	validator.f.optional("table"),
}) .. function(message, level, options)
	level = level or "INFO"
	options = options or {}
	vim.notify(message, vim.log.levels[level], options)
end

--- Wrapper for vim.notify_once
--- see :h vim.notify_once
---@type fun(message: string, level: string | nil, options: table | nil): nil
M.log_once = validator.f.arguments({
	"string",
	validator.f.optional(validator.f.one_of(map.keys(vim.log.levels))),
	validator.f.optional("table"),
}) .. function(message, level, options)
	level = level or "INFO"
	options = options or {}
	vim.notify_once(message, vim.log.levels[level], options)
end

--- Logs a notification message of INFO level
---@type fun(message: string, level: string | nil, options: table | nil): nil
M.info = validator.f.arguments({
	"string",
	validator.f.optional("table"),
}) .. function(message, options)
	return vim.notify(message, "INFO", options)
end

--- Logs a notification message of ERROR level
---@type fun(message: string, level: string | nil, options: table | nil): nil
M.error = validator.f.arguments({
	"string",
	validator.f.optional("table"),
}) .. function(message, options)
	return vim.notify(message, "ERROR", options)
end

--- Inspects the value given
---@param value any
M.debug = function(value)
	print(vim.inspect(value))
end

return M
