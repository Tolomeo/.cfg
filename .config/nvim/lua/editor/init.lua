local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	language = require("editor.language"),
	buffer = require("editor.buffer"),
	completion = require("editor.completion"),
	snippet = require("editor.snippet"),
	spelling = require("editor.spelling")
}

return Module:new(Editor)
