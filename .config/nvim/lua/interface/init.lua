local Module = require("_shared.module")

---@class Interface
local Interface = {}

Interface.modules = {
	"interface.window",
	"interface.tab",
	"interface.theme",
}

return Module:new(Interface)
