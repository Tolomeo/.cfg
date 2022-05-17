local Module = require("_shared.module")

local defaults = {
	component_separator = "│",
	section_separator = "",
}

local Interface = {}

Interface.modules = {
	window = require("interface.window"),
	project_explorer = require("interface.project_explorer"),
	theme = require("interface.theme"),
}

function Interface.toggle_tree()
	Interface.modules.project_explorer.toggle()
end

return Module:new(Interface)
