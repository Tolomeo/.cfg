local Module = require("_shared.module")

---@class Project
local Project = {}

Project.modules = {
	"project.tree",
	"project.git",
	"project.github",
}

return Module:new(Project)
