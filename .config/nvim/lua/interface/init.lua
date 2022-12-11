local Module = require("_shared.module")

local Interface = {}

Interface.modules = {
	"interface.window",
	"interface.tab",
	"interface.theme",
}

return Module:new(Interface)
