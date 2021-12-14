local modules = {
	core = require('modules.core'),
	theme = require('modules.theme'),
	editor = require('modules.editor'),
	vcs = require('modules.vcs'),
	finder = require('modules.finder'),
	intellisense = require('modules.intellisense')
}
local M = {}

function M.for_each(callback)
	for _, module in pairs(modules) do
		callback(module)
	end
end

--[[ function M.setup()
	M.for_each(function(module)
		module.setup()
	end)
end ]]

setmetatable(M, { __index = modules })

return M
