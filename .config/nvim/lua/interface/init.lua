local Module = require("_shared.module")
local validator = require("_shared.validator")

---@class Cfg.Interface
local Interface = {}

Interface.modules = {
	"interface.color",
	"interface.line",
	"interface.tab",
	"interface.window",
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
