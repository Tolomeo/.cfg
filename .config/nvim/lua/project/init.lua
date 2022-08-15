local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	tree = require('project.tree')
}

return Module:new(Editor)
