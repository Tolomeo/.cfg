local Module = require("_shared.module")

local Interface = {}

Interface.modules = {
	window = require("interface.window"),
	project_explorer = require("interface.project_explorer"),
	theme = require("interface.theme"),
}

return Module:new(Interface)
