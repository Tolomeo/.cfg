local Module = require("_shared.module")

local Editor = {}

Editor.modules = {
	language = require("editor.language"),
	text = require("editor.text"),
}

Editor.comment_line = function()
	return Editor.modules.text.comment_line()
end

Editor.comment_selection = function()
	return Editor.modules.text.comment_selection()
end

Editor.cword = function()
	return Editor.modules.text.cword()
end

return Module:new(Editor)
