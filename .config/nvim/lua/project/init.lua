local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	tree = require("project.tree"),
	git = require("project.git"),
}

return Module:new(Editor)
