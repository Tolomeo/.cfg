local Module = require("_shared.module")

---@class Cfg.Integration
local Integration = {}

Integration.modules = {
	"integration.terminal",
	"integration.location",
	"integration.picker",
}

return Module:new(Integration)
