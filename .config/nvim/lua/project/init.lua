local Module = require("_shared.module")

local Project = Module:extend({
	modules = {
		"project.tree",
		"project.git",
		"project.github",
	},
})

return Project:new()
