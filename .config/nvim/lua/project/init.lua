local Module = require("_shared.module")

local Project = Module:extend({
	modules = {
		"project.workspace",
		"project.git",
		"project.github",
	},
})

return Project:new()
