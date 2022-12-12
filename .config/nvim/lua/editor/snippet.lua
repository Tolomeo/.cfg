local Module = require("_shared.module")

---@class Editor.Snippet
local Snippet = {}

Snippet.plugins = {
	"L3MON4D3/LuaSnip",
}

return Module:new(Snippet)
