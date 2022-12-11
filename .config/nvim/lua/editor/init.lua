local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	"editor.language",
	"editor.buffer",
	"editor.completion",
	"editor.snippet",
	"editor.spelling",
}

return Module:new(Editor)
