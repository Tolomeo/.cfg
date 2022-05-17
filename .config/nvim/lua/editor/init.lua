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

Editor.open_code_actions = function()
	return Editor.modules.language.open_code_actions()
end

Editor.format = function()
	return Editor.modules.language.format()
end

Editor.eslint_fix = function()
	return Editor.modules.language.eslint_fix()
end

Editor.go_to_definition = function()
	return Editor.modules.language.go_to_definition()
end

Editor.go_to_type_definition = function()
	return Editor.modules.language.go_to_type_definition()
end

Editor.go_to_implementation = function()
	return Editor.modules.language.go_to_implementation()
end

Editor.show_references = function()
	return Editor.modules.language.show_references()
end

Editor.show_symbol_doc = function()
	return Editor.modules.language.show_symbol_doc()
end

Editor.rename_symbol = function()
	return Editor.modules.language.rename_symbol()
end

Editor.highlight_symbol = function()
	return Editor.modules.language.highlight_symbol()
end

Editor.show_diagnostics = function()
	return Editor.modules.language.show_diagnostics()
end

Editor.next_diagnostic = function()
	return Editor.modules.language.next_diagnostic()
end

Editor.prev_diagnostic = function()
	return Editor.modules.language.prev_diagnostic()
end

-- TODO: move this check into core module
Editor.has_suggestions = function()
	return Editor.modules.language.has_suggestions()
end

Editor.open_suggestions = function()
	return Editor.modules.language.open_suggestions()
end

Editor.next_suggestion = function(...)
	return Editor.modules.language.next_suggestion(...)
end

Editor.prev_suggestion = function()
	return Editor.modules.language.prev_suggestion()
end

Editor.confirm_suggestion = function()
	return Editor.modules.language.confirm_suggestion()
end

return Module:new(Editor)
