local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	language = require("editor.language"),
	text = require("editor.text"),
}

return Module:new(Editor)
