local fn = require("_shared.fn")
local validator = require("_shared.validator")

local M = {}

M.shorten = validator.f.arguments({
	validator.f.shape({
		"string",
		len = validator.f.optional("number"),
	}),
}) .. function(options)
	return vim.fn.pathshorten(options[1], options.len)
end

M.format = validator.f.arguments({
	validator.f.shape({
		"string",
		"string",
	}),
}) .. function(options)
	local path, mods = options[1], options[2]

	return vim.fn.fnamemodify(path, mods)
end

return M
