local fn = require("_shared.fn")
local validator = require("_shared.validator")

local M = {}

M.starts_with = validator.f.arguments({
	"string",
	"string",
}) .. function(str, pattern)
	return string.sub(str, 1, string.len(pattern)) == pattern
end

return M
