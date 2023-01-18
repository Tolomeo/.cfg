local Module = require("_shared.module")

---@class Finder
local Core = {}

Core.modules = {
	"core.terminal",
}

return Module:new(Core)
