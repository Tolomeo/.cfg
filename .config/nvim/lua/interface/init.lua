local Module = require("_shared.module")
local validator = require("_shared.validator")

---@class Interface
local Interface = {}

Interface.modules = {
	"interface.window",
	"interface.tab",
	"interface.theme",
}

Interface.sign = validator.f.arguments({
	validator.f.equal(Interface),
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

return Module:new(Interface)
