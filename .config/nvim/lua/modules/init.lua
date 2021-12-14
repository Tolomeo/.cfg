local modules = {
	core = require('modules.core'),
	theme = require('modules.theme'),
	editor = require('modules.editor'),
	git = require('modules.git'),
	finder = require('modules.finder'),
	intellisense = require('modules.intellisense')
}
local M = {}

function M.for_each(callback)
	for _, module in pairs(modules) do
		callback(module)
	end
end

setmetatable(M, { __index = modules })

return M
