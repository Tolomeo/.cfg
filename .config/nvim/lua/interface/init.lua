local Module = require("_shared.module")

local Interface = {}

Interface.modules = {
	window = require("interface.window"),
	tab = require("interface.tab"),
	theme = require("interface.theme"),
}

return Module:new(Interface)
