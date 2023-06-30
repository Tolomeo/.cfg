local validator = require("_shared.validator")

local String = {}

function String.trim(str)
	return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

function String.split(str, delimiter)
	local result = {}
	local pattern = string.format("([^%s]+)", delimiter)

	for word in string.gmatch(str, pattern) do
		table.insert(result, word)
	end

	return result
end

String.starts_with = validator.f.arguments({
	"string",
	"string",
}) .. function(str, pattern)
	return string.sub(str, 1, string.len(pattern)) == pattern
end

return String
