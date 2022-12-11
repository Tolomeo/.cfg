local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	"project.tree",
	"project.git",
	"project.github",
}

return Module:new(Editor)
