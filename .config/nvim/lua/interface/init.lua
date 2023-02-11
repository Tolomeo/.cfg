local Module = require("_shared.module")
local validator = require("_shared.validator")

local Interface = Module:extend({
	modules = {
		"interface.color",
		"interface.line",
		"interface.window",
	},
})

Interface.sign = validator.f.arguments({
	validator.f.instance_of(Interface),
	validator.f.shape({ name = "string", text = "string" }),
}) .. function(_, ...)
	local signs = { ... }

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, {
			texthl = sign.name,
			text = sign.text,
			numhl = "",
		})
	end
end

return Interface:new()
