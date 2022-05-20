local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	language = require("editor.language"),
	text = require("editor.text"),
	completion = require("editor.completion"),
	snippet = require("editor.snippet")
}

return Module:new(Editor)
