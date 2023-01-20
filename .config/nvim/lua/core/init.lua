local Module = require("_shared.module")

---@class Finder
local Core = {}

Core.modules = {
	"core.color",
	"core.terminal",
	"core.spelling",
}

return Module:new(Core)
